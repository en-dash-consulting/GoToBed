import XCTest
@testable import GoToBedCore

/// The PRD's highest-risk behavior (NFR-rel-2 / AC-8): a time that elapses while
/// the Mac is asleep must be SKIPPED, never replayed on wake. The scheduler
/// achieves this by recomputing the next fire strictly after "now" on wake — so
/// these tests assert that recompute-forward never yields a past occurrence.
final class SleepSkipTests: XCTestCase {
    let cal = TestSupport.utcCalendar()
    lazy var calc = ScheduleCalculator(calendar: cal)

    func testMissedDuringSleepIsSkippedNotReplayed() throws {
        // Daily 09:00 schedule. The machine slept across 09:00 and woke at 09:05.
        let schedule = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "wake")
        let wakeTime = TestSupport.date(2025, 1, 6, 9, 5, calendar: cal)

        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: wakeTime))

        // The next fire must be in the future (Jan 7 09:00), not today's (Jan 6) 09:00.
        XCTAssertGreaterThan(fire, wakeTime)
        XCTAssertEqual(cal.component(.day, from: fire), 7)
        XCTAssertEqual(cal.component(.hour, from: fire), 9)
        XCTAssertEqual(cal.component(.minute, from: fire), 0)
    }

    func testWakeAfterMultiDaySleepArmsNextFutureOccurrence() throws {
        // Schedule active only Monday (2). Slept Sunday->Wednesday; wake Wednesday.
        let schedule = Schedule(hour: 9, minute: 0, weekdays: [2], message: "x")
        // 2025-01-08 is Wednesday.
        let wake = TestSupport.date(2025, 1, 8, 12, 0, calendar: cal)
        XCTAssertEqual(cal.component(.weekday, from: wake), 4)

        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: wake))
        // Monday 2025-01-13, not the missed Monday 2025-01-06.
        XCTAssertEqual(cal.component(.weekday, from: fire), 2)
        XCTAssertGreaterThan(fire, wake)
    }

    func testRecomputeAtExactFireBoundaryDoesNotRefire() throws {
        // Recomputing exactly at the fire instant must move to the next day,
        // not return the same instant (avoids an immediate double-fire).
        let schedule = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "x")
        let exactly = TestSupport.date(2025, 1, 6, 9, 0, 0, calendar: cal)
        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: exactly))
        XCTAssertGreaterThan(fire, exactly)
        XCTAssertEqual(cal.dateComponents([.day], from: exactly, to: fire).day!, 1)
    }
}
