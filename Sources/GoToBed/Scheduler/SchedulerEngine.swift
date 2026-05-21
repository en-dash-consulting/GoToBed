import Foundation
import AppKit
import Combine
import GoToBedCore

/// Drives schedule firing: keeps a single coalesced timer armed to the soonest
/// upcoming occurrence and emits a fire event when it elapses (PRD §5.5).
///
/// Reliability behaviors:
/// - **Coalesced timer (FR §5.5):** one timer to the next event across all
///   schedules, not N long-lived timers.
/// - **Sleep skip (NFR-rel-2):** `Timer` does not fire while asleep; on wake we
///   recompute strictly forward from now, so an occurrence missed during sleep
///   is skipped (logged) rather than replayed.
/// - **Clock/timezone/DST (NFR-rel-3):** recompute on system clock and timezone
///   change notifications.
@MainActor
final class SchedulerEngine {
    /// Called on the main thread when a schedule fires.
    var onFire: ((Schedule) -> Void)?

    private let store: Store
    private let calculator: ScheduleCalculator
    private let now: () -> Date

    private var timer: Timer?
    private var armedFireDate: Date?
    private var cancellables = Set<AnyCancellable>()
    private var observers: [NSObjectProtocol] = []

    init(
        store: Store,
        calendar: Calendar = .current,
        now: @escaping () -> Date = { Date() }
    ) {
        self.store = store
        self.calculator = ScheduleCalculator(calendar: calendar)
        self.now = now
    }

    func start() {
        // Re-arm whenever schedules change.
        store.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                // objectWillChange fires *before* the change is applied; defer to
                // the next main-loop turn so we recompute against the new state.
                DispatchQueue.main.async { MainActor.assumeIsolated { self?.rearm() } }
            }
            .store(in: &cancellables)

        let center = NSWorkspace.shared.notificationCenter
        observers.append(center.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Log.scheduler.info("Woke from sleep; recomputing fire dates forward from now (missed occurrences skipped).")
            MainActor.assumeIsolated { self?.rearm() }
        })

        let dnc = NotificationCenter.default
        for name in [Notification.Name.NSSystemClockDidChange, .NSSystemTimeZoneDidChange] {
            observers.append(dnc.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Log.scheduler.info("System clock/timezone changed; recomputing fire dates.")
                MainActor.assumeIsolated { self?.rearm() }
            })
        }

        rearm()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        armedFireDate = nil
        cancellables.removeAll()
        let ws = NSWorkspace.shared.notificationCenter
        let dnc = NotificationCenter.default
        for o in observers { ws.removeObserver(o); dnc.removeObserver(o) }
        observers.removeAll()
        Log.scheduler.info("Scheduler stopped.")
    }

    /// The currently armed next-fire date (for diagnostics/tests).
    var nextScheduledFire: Date? { armedFireDate }

    /// Recompute the soonest fire and (re)arm a single timer. Idempotent.
    func rearm() {
        timer?.invalidate()
        timer = nil
        armedFireDate = nil

        guard let next = calculator.nextFire(in: store.schedules, after: now()) else {
            Log.scheduler.debug("No enabled schedules; timer idle.")
            return
        }

        let interval = max(0, next.date.timeIntervalSince(now()))
        let fireID = next.schedule.id
        armedFireDate = next.date

        let t = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.fire(scheduleID: fireID) }
        }
        // Tolerance keeps us comfortably within the ±2s budget while letting the
        // OS coalesce wakeups for low idle CPU.
        t.tolerance = 0.5
        RunLoop.main.add(t, forMode: .common)
        timer = t
        Log.scheduler.debug("Armed timer for \(next.date, privacy: .public) (in \(interval, privacy: .public)s).")
    }

    private func fire(scheduleID: UUID) {
        armedFireDate = nil
        timer = nil
        // Re-read the schedule: it may have been edited/disabled since arming.
        guard let schedule = store.schedule(id: scheduleID), schedule.isEnabled else {
            Log.scheduler.info("Scheduled fire skipped; schedule no longer active.")
            rearm()
            return
        }
        Log.scheduler.info("Schedule fired: \(schedule.message, privacy: .private).")
        onFire?(schedule)
        rearm()
    }
}
