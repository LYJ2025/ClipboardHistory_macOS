import SwiftUI

struct MainView: View {
    @State private var selectedTab: AppTab = .history

    var body: some View {
        ZStack {
            switch selectedTab {
            case .history:
                ContentView {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .settings
                    }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            case .settings:
                SettingsView {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .history
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
}

enum AppTab {
    case history
    case settings
}
