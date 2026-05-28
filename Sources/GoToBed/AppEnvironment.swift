import AppKit
import Combine
import GoToBedCore

/// Composition root: wires the Store -> SchedulerEngine -> OverlayController
/// graph and exposes high-level actions (preview, launch-at-login) to the UI.
///
/// All write operations on the domain model (Store mutations) flow through
/// coordinator methods on this class so settings-ui views hold no direct write
/// dependency on Store — only AppEnvironment decides when and how the model
/// changes.
@MainActor
public final class AppEnvironment: ObservableObject {
    public static let shared = AppEnvironment()

    public let store: Store
    let scheduler: SchedulerEngine
    let overlay: OverlayController

    /// Lazily created so it can reference `self` (the env) for window hosting.
    private(set) lazy var settingsWindow = SettingsWindowController(env: self)

    /// Relay Store mutations to env.objectWillChange so views that observe only
    /// this object (e.g. MenuContent) still rebuild when schedules change.
    private var storeCancellable: AnyCancellable?

    private init() {
        store = Store()
        let overlay = OverlayController()
        self.overlay = overlay

        // The scheduler → overlay edge is intentionally wired via closure
        // injection rather than a direct import. Scheduler must not `import`
        // the Overlay layer; doing so would reintroduce an architectural cycle
        // (overlay depends on Schedule types from the domain, scheduler depends
        // on overlay to present → cycle). AppEnvironment is the only place that
        // knows about both, so it crosses the boundary here and nowhere else.
        // If you find yourself wanting to replace this closure with a direct
        // `scheduler.overlay = ...` reference, stop and read this comment.
        scheduler = SchedulerEngine(store: store) { schedule in
            overlay.present(schedule)
        }

        storeCancellable = store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: Window management

    /// Open the settings/editor window (managed directly via AppKit).
    public func openSettings() {
        settingsWindow.show()
    }

    // MARK: Schedule coordinator (write proxy for settings-ui)

    /// Build (but do not insert) a new schedule seeded from the current default
    /// appearance, so the editor opens pre-populated (FR-15).
    func makeSchedule(
        hour: Int,
        minute: Int,
        weekdays: Set<Int>,
        message: String,
        dismissMode: DismissMode = .auto(seconds: DismissMode.defaultAutoSeconds)
    ) -> Schedule {
        store.makeSchedule(
            hour: hour, minute: minute, weekdays: weekdays,
            message: message, dismissMode: dismissMode
        )
    }

    /// Insert a schedule. Invalid schedules are coerced into range first.
    @discardableResult
    func addSchedule(_ schedule: Schedule) -> Schedule {
        store.add(schedule)
    }

    /// Replace an existing schedule (matched by id) with an updated, sanitized copy.
    func updateSchedule(_ schedule: Schedule) {
        store.update(schedule)
    }

    /// Delete a schedule by id.
    func deleteSchedule(id: UUID) {
        store.delete(id: id)
    }

    /// Toggle the enabled state of a schedule.
    func setScheduleEnabled(_ enabled: Bool, id: UUID) {
        store.setEnabled(enabled, id: id)
    }

    /// Update the app-wide default appearance.
    func updateDefaultAppearance(_ appearance: AppearanceSettings) {
        store.updateDefaultAppearance(appearance)
    }

    // MARK: Menu-bar view model

    /// Pre-computed display items for the menu-bar popover.
    ///
    /// MenuContent reads this instead of observing Store directly, so the menu
    /// view has no direct domain dependency.
    var scheduleItems: [ScheduleDisplayItem] {
        store.schedules.map { schedule in
            ScheduleDisplayItem(
                id: schedule.id,
                timeString: ScheduleFormatting.timeString(schedule),
                subtitle: ScheduleFormatting.daysAndMessage(schedule),
                isEnabled: schedule.isEnabled
            )
        }
    }

    // MARK: Misc actions

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
    public func start() {
        scheduler.start()
        Log.lifecycle.info("GoToBed started with \(self.store.schedules.count, privacy: .public) schedule(s).")
    }

    /// Tear down scheduling and any visible overlay (FR-21: quitting stops all
    /// scheduling, no daemon persists).
    public func shutdown() {
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
