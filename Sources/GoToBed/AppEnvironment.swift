import AppKit
import GoToBedCore

/// Composition root: wires the Store -> SchedulerEngine -> OverlayController
/// graph and exposes high-level actions (preview, launch-at-login) to the UI.
@MainActor
final class AppEnvironment: ObservableObject {
    static let shared = AppEnvironment()

    let store: Store
    let scheduler: SchedulerEngine
    let overlay: OverlayController

    /// Lazily created so it can reference `self` (the env) for window hosting.
    private(set) lazy var settingsWindow = SettingsWindowController(env: self)

    private init() {
        store = Store()
        overlay = OverlayController()
        scheduler = SchedulerEngine(store: store)

        scheduler.onFire = { [overlay] schedule in
            overlay.present(schedule)
        }
    }

    /// Open the settings/editor window (managed directly via AppKit).
    func openSettings() {
        settingsWindow.show()
    }

    /// Offline-preserving update check: open the latest releases page in the
    /// default browser. Handing off a URL needs no network entitlement, so the
    /// app's zero-network guarantee (NFR-priv-1) is preserved.
    func checkForUpdates() {
        NSWorkspace.shared.open(AppInfo.releasesURL)
    }

    /// Add a new schedule seeded from defaults, then open the editor to it.
    func addScheduleAndEdit() {
        store.add(store.makeSchedule(
            hour: 22, minute: 30, weekdays: WeekdayPreset.everyDay,
            message: "Time to wind down. Go to bed."
        ))
        openSettings()
    }

    /// Begin scheduling. Called once from the app delegate after launch.
    func start() {
        scheduler.start()
        Log.lifecycle.info("GoToBed started with \(self.store.schedules.count, privacy: .public) schedule(s).")
    }

    /// Tear down scheduling and any visible overlay (FR-21: quitting stops all
    /// scheduling, no daemon persists).
    func shutdown() {
        scheduler.stop()
        overlay.dismiss()
    }

    /// Show `schedule`'s overlay immediately, without affecting scheduling
    /// (PRD "preview overlay" action). Falls back to the first schedule.
    func previewOverlay(_ schedule: Schedule? = nil) {
        let target = schedule ?? store.schedules.first ?? Schedule(
            hour: 0, minute: 0, weekdays: WeekdayPreset.everyDay,
            message: "Preview", appearance: store.defaultAppearance
        )
        overlay.present(target)
    }

    // MARK: Launch at login

    var launchAtLoginEnabled: Bool { LaunchAtLogin.isEnabled }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try LaunchAtLogin.set(enabled)
            store.setLaunchAtLogin(enabled)
        } catch {
            Log.lifecycle.error("Failed to set launch at login: \(String(describing: error), privacy: .public)")
        }
    }
}
