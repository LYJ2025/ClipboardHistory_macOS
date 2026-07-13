import Foundation
import AppKit

@MainActor
final class ClipboardMonitor {
    private let store: ClipboardStore
    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount

    init(store: ClipboardStore) {
        self.store = store
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkPasteboard()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkPasteboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            store.addText(text)
            return
        }

        if let image = NSImage(pasteboard: pasteboard) {
            store.addImage(image)
        }
    }
}
