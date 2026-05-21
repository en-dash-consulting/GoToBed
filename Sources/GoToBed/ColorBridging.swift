import SwiftUI
import GoToBedCore

extension Color {
    init(_ c: ColorComponents) {
        self = Color(.sRGB, red: c.red, green: c.green, blue: c.blue, opacity: c.alpha)
    }
}

extension ColorComponents {
    /// Build from a SwiftUI `Color` by resolving through `NSColor` in sRGB.
    init(_ color: Color) {
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? .black
        self.init(
            red: Double(ns.redComponent),
            green: Double(ns.greenComponent),
            blue: Double(ns.blueComponent),
            alpha: Double(ns.alphaComponent)
        )
    }

    /// A `Color` <-> `ColorComponents` binding for use with SwiftUI `ColorPicker`.
    static func binding(_ source: Binding<ColorComponents>) -> Binding<Color> {
        Binding(
            get: { Color(source.wrappedValue) },
            set: { source.wrappedValue = ColorComponents($0) }
        )
    }
}
