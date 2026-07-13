import SwiftUI
import AppKit

struct ShortcutRecorderView: NSViewRepresentable {
    @Binding var keyCode: Int
    @Binding var modifiers: UInt
    @Binding var isRecording: Bool

    func makeNSView(context: Context) -> ShortcutRecorderNSView {
        let view = ShortcutRecorderNSView()
        view.onKeyCaptured = { code, mods in
            self.keyCode = code
            self.modifiers = mods
            self.isRecording = false
        }
        return view
    }

    func updateNSView(_ nsView: ShortcutRecorderNSView, context: Context) {
        if isRecording {
            nsView.window?.makeFirstResponder(nsView)
        }
    }
}

final class ShortcutRecorderNSView: NSView {
    var onKeyCaptured: ((Int, UInt) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        let code = Int(event.keyCode)
        let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue

        // Must include at least one modifier key
        let hasModifier = mods & (NSEvent.ModifierFlags.command.rawValue |
                                   NSEvent.ModifierFlags.option.rawValue |
                                   NSEvent.ModifierFlags.control.rawValue |
                                   NSEvent.ModifierFlags.shift.rawValue) != 0

        guard hasModifier else { return }

        // Ignore modifier-only keys
        let modifierKeyCodes: Set<UInt16> = [54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
        guard !modifierKeyCodes.contains(event.keyCode) else { return }

        onKeyCaptured?(code, mods)
    }

    override func flagsChanged(with event: NSEvent) {
        // Ignore standalone modifier presses
    }
}

func shortcutDisplayString(keyCode: Int, modifiers: UInt) -> String {
    guard keyCode > 0 else { return "未设置" }

    var result = ""
    if modifiers & NSEvent.ModifierFlags.control.rawValue != 0 { result += "⌃" }
    if modifiers & NSEvent.ModifierFlags.option.rawValue != 0 { result += "⌥" }
    if modifiers & NSEvent.ModifierFlags.shift.rawValue != 0 { result += "⇧" }
    if modifiers & NSEvent.ModifierFlags.command.rawValue != 0 { result += "⌘" }

    result += keyCodeToString(keyCode: keyCode)
    return result
}

private func keyCodeToString(keyCode: Int) -> String {
    let special: [Int: String] = [
        0: "A", 11: "B", 8: "C", 2: "D", 14: "E",
        3: "F", 5: "G", 4: "H", 34: "I", 38: "J",
        40: "K", 37: "L", 46: "M", 45: "N", 31: "O",
        35: "P", 12: "Q", 15: "R", 1: "S", 17: "T",
        32: "U", 9: "V", 13: "W", 7: "X", 16: "Y",
        6: "Z",
        18: "1", 19: "2", 20: "3", 21: "4", 23: "5",
        22: "6", 26: "7", 28: "8", 25: "9", 29: "0",
        36: "↩", 48: "⇥", 49: "Space", 51: "⌫",
        53: "Esc", 123: "←", 124: "→", 125: "↓", 126: "↑",
        96: "F5", 97: "F6", 98: "F7", 99: "F8",
        100: "F9", 101: "F10", 109: "F11", 103: "F12"
    ]

    if let value = special[keyCode] {
        return value
    }

    return "Key \(keyCode)"
}
