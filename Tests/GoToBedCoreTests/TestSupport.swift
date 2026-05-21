import Foundation
@testable import GoToBedCore

enum TestSupport {
    /// A deterministic UTC Gregorian calendar for weekday/time assertions.
    static func utcCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    /// A calendar in a DST-observing zone for transition tests.
    static func newYorkCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        return cal
    }

    static func date(
        _ year: Int, _ month: Int, _ day: Int,
        _ hour: Int = 0, _ minute: Int = 0, _ second: Int = 0,
        calendar: Calendar
    ) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        c.hour = hour; c.minute = minute; c.second = second
        return calendar.date(from: c)!
    }
}
