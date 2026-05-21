import Foundation
import Combine

/// The single observable source of truth for app state (PRD §5.2).
///
/// UI and the scheduler both observe `$state` / `objectWillChange`. All
/// mutations go through here and are persisted immediately (when autosave is
/// enabled). New schedules inherit the app-wide default appearance (FR-15).
public final class Store: ObservableObject {
    @Published public private(set) var state: AppState

    private let persistence: AppStatePersistence
    private let autosaveEnabled: Bool

    public init(
        persistence: AppStatePersistence = AppStatePersistence(),
        autosaveEnabled: Bool = true
    ) {
        self.persistence = persistence
        self.autosaveEnabled = autosaveEnabled
        self.state = persistence.load()
    }

    // MARK: Read

    public var schedules: [Schedule] { state.schedules }
    public var defaultAppearance: AppearanceSettings { state.defaultAppearance }
    public var launchAtLogin: Bool { state.launchAtLogin }

    public func schedule(id: UUID) -> Schedule? {
        state.schedules.first { $0.id == id }
    }

    // MARK: Schedule CRUD

    /// Build (but do not insert) a new schedule seeded from the current default
    /// appearance, so the editor opens pre-populated (FR-15).
    public func makeSchedule(
        hour: Int,
        minute: Int,
        weekdays: Set<Int>,
        message: String,
        dismissMode: DismissMode = .auto(seconds: DismissMode.defaultAutoSeconds)
    ) -> Schedule {
        Schedule(
            hour: hour,
            minute: minute,
            weekdays: weekdays,
            message: message,
            dismissMode: dismissMode,
            appearance: state.defaultAppearance
        )
    }

    /// Insert a schedule. Invalid schedules are coerced into range first.
    @discardableResult
    public func add(_ schedule: Schedule) -> Schedule {
        let clean = schedule.sanitized()
        mutate { $0.schedules.append(clean) }
        return clean
    }

    /// Replace an existing schedule (matched by id) with an updated, sanitized copy.
    public func update(_ schedule: Schedule) {
        let clean = schedule.sanitized()
        mutate { state in
            guard let idx = state.schedules.firstIndex(where: { $0.id == clean.id }) else { return }
            state.schedules[idx] = clean
        }
    }

    public func delete(id: UUID) {
        mutate { $0.schedules.removeAll { $0.id == id } }
    }

    public func setEnabled(_ enabled: Bool, id: UUID) {
        mutate { state in
            guard let idx = state.schedules.firstIndex(where: { $0.id == id }) else { return }
            state.schedules[idx].isEnabled = enabled
        }
    }

    // MARK: Appearance & app-wide settings

    /// Edit the app-wide default appearance. Does not retroactively change
    /// existing schedules (FR-15).
    public func updateDefaultAppearance(_ appearance: AppearanceSettings) {
        mutate { $0.defaultAppearance = appearance }
    }

    public func setLaunchAtLogin(_ enabled: Bool) {
        mutate { $0.launchAtLogin = enabled }
    }

    // MARK: Internals

    private func mutate(_ block: (inout AppState) -> Void) {
        block(&state)
        if autosaveEnabled {
            do {
                try persistence.save(state)
            } catch {
                Log.persistence.error("Failed to persist state: \(String(describing: error), privacy: .public)")
            }
        }
    }
}
