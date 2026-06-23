import Foundation

/// How an overlay goes away once shown.
public enum DismissMode: Codable, Equatable, Sendable {
    /// Auto-dismiss after `seconds` (clamped to `Schedule.durationRange`).
    case auto(seconds: Int)
    /// Stays until the user presses Esc / clicks dismiss.
    case manual

    public static let defaultAutoSeconds = 60
}

/// What the user must *do* to dismiss the overlay — independent of the
/// auto/manual timing in `DismissMode`. The default preserves the original
/// "press Esc" behavior; the other cases add deliberate friction so a bedtime
/// reminder can't be dismissed reflexively. None of these trap the OS escape
/// routes (Cmd-Tab, Mission Control, force-quit) — they gate only the overlay's
/// own dismiss path.
public enum DismissChallenge: Codable, Equatable, Sendable {
    /// Esc dismisses (original behavior).
    case escape
    /// A randomly chosen key (picked when the overlay is shown) must be pressed.
    case randomKey
    /// The user must type `target` exactly.
    case typeString(String)

    /// Longest allowed type-to-dismiss phrase.
    public static let maxTypeStringLength = 100
}

/// A weekly recurring reminder: a time-of-day, the weekdays it is active on,
/// a message, and how its overlay looks and dismisses.
public struct Schedule: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var hour: Int            // 0...23, local time
    public var minute: Int          // 0...59
    /// Active weekdays using `Calendar` numbering: 1 = Sunday … 7 = Saturday.
    /// Must be non-empty for the schedule to be valid.
    public var weekdays: Set<Int>
    /// Primary message, shown prominently below the clock.
    public var message: String
    /// Optional secondary line, shown smaller beneath the primary message.
    public var submessage: String
    public var isEnabled: Bool
    public var dismissMode: DismissMode
    /// What the user must do to dismiss the overlay (Esc / random key / typed phrase).
    public var dismissChallenge: DismissChallenge
    public var appearance: AppearanceSettings

    /// Allowed auto-dismiss durations in seconds (PRD FR-2).
    public static let durationRange: ClosedRange<Int> = 5...3600
    /// Maximum message length (PRD FR-2, ~500 chars).
    public static let maxMessageLength = 500
    /// Valid weekday numbers.
    public static let validWeekdays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]

    public init(
        id: UUID = UUID(),
        hour: Int,
        minute: Int,
        weekdays: Set<Int>,
        message: String,
        submessage: String = "",
        isEnabled: Bool = true,
        dismissMode: DismissMode = .auto(seconds: DismissMode.defaultAutoSeconds),
        dismissChallenge: DismissChallenge = .escape,
        appearance: AppearanceSettings = .appDefault
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.weekdays = weekdays
        self.message = message
        self.submessage = submessage
        self.isEnabled = isEnabled
        self.dismissMode = dismissMode
        self.dismissChallenge = dismissChallenge
        self.appearance = appearance
    }

    enum CodingKeys: String, CodingKey {
        case id, hour, minute, weekdays, message, submessage, isEnabled, dismissMode, dismissChallenge, appearance
    }

    // Custom decode so older saved schedules (no `submessage` key) still load
    // rather than tripping the persistence fallback (NFR-persist-2). Encoding
    // stays synthesized.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        hour = try c.decode(Int.self, forKey: .hour)
        minute = try c.decode(Int.self, forKey: .minute)
        weekdays = try c.decode(Set<Int>.self, forKey: .weekdays)
        message = try c.decode(String.self, forKey: .message)
        submessage = try c.decodeIfPresent(String.self, forKey: .submessage) ?? ""
        isEnabled = try c.decode(Bool.self, forKey: .isEnabled)
        dismissMode = try c.decode(DismissMode.self, forKey: .dismissMode)
        // Older saved schedules predate the dismissal challenge — default to Esc.
        dismissChallenge = try c.decodeIfPresent(DismissChallenge.self, forKey: .dismissChallenge) ?? .escape
        appearance = try c.decode(AppearanceSettings.self, forKey: .appearance)
    }
}

/// Top-level persisted state: the schedules plus the default appearance new
/// schedules inherit (PRD §5.3).
public struct AppState: Codable, Equatable, Sendable {
    public var schedules: [Schedule]
    public var defaultAppearance: AppearanceSettings
    public var launchAtLogin: Bool

    public init(
        schedules: [Schedule] = [],
        defaultAppearance: AppearanceSettings = .appDefault,
        launchAtLogin: Bool = false
    ) {
        self.schedules = schedules
        self.defaultAppearance = defaultAppearance
        self.launchAtLogin = launchAtLogin
    }

    public static let empty = AppState()
}

public extension DismissMode {
    /// The auto duration in seconds, or nil for manual.
    var autoSeconds: Int? {
        if case let .auto(seconds) = self { return seconds }
        return nil
    }
}

/// Common weekday presets (PRD FR-2).
public enum WeekdayPreset {
    public static let everyDay: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
    public static let weekdays: Set<Int> = [2, 3, 4, 5, 6]   // Mon–Fri
    public static let weekends: Set<Int> = [1, 7]            // Sun, Sat
}
