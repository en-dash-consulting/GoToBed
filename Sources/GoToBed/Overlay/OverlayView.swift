import SwiftUI
import GoToBedCore

/// The full-screen overlay content: a large live clock, the schedule's message,
/// a dismiss hint, and (in auto mode) an unobtrusive countdown ring.
struct OverlayView: View {
    let schedule: Schedule
    /// When the overlay was presented — anchors the clock tick and the countdown.
    let startDate: Date
    /// Live dismissal-challenge state, driven by the window's key events.
    @ObservedObject var challenge: DismissChallengeState
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var appearance: AppearanceSettings { schedule.appearance }
    private var isAuto: Bool { schedule.dismissMode.autoSeconds != nil }

    var body: some View {
        GeometryReader { geo in
            // Clamp font sizes so the content always fits the screen vertically;
            // minimumScaleFactor then handles horizontal fit. A configured size
            // is treated as a target maximum, never an overflow.
            let clockSize = min(appearance.clockFontSize, geo.size.height * 0.55)
            let messageSize = min(appearance.messageFontSize, geo.size.height * 0.18)

            ZStack {
                Color(appearance.backgroundColor)
                    .ignoresSafeArea()

                VStack(spacing: max(16, messageSize * 0.5)) {
                    TimelineView(.periodic(from: startDate, by: 1)) { context in
                        Text(Self.clockText(context.date))
                            .font(.system(size: clockSize, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .accessibilityLabel("Current time \(Self.clockText(context.date))")
                    }

                    if !schedule.message.isEmpty {
                        Text(schedule.message)
                            .font(.system(size: messageSize, weight: .medium))
                            .multilineTextAlignment(.center)
                            .lineLimit(5)
                            .minimumScaleFactor(0.3)
                    }

                    if !schedule.submessage.isEmpty {
                        Text(schedule.submessage)
                            .font(.system(size: messageSize * 0.6, weight: .regular))
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .minimumScaleFactor(0.3)
                            .opacity(0.85)
                    }

                    if let seconds = schedule.dismissMode.autoSeconds {
                        CountdownRing(startDate: startDate, duration: Double(seconds))
                            .frame(width: 44, height: 44)
                            .padding(.top, 8)
                            .accessibilityHidden(true)
                    }

                    VStack(spacing: 8) {
                        Text(challenge.prompt)
                            .font(.system(size: 15))
                            .opacity(0.55)
                            .multilineTextAlignment(.center)
                            .accessibilityLabel(challenge.prompt)

                        // Show typed progress for the type-to-dismiss challenge.
                        if case .typeString = challenge.kind {
                            Text(challenge.typed.isEmpty ? " " : challenge.typed)
                                .font(.system(size: 17, weight: .semibold, design: .monospaced))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.secondary.opacity(0.4), lineWidth: 1)
                                )
                                .accessibilityLabel("Typed so far: \(challenge.typed)")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(60)
                .foregroundStyle(Color(appearance.textColor))
            }
            .contentShape(Rectangle())
            // Auto mode allows an early dismiss by clicking — but only when the
            // schedule uses the plain Esc challenge. A friction challenge must be
            // satisfied by the keyed/typed action, so tapping does nothing.
            .onTapGesture { if isAuto && challenge.allowsTapDismiss { onDismiss() } }
            .transaction { if reduceMotion { $0.disablesAnimations = true } }
        }
    }

    /// Locale-aware clock string (12h/24h per system settings) with seconds.
    static func clockText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("jmmss")
        return f.string(from: date)
    }
}

/// A thin progress ring that drains over `duration` seconds from `startDate`.
private struct CountdownRing: View {
    let startDate: Date
    let duration: Double

    var body: some View {
        TimelineView(.periodic(from: startDate, by: 0.2)) { context in
            let elapsed = context.date.timeIntervalSince(startDate)
            let remaining = max(0, 1 - elapsed / duration)
            ZStack {
                Circle().stroke(.secondary.opacity(0.25), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: remaining)
                    .stroke(.secondary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(ceil(max(0, duration - elapsed))))")
                    .font(.system(size: 13, weight: .medium))
                    .monospacedDigit()
            }
        }
    }
}
