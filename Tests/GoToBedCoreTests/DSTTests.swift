import XCTest
@testable import GoToBedCore

/// NFR-rel-3: scheduling stays correct across DST transitions because schedules
/// are interpreted in current local wall-clock time.
final class DSTTests: XCTestCase {
    let cal = TestSupport.newYorkCalendar()
    lazy var calc = ScheduleCalculator(calendar: cal)

    func testNoonScheduleStaysAtLocalNoonAcrossSpringForward() throws {
        // US spring-forward 2025: 2025-03-09. A daily noon schedule the evening
        // before should next fire at local noon on the 9th.
        let saturdayEvening = TestSupport.date(2025, 3, 8, 20, 0, calendar: cal)
        let schedule = Schedule(hour: 12, minute: 0, weekdays: WeekdayPreset.everyDay, message: "noon")
        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: saturdayEvening))
        XCTAssertEqual(cal.component(.hour, from: fire), 12)
        XCTAssertEqual(cal.component(.minute, from: fire), 0)
        XCTAssertEqual(cal.component(.day, from: fire), 9)
    }

    func testNonexistentWallTimeDuringSpringForwardResolvesForward() throws {
        // 02:30 does not exist on 2025-03-09 (clocks jump 02:00 -> 03:00).
        // The calculator must still return a valid future date, not nil/past.
        let before = TestSupport.date(2025, 3, 9, 1, 0, calendar: cal)
        let schedule = Schedule(hour: 2, minute: 30, weekdays: WeekdayPreset.everyDay, message: "x")
        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: before))
        XCTAssertGreaterThan(fire, before)
    }

    func testNoonScheduleStaysAtLocalNoonAcrossFallBack() throws {
        // US fall-back 2025: 2025-11-02.
        let saturdayEvening = TestSupport.date(2025, 11, 1, 20, 0, calendar: cal)
        let schedule = Schedule(hour: 12, minute: 0, weekdays: WeekdayPreset.everyDay, message: "noon")
        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: saturdayEvening))
        XCTAssertEqual(cal.component(.hour, from: fire), 12)
        XCTAssertEqual(cal.component(.day, from: fire), 2)
    }
}
