import AppKit
import SwiftUI

struct ClipboardPopoverView: View {
    @ObservedObject var monitor: ClipboardMonitor
    let onSelect: (ClipboardItem) -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Clips")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 8)

            Divider()

            ScrollView {
                LazyVStack(spacing: 2) {
                    if monitor.items.isEmpty {
                        EmptyHistoryView()
                    } else {
                        ForEach(monitor.items) { item in
                            ClipboardRow(item: item) {
                                onSelect(item)
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            .frame(maxHeight: 285)

            Divider()

            VStack(spacing: 4) {
                FooterButton(title: "About / Settings", icon: "gearshape", role: .primary) {
                    onOpenSettings()
                }

                FooterButton(title: "Clear History", icon: "trash", role: .destructive) {
                    monitor.clearHistory()
                }
                .disabled(monitor.items.isEmpty)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .frame(width: 260)
        .background(.regularMaterial)
    }
}

private struct ClipboardRow: View {
    let item: ClipboardItem
    let onClick: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 10) {
                Image(systemName: item.type == .text ? "doc.text" : "photo")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                rowContent

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
        .onHover { isHovered = $0 }
    }

    @ViewBuilder
    private var rowContent: some View {
        switch item.type {
        case .text:
            Text(item.text?.previewText ?? "")
                .font(.system(size: 13))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        case .image:
            HStack(spacing: 8) {
                if let image = item.image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                }

                Text("Image")
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)
            }
        }
    }
}

private struct FooterButton: View {
    enum Role {
        case primary
        case destructive
    }

    let title: String
    let icon: String
    let role: Role
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .frame(width: 16)
                Text(title)
                Spacer()
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.45)
        .onHover { isHovered = $0 && isEnabled }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return .secondary }
        return role == .destructive ? .red : .primary
    }
}

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "clipboard")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
            Text("No clips yet")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 42)
    }
}
