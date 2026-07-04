import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private let appSettings: AppSettings
    private let clipboardMonitor: ClipboardMonitor
    private let windowController: SettingsWindowController

    override init() {
        let settings = AppSettings()
        appSettings = settings
        clipboardMonitor = ClipboardMonitor(settings: settings)
        windowController = SettingsWindowController(settings: settings)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        configureStatusItem()
        configurePopover()
        clipboardMonitor.start()
        showOnboardingIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor.stop()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item

        guard let button = item.button else { return }
        if let image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipStack") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "📋"
        }

        button.action = #selector(togglePopover(_:))
        button.target = self
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 260, height: 410)
        popover.contentViewController = NSHostingController(
            rootView: ClipboardPopoverView(
                monitor: clipboardMonitor,
                onSelect: { [weak self] item in
                    self?.clipboardMonitor.copyToPasteboard(item)
                    self?.popover.performClose(nil)
                },
                onOpenSettings: { [weak self] in
                    self?.popover.performClose(nil)
                    self?.showSettingsWindow()
                }
            )
        )
    }

    private func showOnboardingIfNeeded() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        guard !hasCompletedOnboarding else { return }

        showSettingsWindow()
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
    }

    private func showSettingsWindow() {
        windowController.showWindow()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

private enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
}
