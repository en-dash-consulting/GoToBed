import Foundation
import GoToBedCore

/// Display helpers for schedules, shared across the menu and editor.
enum ScheduleFormatting {
    /// Locale-aware "10:30 PM" / "22:30" for a schedule's time.
    static func timeString(_ schedule: Schedule) -> String {
        var comps = DateComponents()
        comps.hour = schedule.hour
        comps.minute = schedule.minute
        let date = Calendar.current.date(from: comps) ?? Date()
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("jmm")
        return f.string(from: date)
    }

    /// Calendar weekday symbols (localized), Sunday-first to match weekday=1.
    static var weekdaySymbols: [String] {
        let f = DateFormatter()
        f.locale = .current
        return f.shortWeekdaySymbols
    }

    /// "Mon–Fri · Time to wind down" style summary line.
    static func daysAndMessage(_ schedule: Schedule) -> String {
        let days = daysSummary(schedule.weekdays)
        let msg = schedule.message.replacingOccurrences(of: "\n", with: " ")
        return msg.isEmpty ? days : "\(days) · \(msg)"
    }

    static func daysSummary(_ weekdays: Set<Int>) -> String {
        if weekdays == WeekdayPreset.everyDay { return "Every day" }
        if weekdays == WeekdayPreset.weekdays { return "Weekdays" }
        if weekdays == WeekdayPreset.weekends { return "Weekends" }
        let symbols = weekdaySymbols // index 0 == Sunday
        return weekdays.sorted().compactMap { day -> String? in
            let idx = day - 1
            return symbols.indices.contains(idx) ? symbols[idx] : nil
        }.joined(separator: " ")
    }
}
