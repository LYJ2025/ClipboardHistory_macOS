import Foundation
import AppKit
import SwiftUI

@Observable
@MainActor
final class ClipboardStore {
    @MainActor static let shared = ClipboardStore()

    var items: [ClipboardItem] = []
    var searchText: String = ""
    var backgroundOpacity: Double {
        didSet {
            UserDefaults.standard.set(backgroundOpacity, forKey: "backgroundOpacity")
        }
    }

    var hotkeyKeyCode: Int {
        didSet {
            UserDefaults.standard.set(hotkeyKeyCode, forKey: "hotkeyKeyCode")
        }
    }

    var hotkeyModifiers: UInt {
        didSet {
            UserDefaults.standard.set(hotkeyModifiers, forKey: "hotkeyModifiers")
        }
    }

    var hotkeyEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hotkeyEnabled, forKey: "hotkeyEnabled")
        }
    }

    private let fileManager = FileManager.default
    private var appSupportDirectory: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("ClipboardHistory", isDirectory: true)
    }

    private var historyFileURL: URL {
        appSupportDirectory.appendingPathComponent("history.json")
    }

    private var imagesDirectoryURL: URL {
        appSupportDirectory.appendingPathComponent("images", isDirectory: true)
    }

    init() {
        if let saved = UserDefaults.standard.value(forKey: "backgroundOpacity") as? Double {
            self.backgroundOpacity = saved
        } else {
            self.backgroundOpacity = 0.85
        }
        self.hotkeyKeyCode = UserDefaults.standard.integer(forKey: "hotkeyKeyCode")
        self.hotkeyModifiers = UInt(UserDefaults.standard.integer(forKey: "hotkeyModifiers"))
        self.hotkeyEnabled = UserDefaults.standard.bool(forKey: "hotkeyEnabled")
        createDirectoriesIfNeeded()
        loadItems()
        cleanupExpiredItems()
    }

    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: true)
    }

    private func loadItems() {
        guard let data = try? Data(contentsOf: historyFileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let loadedItems = try? decoder.decode([ClipboardItem].self, from: data) {
            items = loadedItems
        }
    }

    private func saveItems() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(items) {
            try? data.write(to: historyFileURL)
        }
    }

    func addText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if items.contains(where: { $0.textContent == trimmed }) { return }
        items.insert(ClipboardItem(text: trimmed), at: 0)
        saveItems()
    }

    func addImage(_ image: NSImage) {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else { return }

        let fileName = "\(UUID().uuidString).png"
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        do {
            try pngData.write(to: fileURL)
            items.insert(ClipboardItem(imageFileName: fileName), at: 0)
            saveItems()
        } catch {
            print("保存图片失败: \(error)")
        }
    }

    func image(for item: ClipboardItem) -> NSImage? {
        guard let fileName = item.imageFileName else { return nil }
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        return NSImage(contentsOf: fileURL)
    }

    func copyToClipboard(item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        switch item.contentType {
        case .text:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let image = image(for: item) {
                pasteboard.writeObjects([image])
            }
        }
    }

    func togglePin(item: ClipboardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isPinned.toggle()
            sortItems()
            saveItems()
        }
    }

    func delete(item: ClipboardItem) {
        if item.contentType == .image, let fileName = item.imageFileName {
            let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
            try? fileManager.removeItem(at: fileURL)
        }
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    func cleanupExpiredItems() {
        let expired = items.filter { $0.isExpired }
        for item in expired {
            if item.contentType == .image, let fileName = item.imageFileName {
                let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
                try? fileManager.removeItem(at: fileURL)
            }
        }
        items.removeAll { $0.isExpired }
        saveItems()
    }

    private func sortItems() {
        items.sort {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            }
            return $0.createdAt > $1.createdAt
        }
    }

    var filteredItems: [ClipboardItem] {
        let sorted = items.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            }
            return $0.createdAt > $1.createdAt
        }
        if searchText.isEmpty { return sorted }
        return sorted.filter { item in
            if item.contentType == .text {
                return item.textContent?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            return item.displayDate.localizedCaseInsensitiveContains(searchText)
        }
    }
}
