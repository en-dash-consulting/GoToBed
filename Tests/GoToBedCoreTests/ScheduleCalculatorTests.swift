import XCTest
@testable import GoToBedCore

final class ScheduleCalculatorTests: XCTestCase {
    let cal = TestSupport.utcCalendar()
    lazy var calc = ScheduleCalculator(calendar: cal)

    // FR-3: fires on its active day at its configured time.
    func testNextFireMatchesConfiguredWeekdayAndTime() throws {
        // 2025-01-06 is a Monday (weekday 2). Schedule for Monday 22:30.
        let monday = TestSupport.date(2025, 1, 6, 8, 0, calendar: cal)
        XCTAssertEqual(cal.component(.weekday, from: monday), 2)

        let schedule = Schedule(hour: 22, minute: 30, weekdays: [2], message: "Bed")
        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: monday))

        XCTAssertEqual(cal.component(.weekday, from: fire), 2)
        XCTAssertEqual(cal.component(.hour, from: fire), 22)
        XCTAssertEqual(cal.component(.minute, from: fire), 30)
        XCTAssertGreaterThan(fire, monday)
    }

    // FR-4: if today's time already passed, fire at the NEXT active occurrence,
    // never immediately / in the past.
    func testPassedTodayFiresNextWeek() throws {
        let monday = TestSupport.date(2025, 1, 6, 23, 0, calendar: cal) // after 22:30
        let schedule = Schedule(hour: 22, minute: 30, weekdays: [2], message: "Bed")
        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: monday))

        XCTAssertGreaterThan(fire, monday)
        // Only Monday is active, so the next fire is the following Monday (Jan 13).
        XCTAssertEqual(cal.component(.weekday, from: fire), 2)
        XCTAssertEqual(cal.component(.month, from: fire), 1)
        XCTAssertEqual(cal.component(.day, from: fire), 13)
    }

    // FR-4: created on a non-active day -> next active day, not today.
    func testNonActiveDayFiresOnNextActiveDay() throws {
        // Wednesday 2025-01-08 (weekday 4). Schedule active only Friday (6).
        let wednesday = TestSupport.date(2025, 1, 8, 10, 0, calendar: cal)
        XCTAssertEqual(cal.component(.weekday, from: wednesday), 4)
        let schedule = Schedule(hour: 9, minute: 0, weekdays: [6], message: "x")
        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: wednesday))
        XCTAssertEqual(cal.component(.weekday, from: fire), 6)
        XCTAssertGreaterThan(fire, wednesday)
    }

    // FR-5: disabled schedules never produce a fire date.
    func testDisabledScheduleProducesNoFire() {
        var schedule = Schedule(hour: 9, minute: 0, weekdays: [2], message: "x")
        schedule.isEnabled = false
        XCTAssertNil(calc.nextFireDate(for: schedule, after: Date()))
    }

    func testEmptyWeekdaysProducesNoFire() {
        let schedule = Schedule(hour: 9, minute: 0, weekdays: [], message: "x")
        XCTAssertNil(calc.nextFireDate(for: schedule, after: Date()))
    }

    func testWeekdayPresetEveryDayFiresWithin24h() throws {
        let now = TestSupport.date(2025, 1, 6, 10, 0, calendar: cal)
        let schedule = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "x")
        let fire = try XCTUnwrap(calc.nextFireDate(for: schedule, after: now))
        // 09:00 already passed today (Jan 6), so tomorrow (Jan 7) at 09:00.
        XCTAssertEqual(cal.component(.day, from: fire), 7)
        XCTAssertEqual(cal.component(.hour, from: fire), 9)
    }

    // nextFire across schedules picks the soonest.
    func testNextFirePicksSoonestAcrossSchedules() throws {
        let now = TestSupport.date(2025, 1, 6, 8, 0, calendar: cal)
        let early = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "early")
        let late = Schedule(hour: 18, minute: 0, weekdays: WeekdayPreset.everyDay, message: "late")
        let result = try XCTUnwrap(calc.nextFire(in: [late, early], after: now))
        XCTAssertEqual(result.schedule.message, "early")
        XCTAssertEqual(cal.component(.hour, from: result.date), 9)
    }

    // FR-16: exact same-minute tie resolves to the later schedule in creation order.
    func testSameMinuteTieResolvesToLaterCreationOrder() throws {
        let now = TestSupport.date(2025, 1, 6, 8, 0, calendar: cal)
        let first = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "first")
        let second = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "second")
        let result = try XCTUnwrap(calc.nextFire(in: [first, second], after: now))
        XCTAssertEqual(result.schedule.message, "second")
    }
}
