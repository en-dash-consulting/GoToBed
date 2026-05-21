import Foundation

/// A framework-agnostic RGBA color (each component in 0...1).
///
/// Kept free of SwiftUI/AppKit so the model layer stays unit-testable
/// without a UI. Bridging to `Color`/`NSColor` lives in the app target.
public struct ColorComponents: Codable, Equatable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red.clamped01
        self.green = green.clamped01
        self.blue = blue.clamped01
        self.alpha = alpha.clamped01
    }

    /// Relative luminance per WCAG 2.1, used for contrast checks.
    public var relativeLuminance: Double {
        func lin(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * lin(red) + 0.7152 * lin(green) + 0.0722 * lin(blue)
    }

    public static let black = ColorComponents(red: 0, green: 0, blue: 0)
    public static let white = ColorComponents(red: 1, green: 1, blue: 1)
}

private extension Double {
    var clamped01: Double { Swift.min(1, Swift.max(0, self)) }
}

/// Per-schedule (and app-wide default) visual styling for the overlay.
public struct AppearanceSettings: Codable, Equatable, Sendable {
    public var backgroundColor: ColorComponents
    public var textColor: ColorComponents
    public var clockFontSize: Double
    public var messageFontSize: Double

    public init(
        backgroundColor: ColorComponents,
        textColor: ColorComponents,
        clockFontSize: Double,
        messageFontSize: Double
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.clockFontSize = clockFontSize
        self.messageFontSize = messageFontSize
    }

    /// Default seed for new schedules: dark translucent background, light text,
    /// large clock (PRD FR-15).
    public static let appDefault = AppearanceSettings(
        backgroundColor: ColorComponents(red: 0.05, green: 0.05, blue: 0.08, alpha: 0.92),
        textColor: ColorComponents(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0),
        clockFontSize: 120,
        messageFontSize: 36
    )

    /// WCAG contrast ratio between text and background (1...21).
    /// Computed against the background composited over black so translucent
    /// backgrounds are judged the way they appear on a dark overlay.
    public var contrastRatio: Double {
        let bgOpaque = backgroundColor.composited(over: .black)
        let l1 = textColor.relativeLuminance
        let l2 = bgOpaque.relativeLuminance
        let lighter = Swift.max(l1, l2)
        let darker = Swift.min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// True when text is hard to read against the background (WCAG AA large-text
    /// threshold is 3.0; we warn below that). PRD NFR-use-4.
    public var hasLowContrast: Bool { contrastRatio < 3.0 }
}

public extension ColorComponents {
    /// Alpha-composite this color over an opaque background.
    func composited(over background: ColorComponents) -> ColorComponents {
        let a = alpha
        return ColorComponents(
            red: red * a + background.red * (1 - a),
            green: green * a + background.green * (1 - a),
            blue: blue * a + background.blue * (1 - a),
            alpha: 1.0
        )
    }
}
