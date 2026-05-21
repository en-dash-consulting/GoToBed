import SwiftUI
import GoToBedCore

/// A row of seven circular day toggles (S M T W T F S), accent-filled when
/// active, plus the Every day / Weekdays / Weekends presets.
struct WeekdayPicker: View {
    @Binding var weekdays: Set<Int>

    private static let letters: [String] = {
        let f = DateFormatter()
        f.locale = .current
        // veryShortWeekdaySymbols is Sunday-first, matching weekday = 1...7.
        return f.veryShortWeekdaySymbols ?? ["S", "M", "T", "W", "T", "F", "S"]
    }()

    private static let fullNames: [String] = {
        let f = DateFormatter()
        f.locale = .current
        return f.weekdaySymbols ?? []
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(1...7, id: \.self) { day in
                    dayButton(day)
                }
            }
            HStack(spacing: 8) {
                preset("Every day", WeekdayPreset.everyDay)
                preset("Weekdays", WeekdayPreset.weekdays)
                preset("Weekends", WeekdayPreset.weekends)
            }
        }
    }

    private func dayButton(_ day: Int) -> some View {
        let on = weekdays.contains(day)
        return Button {
            if on { weekdays.remove(day) } else { weekdays.insert(day) }
        } label: {
            Text(Self.letters[safe: day - 1] ?? "?")
                .font(.system(.callout, design: .rounded).weight(.semibold))
                .frame(width: 32, height: 32)
                .background(
                    Circle().fill(on ? Color.accentColor : Color.secondary.opacity(0.15))
                )
                .foregroundStyle(on ? Color.white : Color.primary)
                .overlay(Circle().stroke(Color.secondary.opacity(on ? 0 : 0.25)))
        }
        .buttonStyle(.plain)
        .help(Self.fullNames[safe: day - 1] ?? "")
        .accessibilityLabel(Self.fullNames[safe: day - 1] ?? "Day \(day)")
        .accessibilityValue(on ? "active" : "inactive")
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private func preset(_ title: String, _ days: Set<Int>) -> some View {
        let active = weekdays == days
        return Button(title) { weekdays = days }
            .buttonStyle(.borderless)
            .font(.caption.weight(active ? .bold : .regular))
            .foregroundStyle(active ? Color.accentColor : Color.secondary)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
