import AppKit
import SwiftUI

@MainActor
final class ClipboardMonitor: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []

    private let settings: AppSettings
    private let pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var lastChangeCount: Int

    init(settings: AppSettings) {
        self.settings = settings
        lastChangeCount = pasteboard.changeCount
    }

    func start() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPasteboard()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func clearHistory() {
        items.removeAll()
    }

    func copyToPasteboard(_ item: ClipboardItem) {
        pasteboard.clearContents()

        switch item.type {
        case .text:
            if let text = item.text {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let image = item.image {
                pasteboard.writeObjects([image])
            }
        }

        lastChangeCount = pasteboard.changeCount
    }

    private func checkPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if settings.captureText, let text = pasteboard.string(forType: .string), !text.isEmpty {
            addOrPromote(ClipboardItem(type: .text, text: text, image: nil))
            return
        }

        if settings.captureImages, let image = readImageFromPasteboard() {
            addOrPromote(ClipboardItem(type: .image, text: nil, image: image))
        }
    }

    private func addOrPromote(_ item: ClipboardItem) {
        if let existingIndex = items.firstIndex(of: item) {
            let existing = items.remove(at: existingIndex)
            items.insert(existing, at: 0)
        } else {
            items.insert(item, at: 0)
        }

        if settings.playSoundOnCapture {
            NSSound(named: "Pop")?.play()
        }

        if items.count > settings.maxHistoryItems {
            items.removeLast(items.count - settings.maxHistoryItems)
        }
    }

    private func readImageFromPasteboard() -> NSImage? {
        if let data = pasteboard.data(forType: .png), let image = NSImage(data: data) {
            return image
        }

        if let data = pasteboard.data(forType: .tiff), let image = NSImage(data: data) {
            return image
        }

        if let image = NSImage(pasteboard: pasteboard) {
            return image
        }

        return nil
    }
}
