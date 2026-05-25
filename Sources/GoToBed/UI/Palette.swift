import SwiftUI
import GoToBedCore

// BrandColor, ColorComponents hex extension, and AppearancePreset live in
// GoToBedCore/Models/Palette.swift so both settings-ui and any future overlay-ui
// zone can reference shared visual tokens without a cross-zone import.

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
