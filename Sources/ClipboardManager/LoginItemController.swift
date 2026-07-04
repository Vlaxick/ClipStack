import Foundation
import ServiceManagement

@MainActor
final class LoginItemController: ObservableObject {
    @Published var launchesAtLogin: Bool {
        didSet {
            guard launchesAtLogin != oldValue else { return }
            updateLoginItem(enabled: launchesAtLogin)
        }
    }

    @Published private(set) var errorMessage: String?

    init() {
        launchesAtLogin = SMAppService.mainApp.status == .enabled
    }

    func refresh() {
        launchesAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func updateLoginItem(enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }

            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            launchesAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
