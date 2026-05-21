import SwiftUI
import GoToBedCore

/// The En Dash brand palette, offered as quick swatches in the appearance editor.
enum BrandColor: String, CaseIterable {
    case pink, orange, green, teal, darkBlue, purple, darkGray, black, white

    var label: String {
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

    var hex: String {
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

    var components: ColorComponents { ColorComponents(hex: hex) }
}

extension ColorComponents {
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
struct AppearancePreset: Identifiable {
    let name: String
    let background: BrandColor
    let text: BrandColor
    var id: String { name }

    /// Apply to an appearance, preserving the separately-controlled opacity and
    /// font sizes — only the colors change.
    func apply(to appearance: inout AppearanceSettings) {
        var bg = background.components
        bg.alpha = appearance.backgroundColor.alpha
        appearance.backgroundColor = bg
        appearance.textColor = text.components
    }

    /// All curated combos are high-contrast (pass the readability threshold).
    static let all: [AppearancePreset] = [
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

/// A row of tappable preset chips, each previewing its background + text combo.
struct PresetRow: View {
    @Binding var appearance: AppearanceSettings

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppearancePreset.all) { preset in
                    Button { preset.apply(to: &appearance) } label: {
                        VStack(spacing: 3) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(preset.background.components))
                                Text("Aa")
                                    .font(.system(.caption, design: .rounded).weight(.semibold))
                                    .foregroundStyle(Color(preset.text.components))
                            }
                            .frame(width: 46, height: 30)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))
                            Text(preset.name)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .help("\(preset.name): \(preset.text.label) on \(preset.background.label)")
                    .accessibilityLabel("\(preset.name) preset")
                }
            }
            .padding(.vertical, 2)
        }
    }
}

/// A row of brand-color swatches that set the bound color on tap.
struct SwatchPicker: View {
    @Binding var color: ColorComponents
    /// Keep the current alpha (used for the background, whose opacity is set
    /// separately). When false the swatch's opaque alpha is applied.
    var preserveAlpha: Bool

    var body: some View {
        HStack(spacing: 6) {
            ForEach(BrandColor.allCases, id: \.self) { brand in
                let c = brand.components
                let selected = color.matchesRGB(c)
                Button {
                    var newColor = c
                    if preserveAlpha { newColor.alpha = color.alpha }
                    color = newColor
                } label: {
                    Circle()
                        .fill(Color(ColorComponents(red: c.red, green: c.green, blue: c.blue, alpha: 1)))
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(.secondary.opacity(0.35)))
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: selected ? 2.5 : 0)
                                .padding(-2)
                        )
                }
                .buttonStyle(.plain)
                .help("\(brand.label) (#\(brand.hex))")
                .accessibilityLabel(brand.label)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }
}
