import XCTest
import AppKit
@testable import GoToBedKit
@testable import GoToBedCore

/// Unit tests for OverlayController state management.
///
/// Tests that require a physical display (present/dismiss lifecycle) are
/// guarded with XCTSkipIf so they remain green in headless CI environments.
@MainActor
final class OverlayControllerTests: XCTestCase {

    // MARK: Initial state

    func testInitiallyNotShowing() {
        let controller = OverlayController()
        XCTAssertFalse(controller.isShowing, "A fresh OverlayController must report isShowing = false")
    }

    // MARK: Dismiss when nothing is showing

    func testDismissWhenNotShowingDoesNotCrash() {
        let controller = OverlayController()
        // Calling dismiss() with no active overlay must be a silent no-op.
        controller.dismiss()
        XCTAssertFalse(controller.isShowing)
    }

    func testMultipleDismissCallsAreIdempotent() {
        let controller = OverlayController()
        controller.dismiss()
        controller.dismiss()
        XCTAssertFalse(controller.isShowing)
    }

    // MARK: Present / dismiss lifecycle (requires a display)

    func testPresentSetsIsShowingAndDismissClearsIt() throws {
        try XCTSkipIf(NSScreen.main == nil, "Overlay presentation requires a display")

        let controller = OverlayController()
        let schedule = Schedule(
            hour: 22, minute: 0,
            weekdays: WeekdayPreset.everyDay,
            message: "Test overlay"
        )

        controller.present(schedule)
        XCTAssertTrue(controller.isShowing, "present() must set isShowing = true")

        controller.dismiss()
        // Note: dismiss uses an animation; the window is torn down synchronously
        // in the non-animated path (reduceMotion). We check the in-memory flag.
        XCTAssertFalse(controller.isShowing, "dismiss() must set isShowing = false immediately")
    }

    func testPresentReplacesExistingOverlay() throws {
        try XCTSkipIf(NSScreen.main == nil, "Overlay presentation requires a display")

        let controller = OverlayController()
        let s1 = Schedule(hour: 22, minute: 0, weekdays: WeekdayPreset.everyDay, message: "first")
        let s2 = Schedule(hour: 22, minute: 30, weekdays: WeekdayPreset.everyDay, message: "second")

        controller.present(s1)
        XCTAssertTrue(controller.isShowing)

        // A second present() must replace the first without leaving two overlays.
        controller.present(s2)
        XCTAssertTrue(controller.isShowing, "Overlay should still be showing after replacement")

        controller.dismiss()
    }
}
