import Foundation
import ServiceManagement
import GoToBedCore

/// Thin wrapper over `SMAppService` for the launch-at-login toggle (PRD FR-20).
/// Off by default; the registered state is the system's source of truth.
enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Register/unregister the main app as a login item. Throws if the system
    /// rejects the change (e.g. unsigned during local dev) so callers can keep
    /// the UI toggle in sync with reality rather than silently lying.
    static func set(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
        Log.lifecycle.info("Launch at login set to \(enabled, privacy: .public).")
    }
}
