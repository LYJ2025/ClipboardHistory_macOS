import SwiftUI
import AppKit

@main
struct ClipboardHistoryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 420, height: 650)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var monitor: ClipboardMonitor?
    private let store = ClipboardStore.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        startMonitoring()
        registerGlobalHotkey()
        NSApp.setActivationPolicy(.accessory)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showMainWindow()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "剪贴板历史")

        let menu = NSMenu()
        let openItem = NSMenuItem(title: "打开剪贴板历史", action: #selector(showMainWindow), keyEquivalent: "")
        openItem.target = self
        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(openItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)
        statusItem?.menu = menu
    }

    @objc private func showMainWindow() {
        guard let window = NSApp.windows.first else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    private func startMonitoring() {
        monitor = ClipboardMonitor(store: store)
        monitor?.start()
    }

    private func registerGlobalHotkey() {
        guard store.hotkeyEnabled, store.hotkeyKeyCode > 0 else { return }
        HotkeyManager.shared.register(keyCode: store.hotkeyKeyCode, modifiers: store.hotkeyModifiers) { [weak self] in
            self?.toggleMainWindow()
        }
    }

    @objc private func toggleMainWindow() {
        guard let window = NSApp.windows.first else { return }
        if window.isKeyWindow && window.isVisible {
            window.orderOut(nil)
        } else {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
