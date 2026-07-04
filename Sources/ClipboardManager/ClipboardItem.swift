import AppKit

enum ClipboardItemType: Equatable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Equatable {
    let id = UUID()
    let type: ClipboardItemType
    let text: String?
    let image: NSImage?

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.text, .text):
            return lhs.text == rhs.text
        case (.image, .image):
            return lhs.image?.stablePNGData == rhs.image?.stablePNGData
        default:
            return false
        }
    }
}

extension String {
    var previewText: String {
        let collapsed = replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        guard collapsed.count > 50 else { return collapsed }
        return String(collapsed.prefix(50))
    }
}

extension NSImage {
    var stablePNGData: Data? {
        guard
            let tiffData = tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData)
        else {
            return nil
        }

        return bitmap.representation(using: .png, properties: [:])
    }
}
