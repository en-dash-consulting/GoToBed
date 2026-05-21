import Foundation

/// A single reason a schedule is invalid.
public enum ScheduleValidationError: Error, Equatable, CustomStringConvertible {
    case emptyWeekdays
    case invalidWeekday(Int)
    case hourOutOfRange(Int)
    case minuteOutOfRange(Int)
    case durationOutOfRange(Int)
    case messageTooLong(Int)
    case submessageTooLong(Int)

    public var description: String {
        switch self {
        case .emptyWeekdays:
            return "At least one active day is required."
        case let .invalidWeekday(d):
            return "Invalid weekday \(d); must be 1...7."
        case let .hourOutOfRange(h):
            return "Hour \(h) out of range; must be 0...23."
        case let .minuteOutOfRange(m):
            return "Minute \(m) out of range; must be 0...59."
        case let .durationOutOfRange(s):
            return "Auto-dismiss duration \(s)s out of range; must be \(Schedule.durationRange.lowerBound)...\(Schedule.durationRange.upperBound)."
        case let .messageTooLong(n):
            return "Message length \(n) exceeds \(Schedule.maxMessageLength)."
        case let .submessageTooLong(n):
            return "Submessage length \(n) exceeds \(Schedule.maxMessageLength)."
        }
    }
}

public extension Schedule {
    /// All validation problems with this schedule (empty == valid).
    func validationErrors() -> [ScheduleValidationError] {
        var errors: [ScheduleValidationError] = []
        if weekdays.isEmpty { errors.append(.emptyWeekdays) }
        for d in weekdays where !Schedule.validWeekdays.contains(d) {
            errors.append(.invalidWeekday(d))
        }
        if !(0...23).contains(hour) { errors.append(.hourOutOfRange(hour)) }
        if !(0...59).contains(minute) { errors.append(.minuteOutOfRange(minute)) }
        if case let .auto(seconds) = dismissMode, !Schedule.durationRange.contains(seconds) {
            errors.append(.durationOutOfRange(seconds))
        }
        if message.count > Schedule.maxMessageLength {
            errors.append(.messageTooLong(message.count))
        }
        if submessage.count > Schedule.maxMessageLength {
            errors.append(.submessageTooLong(submessage.count))
        }
        return errors
    }

    var isValid: Bool { validationErrors().isEmpty }

    /// Returns a copy with values coerced into valid ranges. Used by the editor
    /// so a slightly-out-of-range value is corrected rather than rejected.
    func sanitized() -> Schedule {
        var copy = self
        copy.hour = min(23, max(0, hour))
        copy.minute = min(59, max(0, minute))
        copy.weekdays = weekdays.filter { Schedule.validWeekdays.contains($0) }
        if case let .auto(seconds) = dismissMode {
            let clamped = min(Schedule.durationRange.upperBound,
                              max(Schedule.durationRange.lowerBound, seconds))
            copy.dismissMode = .auto(seconds: clamped)
        }
        if message.count > Schedule.maxMessageLength {
            copy.message = String(message.prefix(Schedule.maxMessageLength))
        }
        if submessage.count > Schedule.maxMessageLength {
            copy.submessage = String(submessage.prefix(Schedule.maxMessageLength))
        }
        return copy
    }
}
