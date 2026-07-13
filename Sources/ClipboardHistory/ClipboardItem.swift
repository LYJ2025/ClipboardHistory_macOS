import Foundation
import AppKit

enum ClipboardContentType: String, Codable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    var contentType: ClipboardContentType
    var textContent: String?
    var imageFileName: String?
    var createdAt: Date
    var isPinned: Bool

    init(text: String) {
        self.id = UUID()
        self.contentType = .text
        self.textContent = text
        self.imageFileName = nil
        self.createdAt = Date()
        self.isPinned = false
    }

    init(imageFileName: String) {
        self.id = UUID()
        self.contentType = .image
        self.textContent = nil
        self.imageFileName = imageFileName
        self.createdAt = Date()
        self.isPinned = false
    }

    var displayTitle: String {
        switch contentType {
        case .text:
            return textContent ?? ""
        case .image:
            return "图片"
        }
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: createdAt)
    }

    var isExpired: Bool {
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date()
        return createdAt < sixtyDaysAgo
    }
}
