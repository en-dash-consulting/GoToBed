import XCTest
import AppKit
@testable import GoToBedKit
@testable import GoToBedCore

/// Tests for the inter-service wiring reproduced from AppEnvironment:
///   Store → SchedulerEngine → OverlayController
///
/// AppEnvironment's wiring is: `scheduler.onFire = { overlay.present($0) }`.
/// These tests verify that pattern end-to-end without instantiating the
/// AppEnvironment singleton.
@MainActor
final class InterServiceWiringTests: XCTestCase {
    private let cal = AppLayerTestHelpers.utcCalendar()

    private func makeStore() -> Store {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("gotobed-wiring-\(UUID().uuidString).json")
        return Store(persistence: AppStatePersistence(fileURL: url), autosaveEnabled: false)
    }

    // MARK: scheduler.onFire → overlay.present wiring

    /// When the scheduler fires, the onFire closure (wired the same way as
    /// AppEnvironment does) must call overlay.present(), setting isShowing = true
    /// when a display is available.
    func testSchedulerFireCallsOverlayPresent() async throws {
        let fireDate = AppLayerTestHelpers.date(2025, 6, 15, 11, 0, calendar: cal)
        let nowDate  = fireDate.addingTimeInterval(-0.05) // 50 ms before target minute

        let store    = makeStore()
        let overlay  = OverlayController()
        let scheduler = SchedulerEngine(store: store, calendar: cal, now: { nowDate })

        // Wire exactly as AppEnvironment does.
        scheduler.onFire = { [weak store, overlay] schedule in
            store?.delete(id: schedule.id) // prevent re-arm loop
            overlay.present(schedule)
        }

        let fired = store.add(Schedule(
            hour: cal.component(.hour, from: fireDate),
            minute: cal.component(.minute, from: fireDate),
            weekdays: WeekdayPreset.everyDay,
            message: "wiring-test"
        ))

        let exp = expectation(description: "onFire closure executed")
        let originalOnFire = scheduler.onFire
        scheduler.onFire = { [weak store, overlay] schedule in
            store?.delete(id: schedule.id)
            overlay.present(schedule)
            exp.fulfill()
        }

        scheduler.start()
        await fulfillment(of: [exp], timeout: 2.0)

        // If a display is available the overlay should now be showing.
        if NSScreen.main != nil {
            XCTAssertTrue(overlay.isShowing,
                "SchedulerEngine.onFire must trigger overlay.present() when a display is available")
            overlay.dismiss()
        }

        scheduler.stop()
    }

    /// Verifying the shutdown contract: stop() + dismiss() must leave the
    /// engine disarmed and the overlay hidden.
    func testShutdownSequenceDisarmsEngineAndHidesOverlay() throws {
        try XCTSkipIf(NSScreen.main == nil, "Overlay presentation requires a display")

        let now = AppLayerTestHelpers.date(2025, 1, 6, 9, 59, calendar: cal)
        let store    = makeStore()
        let overlay  = OverlayController()
        let scheduler = SchedulerEngine(store: store, calendar: cal, now: { now })

        store.add(Schedule(hour: 10, minute: 0, weekdays: WeekdayPreset.everyDay, message: "x"))
        scheduler.rearm()

        let schedule = Schedule(hour: 22, minute: 0, weekdays: WeekdayPreset.everyDay, message: "shutdown-test")
        overlay.present(schedule)

        XCTAssertNotNil(scheduler.nextScheduledFire, "Precondition: engine should be armed")
        XCTAssertTrue(overlay.isShowing, "Precondition: overlay should be visible")

        // Simulate AppEnvironment.shutdown()
        scheduler.stop()
        overlay.dismiss()

        XCTAssertNil(scheduler.nextScheduledFire, "stop() must disarm the engine")
        XCTAssertFalse(overlay.isShowing, "dismiss() must hide the overlay")
    }
}
