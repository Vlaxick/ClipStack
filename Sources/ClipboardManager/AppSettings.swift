import Foundation
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    @Published var captureText: Bool {
        didSet { UserDefaults.standard.set(captureText, forKey: Keys.captureText) }
    }

    @Published var captureImages: Bool {
        didSet { UserDefaults.standard.set(captureImages, forKey: Keys.captureImages) }
    }

    @Published var playSoundOnCapture: Bool {
        didSet { UserDefaults.standard.set(playSoundOnCapture, forKey: Keys.playSoundOnCapture) }
    }

    @Published var maxHistoryItems: Int {
        didSet { UserDefaults.standard.set(maxHistoryItems, forKey: Keys.maxHistoryItems) }
    }

    @Published var developerName: String {
        didSet { UserDefaults.standard.set(developerName, forKey: Keys.developerName) }
    }

    init() {
        let defaults = UserDefaults.standard
        captureText = defaults.object(forKey: Keys.captureText) as? Bool ?? true
        captureImages = defaults.object(forKey: Keys.captureImages) as? Bool ?? true
        playSoundOnCapture = defaults.object(forKey: Keys.playSoundOnCapture) as? Bool ?? false
        maxHistoryItems = defaults.object(forKey: Keys.maxHistoryItems) as? Int ?? 10
        developerName = defaults.string(forKey: Keys.developerName) ?? "Твій Mac Studio"
    }
}

private enum Keys {
    static let captureText = "captureText"
    static let captureImages = "captureImages"
    static let playSoundOnCapture = "playSoundOnCapture"
    static let maxHistoryItems = "maxHistoryItems"
    static let developerName = "developerName"
}
