import XCTest
@testable import GoToBedCore

/// Simulates the scheduler's fire -> recompute-forward -> re-arm loop (the same
/// decision logic `SchedulerEngine` runs around a Timer) entirely in terms of
/// the pure calculator, so the end-to-end sequencing is testable headlessly.
final class SchedulerLoopTests: XCTestCase {
    let cal = TestSupport.utcCalendar()
    lazy var calc = ScheduleCalculator(calendar: cal)

    /// Drive the loop `count` times starting at `start`, advancing "now" to each
    /// fire (as a Timer would). Returns the ordered fire dates.
    private func runLoop(_ schedules: [Schedule], from start: Date, count: Int) -> [Date] {
        var now = start
        var fires: [Date] = []
        for _ in 0..<count {
            guard let next = calc.nextFire(in: schedules, after: now) else { break }
            fires.append(next.date)
            now = next.date // the timer "fires" exactly at next.date
        }
        return fires
    }

    func testDailyScheduleFiresOncePerDayStrictlyIncreasing() throws {
        let s = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "x")
        let start = TestSupport.date(2025, 1, 6, 0, 0, calendar: cal)
        let fires = runLoop([s], from: start, count: 5)

        XCTAssertEqual(fires.count, 5)
        // Strictly increasing — never re-fires the same instant.
        for i in 1..<fires.count {
            XCTAssertGreaterThan(fires[i], fires[i - 1])
        }
        // Exactly 24h apart, all at 09:00.
        for f in fires { XCTAssertEqual(cal.component(.hour, from: f), 9) }
        XCTAssertEqual(cal.dateComponents([.day], from: fires[0], to: fires[1]).day!, 1)
    }

    func testTwoSchedulesInterleaveByTime() {
        let morning = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "am")
        let evening = Schedule(hour: 18, minute: 0, weekdays: WeekdayPreset.everyDay, message: "pm")
        let start = TestSupport.date(2025, 1, 6, 0, 0, calendar: cal)
        let fires = runLoop([morning, evening], from: start, count: 4)
        // 09:00, 18:00, 09:00, 18:00
        XCTAssertEqual(fires.map { cal.component(.hour, from: $0) }, [9, 18, 9, 18])
    }

    func testDisabledScheduleDropsOutOfLoop() {
        var s = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.everyDay, message: "x")
        s.isEnabled = false
        let start = TestSupport.date(2025, 1, 6, 0, 0, calendar: cal)
        XCTAssertTrue(runLoop([s], from: start, count: 3).isEmpty)
    }

    func testWeekdayOnlyScheduleSkipsWeekend() throws {
        // Mon–Fri 09:00 starting Friday should fire Fri, then Mon (skipping Sat/Sun).
        let s = Schedule(hour: 9, minute: 0, weekdays: WeekdayPreset.weekdays, message: "x")
        let friday = TestSupport.date(2025, 1, 10, 0, 0, calendar: cal) // 2025-01-10 is Friday
        XCTAssertEqual(cal.component(.weekday, from: friday), 6)
        let fires = runLoop([s], from: friday, count: 2)
        XCTAssertEqual(cal.component(.weekday, from: fires[0]), 6) // Friday
        XCTAssertEqual(cal.component(.weekday, from: fires[1]), 2) // Monday
        XCTAssertEqual(cal.dateComponents([.day], from: fires[0], to: fires[1]).day!, 3)
    }
}
