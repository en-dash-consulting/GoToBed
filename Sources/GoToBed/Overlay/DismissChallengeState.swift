import Foundation
import GoToBedCore

/// Live state for an overlay's dismissal challenge.
///
/// The `OverlayWindow` owns one of these, feeds it the user's keystrokes, and
/// dismisses when `handle(character:)` reports the challenge is satisfied.
/// `OverlayView` observes it to render the prompt and (for type-to-dismiss) the
/// typed progress. Resolving the random key here — rather than in the pure-logic
/// core — keeps the per-presentation choice out of the persisted model.
@MainActor
final class DismissChallengeState: ObservableObject {
    /// The concrete challenge for this presentation, with the random key already
    /// chosen so the window and the view agree on which key to require.
    enum Kind: Equatable {
        case escape
        case randomKey(Character)
        case typeString(String)
    }

    let kind: Kind
    /// Progress toward the target phrase (type-to-dismiss only).
    @Published private(set) var typed: String = ""

    /// Candidate keys for the random-key challenge: unambiguous uppercase letters
    /// (I and O dropped to avoid 1/0 confusion).
    static let randomKeyAlphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ")

    init<R: RandomNumberGenerator>(challenge: DismissChallenge, rng: inout R) {
        switch challenge {
        case .escape:
            kind = .escape
        case .randomKey:
            kind = .randomKey(Self.randomKeyAlphabet.randomElement(using: &rng) ?? "K")
        case .typeString(let target):
            kind = .typeString(target)
        }
    }

    convenience init(challenge: DismissChallenge) {
        var rng = SystemRandomNumberGenerator()
        self.init(challenge: challenge, rng: &rng)
    }

    /// Whether Esc dismisses. Only the (default) escape challenge honors Esc;
    /// the friction modes deliberately ignore it. OS escape routes (Cmd-Tab,
    /// force-quit) are unaffected regardless — the window never traps them.
    var escDismisses: Bool {
        if case .escape = kind { return true }
        return false
    }

    /// Whether clicking the overlay may dismiss it early. Only meaningful for the
    /// escape challenge; the friction modes require the keyed/typed action.
    var allowsTapDismiss: Bool { escDismisses }

    /// Feed one typed character to the challenge. Returns `true` once satisfied.
    @discardableResult
    func handle(character: Character) -> Bool {
        switch kind {
        case .escape:
            return false
        case .randomKey(let required):
            guard let upper = character.uppercased().first else { return false }
            return upper == required
        case .typeString(let target):
            let candidate = typed + String(character)
            if target.hasPrefix(candidate) {
                typed = candidate
            } else {
                // Wrong character: restart, but let this keystroke begin a fresh
                // attempt if it matches the phrase's first character.
                typed = target.hasPrefix(String(character)) ? String(character) : ""
            }
            return typed == target && !target.isEmpty
        }
    }

    /// Remove the last typed character (Backspace) in type-to-dismiss mode.
    func deleteBackward() {
        if case .typeString = kind, !typed.isEmpty {
            typed.removeLast()
        }
    }

    /// User-facing instruction shown in the overlay.
    var prompt: String {
        switch kind {
        case .escape:
            return "Press Esc to dismiss"
        case .randomKey(let key):
            return "Press the \(key) key to dismiss"
        case .typeString(let target):
            return "Type \u{201C}\(target)\u{201D} to dismiss"
        }
    }
}
