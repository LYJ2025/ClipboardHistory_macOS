import SwiftUI
import AppKit

struct ContentView: View {
    let onOpenSettings: () -> Void

    @State private var store = ClipboardStore.shared
    @State private var itemToDelete: ClipboardItem?

    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchBar
            Divider()
            listView
        }
        .frame(minWidth: 360, minHeight: 500)
        .background(.ultraThinMaterial)
        .background(lightBlueBackground.opacity(store.backgroundOpacity))
        .confirmationDialog("确认删除？", isPresented: Binding(
            get: { itemToDelete != nil },
            set: { if !$0 { itemToDelete = nil } }
        ), actions: {
            Button("删除", role: .destructive) {
                if let item = itemToDelete {
                    store.delete(item: item)
                }
                itemToDelete = nil
            }
            Button("取消", role: .cancel) {
                itemToDelete = nil
            }
        }, message: {
            Text("删除后将无法恢复。")
        })
        .environment(store)
    }

    private var headerView: some View {
        ZStack {
            Text("剪贴板历史")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            HStack {
                Spacer()
                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .background(lightBlueHeader.opacity(store.backgroundOpacity))
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("搜索历史记录", text: $store.searchText)
                .textFieldStyle(.plain)
            if !store.searchText.isEmpty {
                Button(action: { store.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(store.backgroundOpacity))
        .cornerRadius(8)
        .padding()
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.filteredItems) { item in
                    HistoryCard(item: item, store: store) {
                        itemToDelete = item
                    }
                }
            }
            .padding()
        }
    }

    private var lightBlueBackground: Color {
        Color(red: 0.94, green: 0.97, blue: 1.0)
    }

    private var lightBlueHeader: Color {
        Color(red: 0.85, green: 0.93, blue: 1.0)
    }
}

struct HistoryCard: View {
    let item: ClipboardItem
    let store: ClipboardStore
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                Text(item.displayDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                cardContent
            }

            HStack {
                Spacer()
                Button(action: { store.togglePin(item: item) }) {
                    Image(systemName: item.isPinned ? "pin.slash" : "pin")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.borderless)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(store.backgroundOpacity))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            store.copyToClipboard(item: item)
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        switch item.contentType {
        case .text:
            Text(item.textContent ?? "")
                .font(.body)
                .lineLimit(4)
                .foregroundStyle(.primary)
        case .image:
            if let image = store.image(for: item) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                    .cornerRadius(6)
            } else {
                Text("图片无法加载")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
