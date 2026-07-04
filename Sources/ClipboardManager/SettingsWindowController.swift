import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    private var window: NSWindow?
    private let loginItemController = LoginItemController()
    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    func showWindow() {
        if let window {
            loginItemController.refresh()
            window.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 650),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ClipStack"
        window.center()
        window.isReleasedWhenClosed = false
        window.contentMinSize = NSSize(width: 660, height: 600)
        window.contentViewController = NSHostingController(
            rootView: WelcomeSettingsView(
                loginItemController: loginItemController,
                settings: settings
            )
        )

        self.window = window
        window.makeKeyAndOrderFront(nil)
    }
}
