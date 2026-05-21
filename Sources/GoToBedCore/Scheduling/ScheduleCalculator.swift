import Foundation

/// Pure next-occurrence math for schedules.
///
/// Everything here computes occurrences *strictly after* a supplied reference
/// date. That single invariant is what gives us the PRD's "skip, never replay"
/// sleep behavior (NFR-rel-2) for free: on wake we recompute with `now`, so any
/// occurrence that elapsed during sleep is simply never produced. It also gives
/// FR-4 (a newly-created schedule whose time already passed today fires at its
/// next active occurrence, not immediately).
public struct ScheduleCalculator {
    public var calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// The next instant `schedule` should fire, strictly after `date`.
    /// Returns nil for a disabled schedule or one with no valid weekdays.
    public func nextFireDate(for schedule: Schedule, after date: Date) -> Date? {
        guard schedule.isEnabled else { return nil }
        let activeDays = schedule.weekdays.filter { Schedule.validWeekdays.contains($0) }
        guard !activeDays.isEmpty else { return nil }

        var soonest: Date?
        for weekday in activeDays {
            var comps = DateComponents()
            comps.hour = schedule.hour
            comps.minute = schedule.minute
            comps.second = 0
            comps.weekday = weekday
            guard let candidate = calendar.nextDate(
                after: date,
                matching: comps,
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .forward
            ) else { continue }
            if soonest == nil || candidate < soonest! {
                soonest = candidate
            }
        }
        return soonest
    }

    /// The soonest fire across all `schedules` strictly after `date`, paired with
    /// the schedule that produces it. When two schedules tie on the exact same
    /// instant, the later one in array (creation) order wins, matching FR-16's
    /// "newer message wins" / last-by-creation-order rule.
    public func nextFire(
        in schedules: [Schedule],
        after date: Date
    ) -> (schedule: Schedule, date: Date)? {
        var best: (schedule: Schedule, date: Date)?
        for schedule in schedules {
            guard let fire = nextFireDate(for: schedule, after: date) else { continue }
            if let current = best {
                // `<=` so a tie resolves to the later schedule in creation order.
                if fire <= current.date {
                    best = (schedule, fire)
                }
            } else {
                best = (schedule, fire)
            }
        }
        return best
    }
}
