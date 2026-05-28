import Foundation

/// Pre-computed display data for a single schedule in the menu-bar popover.
///
/// Produced by `AppEnvironment.scheduleItems` and passed into `MenuContent` as
/// a plain value, so the menu view has no direct dependency on `Store` or
/// `Schedule`. All domain reads are resolved at the composition root.
struct ScheduleDisplayItem: Identifiable {
    let id: UUID
    let timeString: String
    /// "Mon–Fri · Time to wind down" style summary.
    let subtitle: String
    let isEnabled: Bool
}
