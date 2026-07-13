import Foundation
import AppKit
import Carbon

@MainActor
final class HotkeyManager {
    static let shared = HotkeyManager()

    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyID = EventHotKeyID(signature: 0x434C4248, id: 1) // "CLBH"
    private var toggleAction: (() -> Void)?

    private init() {}

    func register(keyCode: Int, modifiers: UInt, action: @escaping () -> Void) {
        unregister()

        guard keyCode > 0 else { return }

        self.toggleAction = action

        let eventSpec = [EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))]

        let callback: EventHandlerUPP = { _, eventRef, _ -> OSStatus in
            guard let eventRef = eventRef else { return noErr }

            var hotKeyID = EventHotKeyID()
            let result = GetEventParameter(eventRef,
                                           EventParamName(kEventParamDirectObject),
                                           EventParamType(typeEventHotKeyID),
                                           nil,
                                           MemoryLayout<EventHotKeyID>.size,
                                           nil,
                                           &hotKeyID)
            guard result == noErr else { return noErr }

            MainActor.assumeIsolated {
                HotkeyManager.shared.toggleAction?()
            }
            return noErr
        }

        InstallEventHandler(GetEventDispatcherTarget(), callback, 1, eventSpec, nil, &eventHandler)

        let carbonModifiers = carbonModifiers(from: modifiers)
        RegisterEventHotKey(UInt32(keyCode), carbonModifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
    }

    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        toggleAction = nil
    }

    private func carbonModifiers(from modifiers: UInt) -> UInt32 {
        var carbon: UInt32 = 0
        if modifiers & NSEvent.ModifierFlags.command.rawValue != 0 { carbon |= UInt32(cmdKey) }
        if modifiers & NSEvent.ModifierFlags.option.rawValue != 0 { carbon |= UInt32(optionKey) }
        if modifiers & NSEvent.ModifierFlags.control.rawValue != 0 { carbon |= UInt32(controlKey) }
        if modifiers & NSEvent.ModifierFlags.shift.rawValue != 0 { carbon |= UInt32(shiftKey) }
        return carbon
    }
}
