import SwiftUI

extension View {
    /// `onChange` that works on the macOS 13 deployment floor (NFR-compat-1).
    ///
    /// The two-parameter `onChange(of:initial:_:)` is macOS 14+, so on 13 we use
    /// the single-parameter form. The 13 path is the only deprecated call in the
    /// codebase, deliberately confined here for back-deployment.
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(macOS 14, *) {
            onChange(of: value) { _, newValue in action(newValue) }
        } else {
            onChange(of: value) { newValue in action(newValue) }
        }
    }
}
