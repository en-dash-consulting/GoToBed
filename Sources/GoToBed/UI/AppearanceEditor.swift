import SwiftUI
import GoToBedCore

/// Reusable appearance controls (colors + font sizes) with a live preview tile
/// and a low-contrast warning (PRD FR-13, FR-14, NFR-use-4).
struct AppearanceEditor: View {
    @Binding var appearance: AppearanceSettings

    /// Generous ranges so the overlay can be made very large on big displays.
    static let clockSizeRange: ClosedRange<Double> = 40...500
    static let messageSizeRange: ClosedRange<Double> = 14...240

    private func sliderRow(_ title: String, value: Binding<Double>, range: ClosedRange<Double>, caption: String) -> some View {
        LabeledContent(title) {
            HStack(spacing: 8) {
                Slider(value: value, in: range) { Text(title) }
                    .frame(width: 180)
                Text(caption)
                    .font(.caption).monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: 44, alignment: .trailing)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Brand presets").font(.caption).foregroundStyle(.secondary)
                PresetRow(appearance: $appearance)
            }

            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        ColorPicker("Background", selection: ColorComponents.binding($appearance.backgroundColor), supportsOpacity: false)
                        SwatchPicker(color: $appearance.backgroundColor, preserveAlpha: true)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        ColorPicker("Text", selection: ColorComponents.binding($appearance.textColor), supportsOpacity: false)
                        SwatchPicker(color: $appearance.textColor, preserveAlpha: false)
                    }

                    sliderRow("Overlay opacity",
                              value: $appearance.backgroundColor.alpha,
                              range: 0...1,
                              caption: "\(Int(appearance.backgroundColor.alpha * 100))%")
                    sliderRow("Clock size",
                              value: $appearance.clockFontSize,
                              range: Self.clockSizeRange,
                              caption: "\(Int(appearance.clockFontSize)) pt")
                    sliderRow("Message size",
                              value: $appearance.messageFontSize,
                              range: Self.messageSizeRange,
                              caption: "\(Int(appearance.messageFontSize)) pt")
                }

                PreviewTile(appearance: appearance)
                    .frame(width: 200, height: 130)
            }

            if appearance.hasLowContrast {
                Label("Text may be hard to read against this background.", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .accessibilityLabel("Warning: low contrast between text and background.")
            }
        }
    }
}

/// A scaled representation of how the overlay will look. Text size tracks the
/// configured sizes (as a fraction of their range) mapped into the tile, so
/// dragging a size slider visibly changes the preview, while `minimumScaleFactor`
/// keeps it from overflowing the tile.
struct PreviewTile: View {
    let appearance: AppearanceSettings

    var body: some View {
        GeometryReader { geo in
            let clockFrac = fraction(appearance.clockFontSize, AppearanceEditor.clockSizeRange)
            let msgFrac = fraction(appearance.messageFontSize, AppearanceEditor.messageSizeRange)
            let clockFont = geo.size.height * (0.18 + 0.42 * clockFrac)
            let msgFont = geo.size.height * (0.07 + 0.18 * msgFrac)

            ZStack {
                Color(appearance.backgroundColor)
                VStack(spacing: 4) {
                    Text("10:30")
                        .font(.system(size: clockFont, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                    Text("Go to bed")
                        .font(.system(size: msgFont, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                }
                .padding(6)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(Color(appearance.textColor))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)))
        .accessibilityLabel("Appearance preview")
    }

    private func fraction(_ value: Double, _ range: ClosedRange<Double>) -> Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return min(1, max(0, (value - range.lowerBound) / span))
    }
}
