import SwiftUI
import ServiceManagement

struct SettingsView: View {
    let onBack: () -> Void

    @State private var isAutoStartEnabled = false
    @State private var store = ClipboardStore.shared
    @State private var isRecordingHotkey = false
    @State private var showPermissionAlert = false

    var body: some View {
        VStack(spacing: 0) {
            toolbarView
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    generalSection
                    shortcutSection
                    appearanceSection
                    aboutSection
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 24)
            }
        }
        .frame(minWidth: 360, minHeight: 500)
        .background(.ultraThinMaterial)
        .background(lightBlueBackground.opacity(store.backgroundOpacity))
        .onAppear {
            isAutoStartEnabled = SMAppService.mainApp.status == .enabled
        }
    }

    private var toolbarView: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
            }
            .buttonStyle(.borderless)

            Spacer()

            Text("设置")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Spacer()

            Button(action: {}) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderless)
            .opacity(0)
        }
        .padding()
        .background(.ultraThinMaterial)
        .background(lightBlueHeader.opacity(store.backgroundOpacity))
    }

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("通用")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 0) {
                Toggle("开机自动启动", isOn: $isAutoStartEnabled)
                    .padding()
                    .onChange(of: isAutoStartEnabled) { _, newValue in
                        setAutoStart(enabled: newValue)
                    }

                Divider()
                    .padding(.leading)

                HStack {
                    Text("数据保存位置")
                    Spacer()
                    Text("~/Library/Application Support/ClipboardHistory/")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(store.backgroundOpacity))
            .cornerRadius(10)
        }
    }

    private var shortcutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快捷键")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Toggle("启用全局快捷键", isOn: $store.hotkeyEnabled)

                    Spacer()

                    Button(action: {
                        if store.hotkeyEnabled {
                            isRecordingHotkey.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(isRecordingHotkey ? "按下快捷键..." : shortcutDisplayString(keyCode: store.hotkeyKeyCode, modifiers: store.hotkeyModifiers))
                                .font(.system(.body, design: .monospaced))
                            Image(systemName: isRecordingHotkey ? "record.circle" : "keyboard")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!store.hotkeyEnabled)
                    .background(isRecordingHotkey ? Color.red.opacity(0.15) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding()

                if store.hotkeyEnabled {
                    Divider()
                        .padding(.leading)

                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                        Text("首次使用快捷键可能需要到「系统设置 → 隐私与安全性 → 辅助功能」中允许本应用。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                }

                ShortcutRecorderView(keyCode: $store.hotkeyKeyCode, modifiers: $store.hotkeyModifiers, isRecording: $isRecordingHotkey)
                    .frame(width: 0, height: 0)
                    .focusable(false)
            }
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(store.backgroundOpacity))
            .cornerRadius(10)
            .onChange(of: store.hotkeyEnabled) { _, enabled in
                if enabled {
                    HotkeyManager.shared.register(keyCode: store.hotkeyKeyCode, modifiers: store.hotkeyModifiers) {
                        toggleWindow()
                    }
                } else {
                    HotkeyManager.shared.unregister()
                }
            }
            .onChange(of: store.hotkeyKeyCode) { _, _ in
                guard store.hotkeyEnabled else { return }
                HotkeyManager.shared.register(keyCode: store.hotkeyKeyCode, modifiers: store.hotkeyModifiers) {
                    toggleWindow()
                }
            }
            .onChange(of: store.hotkeyModifiers) { _, _ in
                guard store.hotkeyEnabled else { return }
                HotkeyManager.shared.register(keyCode: store.hotkeyKeyCode, modifiers: store.hotkeyModifiers) {
                    toggleWindow()
                }
            }
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("外观")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("背景透明度")
                    Spacer()
                    Text("\(Int(store.backgroundOpacity * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Slider(value: $store.backgroundOpacity, in: 0.1...1.0, step: 0.05) {}
                    .tint(.blue)

                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "circle.righthalf.filled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(store.backgroundOpacity))
            .cornerRadius(10)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("关于")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("剪贴板历史")
                        .font(.body)
                    Text("版本 1.0")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(store.backgroundOpacity))
            .cornerRadius(10)
        }
    }

    private var lightBlueBackground: Color {
        Color(red: 0.94, green: 0.97, blue: 1.0)
    }

    private var lightBlueHeader: Color {
        Color(red: 0.85, green: 0.93, blue: 1.0)
    }

    private func setAutoStart(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("设置开机自启失败: \(error)")
            isAutoStartEnabled = SMAppService.mainApp.status == .enabled
        }
    }

    private func toggleWindow() {
        guard let window = NSApp.windows.first else { return }
        if window.isKeyWindow && window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
