import Foundation
@testable import GoToBedCore

/// Shared date/calendar utilities for GoToBedTests (app-layer tests).
enum AppLayerTestHelpers {
    /// A deterministic UTC Gregorian calendar for time/weekday assertions.
    static func utcCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    /// Construct an exact Date from components using the given calendar.
    static func date(
        _ year: Int, _ month: Int, _ day: Int,
        _ hour: Int = 0, _ minute: Int = 0, _ second: Int = 0,
        nanosecond: Int = 0,
        calendar: Calendar
    ) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        c.hour = hour; c.minute = minute; c.second = second
        c.nanosecond = nanosecond
        return calendar.date(from: c)!
    }
}
