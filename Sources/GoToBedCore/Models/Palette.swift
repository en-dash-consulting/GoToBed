import Foundation

/// En Dash brand palette — colour tokens shared across the app layer zones
/// (settings-ui, overlay-ui, and any future ui zones).
///
/// Living in GoToBedCore makes these definitions accessible without any
/// cross-zone import: both the settings editor and the overlay can reference
/// BrandColor and AppearancePreset via the foundation layer they already import.
public enum BrandColor: String, CaseIterable {
    case pink, orange, green, teal, darkBlue, purple, darkGray, black, white

    public var label: String {
        switch self {
        case .pink: return "n-pink"
        case .orange: return "n-orange"
        case .green: return "n-green"
        case .teal: return "n-teal"
        case .darkBlue: return "n-darkblue"
        case .purple: return "n-purple"
        case .darkGray: return "n-darkgray"
        case .black: return "n-black"
        case .white: return "n-white"
        }
    }

    public var hex: String {
        switch self {
        case .pink: return "D52E66"
        case .orange: return "FF5926"
        case .green: return "00BD81"
        case .teal: return "00E5B9"
        case .darkBlue: return "001769"
        case .purple: return "6C41F0"
        case .darkGray: return "4B5462"
        case .black: return "000000"
        case .white: return "FFFFFF"
        }
    }

    public var components: ColorComponents { ColorComponents(hex: hex) }
}

public extension ColorComponents {
    /// Parse "#RRGGBB" / "RRGGBB" (alpha defaults to opaque).
    init(hex: String) {
        var s = hex
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        self.init(
            red: Double((v >> 16) & 0xFF) / 255,
            green: Double((v >> 8) & 0xFF) / 255,
            blue: Double(v & 0xFF) / 255,
            alpha: 1
        )
    }

    /// True when RGB matches `other` (ignoring alpha), within a small tolerance.
    func matchesRGB(_ other: ColorComponents) -> Bool {
        let t = 0.004
        return abs(red - other.red) < t && abs(green - other.green) < t && abs(blue - other.blue) < t
    }
}

/// A curated background+text brand combination, applied in one tap.
public struct AppearancePreset: Identifiable {
    public let name: String
    public let background: BrandColor
    public let text: BrandColor
    public var id: String { name }

    public init(name: String, background: BrandColor, text: BrandColor) {
        self.name = name
        self.background = background
        self.text = text
    }

    /// Apply to an appearance, preserving the separately-controlled opacity and
    /// font sizes — only the colors change.
    public func apply(to appearance: inout AppearanceSettings) {
        var bg = background.components
        bg.alpha = appearance.backgroundColor.alpha
        appearance.backgroundColor = bg
        appearance.textColor = text.components
    }

    /// All curated combos are high-contrast (pass the readability threshold).
    public static let all: [AppearancePreset] = [
        AppearancePreset(name: "Midnight", background: .darkBlue, text: .white),
        AppearancePreset(name: "Teal Night", background: .black, text: .teal),
        AppearancePreset(name: "Sunset", background: .darkBlue, text: .orange),
        AppearancePreset(name: "Berry", background: .black, text: .pink),
        AppearancePreset(name: "Aurora", background: .darkBlue, text: .teal),
        AppearancePreset(name: "Violet", background: .purple, text: .white),
        AppearancePreset(name: "Slate", background: .darkGray, text: .white),
        AppearancePreset(name: "Mono", background: .black, text: .white),
    ]
}
