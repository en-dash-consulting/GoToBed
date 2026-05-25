import XCTest
@testable import GoToBedKit
@testable import GoToBedCore

/// Unit tests for SchedulerEngine: timer arming, fire callbacks, and stop/rearm
/// lifecycle. SchedulerEngine is @MainActor so the whole test class is isolated
/// to the main actor, which lets timer-firing tests use await to yield the run
/// loop without extra MainActor.run wrappers.
@MainActor
final class SchedulerEngineTests: XCTestCase {
    private let cal = AppLayerTestHelpers.utcCalendar()

    /// Build an isolated Store backed by a temp file so tests don't touch
    /// ~/Library/Application Support/GoToBed/state.json.
    private func makeStore() -> Store {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("gotobed-test-\(UUID().uuidString).json")
        return Store(persistence: AppStatePersistence(fileURL: url), autosaveEnabled: false)
    }

    // MARK: rearm() state

    func testRearmWithNoSchedulesArmsNoTimer() {
        let engine = SchedulerEngine(store: makeStore(), calendar: cal)
        engine.rearm()
        XCTAssertNil(engine.nextScheduledFire, "Empty store must leave timer unarmed")
    }

    func testRearmWithEnabledScheduleSetsNextFireDate() {
        // "now" is 09:59; schedule fires at 10:00.
        let now = AppLayerTestHelpers.date(2025, 1, 6, 9, 59, calendar: cal)
        let store = makeStore()
        store.add(Schedule(hour: 10, minute: 0, weekdays: WeekdayPreset.everyDay, message: "wake"))

        let engine = SchedulerEngine(store: store, calendar: cal, now: { now })
        engine.rearm()

        let fire = engine.nextScheduledFire
        XCTAssertNotNil(fire, "Enabled schedule should arm a timer")
        XCTAssertEqual(cal.component(.hour, from: fire!), 10)
        XCTAssertEqual(cal.component(.minute, from: fire!), 0)
    }

    func testRearmWithDisabledScheduleArmsNoTimer() {
        let now = AppLayerTestHelpers.date(2025, 1, 6, 9, 59, calendar: cal)
        let store = makeStore()
        var schedule = Schedule(hour: 10, minute: 0, weekdays: WeekdayPreset.everyDay, message: "off")
        schedule.isEnabled = false
        store.add(schedule)

        let engine = SchedulerEngine(store: store, calendar: cal, now: { now })
        engine.rearm()

        XCTAssertNil(engine.nextScheduledFire, "Disabled schedule must not arm a timer")
    }

    func testRearmPicksSoonestOfMultipleSchedules() {
        let now = AppLayerTestHelpers.date(2025, 1, 6, 7, 0, calendar: cal)
        let store = makeStore()
        // Two schedules at 09:00 and 10:00; rearm should pick 09:00.
        store.add(Schedule(hour: 10, minute: 0, weekdays: WeekdayPreset.everyDay, message: "later"))
        store.add(Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "sooner"))

        let engine = SchedulerEngine(store: store, calendar: cal, now: { now })
        engine.rearm()

        let fire = engine.nextScheduledFire
        XCTAssertNotNil(fire)
        XCTAssertEqual(cal.component(.hour, from: fire!), 9,
                       "Engine should arm to the soonest schedule, not the first added")
    }

    // MARK: stop()

    func testStopClearsArmedFireDate() {
        let now = AppLayerTestHelpers.date(2025, 1, 6, 9, 59, calendar: cal)
        let store = makeStore()
        store.add(Schedule(hour: 10, minute: 0, weekdays: WeekdayPreset.everyDay, message: "x"))

        let engine = SchedulerEngine(store: store, calendar: cal, now: { now })
        engine.rearm()
        XCTAssertNotNil(engine.nextScheduledFire, "Precondition: timer should be armed")

        engine.stop()
        XCTAssertNil(engine.nextScheduledFire, "stop() must clear the armed fire date")
    }

    func testStopIsIdempotent() {
        let engine = SchedulerEngine(store: makeStore(), calendar: cal)
        // Two consecutive stops must not crash.
        engine.stop()
        engine.stop()
    }

    // MARK: onFire callback (real timer, sub-100 ms)

    /// The engine must call onFire when the real Timer elapses.
    ///
    /// Design: "now" is injected as a fixed instant 50 ms before the target
    /// hour:minute. The computed timer interval is therefore ~50 ms. After
    /// onFire fires, the schedule is deleted from the store so the subsequent
    /// rearm() finds nothing and does not loop.
    func testOnFireCallbackCalledWhenTimerElapses() async throws {
        let fireDate = AppLayerTestHelpers.date(2025, 6, 15, 10, 0, calendar: cal)
        let nowDate  = fireDate.addingTimeInterval(-0.05) // 50 ms before target minute

        let store = makeStore()
        let fired = store.add(Schedule(
            hour: cal.component(.hour, from: fireDate),
            minute: cal.component(.minute, from: fireDate),
            weekdays: WeekdayPreset.everyDay,
            message: "fire-test"
        ))

        var receivedSchedule: Schedule?
        let exp = expectation(description: "onFire called")

        let engine = SchedulerEngine(store: store, calendar: cal, now: { nowDate })
        engine.onFire = { [weak store] schedule in
            // Delete the schedule so the post-fire rearm() finds nothing and
            // the timer does not immediately re-arm.
            store?.delete(id: schedule.id)
            receivedSchedule = schedule
            exp.fulfill()
        }
        engine.start()

        await fulfillment(of: [exp], timeout: 2.0)

        XCTAssertEqual(receivedSchedule?.message, "fire-test")
        engine.stop()
    }

    /// A schedule disabled between arming and firing must not trigger onFire.
    func testFireSkipsScheduleDisabledAfterArming() async throws {
        let fireDate = AppLayerTestHelpers.date(2025, 6, 15, 10, 0, calendar: cal)
        // 300 ms before fire — wide enough to disable the schedule before the timer fires.
        let nowDate  = fireDate.addingTimeInterval(-0.3)

        let store = makeStore()
        let s = store.add(Schedule(
            hour: cal.component(.hour, from: fireDate),
            minute: cal.component(.minute, from: fireDate),
            weekdays: WeekdayPreset.everyDay,
            message: "should-skip"
        ))

        var callbackFired = false
        let engine = SchedulerEngine(store: store, calendar: cal, now: { nowDate })
        engine.onFire = { _ in callbackFired = true }
        engine.start()

        // Disable immediately after starting (well within the 300 ms window).
        store.setEnabled(false, id: s.id)

        // Wait 700 ms — longer than the timer interval — then verify no callback.
        try await Task.sleep(nanoseconds: 700_000_000)

        XCTAssertFalse(callbackFired, "Disabled schedule must not trigger onFire")
        engine.stop()
    }
}
