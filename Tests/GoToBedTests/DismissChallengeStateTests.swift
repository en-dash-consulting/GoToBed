import XCTest
@testable import GoToBedKit
@testable import GoToBedCore

/// Unit tests for the overlay's live dismissal-challenge handling: Esc gating,
/// random-key matching, and type-to-dismiss buffer transitions.
@MainActor
final class DismissChallengeStateTests: XCTestCase {

    /// Deterministic generator so random-key selection is reproducible in tests.
    private struct SeededRNG: RandomNumberGenerator {
        var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }
    }

    // MARK: Escape

    func testEscapeChallengeHonorsEscOnly() {
        let s = DismissChallengeState(challenge: .escape)
        XCTAssertTrue(s.escDismisses)
        XCTAssertTrue(s.allowsTapDismiss)
        XCTAssertFalse(s.handle(character: "x"))
        XCTAssertEqual(s.prompt, "Press Esc to dismiss")
    }

    // MARK: Random key

    func testRandomKeyIsStableForAState() {
        var rng = SeededRNG(seed: 42)
        let s = DismissChallengeState(challenge: .randomKey, rng: &rng)
        guard case let .randomKey(key) = s.kind else { return XCTFail("expected randomKey") }
        XCTAssertTrue(DismissChallengeState.randomKeyAlphabet.contains(key))
        XCTAssertFalse(s.escDismisses)
        XCTAssertFalse(s.allowsTapDismiss)
        XCTAssertEqual(s.prompt, "Press the \(key) key to dismiss")
    }

    func testRandomKeyMatchesCaseInsensitively() {
        var rng = SeededRNG(seed: 7)
        let s = DismissChallengeState(challenge: .randomKey, rng: &rng)
        guard case let .randomKey(key) = s.kind else { return XCTFail("expected randomKey") }

        // A different key is ignored; the required key (any case) dismisses.
        let wrong: Character = key == "Z" ? "A" : "Z"
        XCTAssertFalse(s.handle(character: wrong))
        XCTAssertTrue(s.handle(character: Character(key.lowercased())))
    }

    // MARK: Type to dismiss

    func testTypeStringExactMatchDismisses() {
        let s = DismissChallengeState(challenge: .typeString("bed"))
        XCTAssertFalse(s.handle(character: "b"))
        XCTAssertEqual(s.typed, "b")
        XCTAssertFalse(s.handle(character: "e"))
        XCTAssertTrue(s.handle(character: "d"))
        XCTAssertEqual(s.typed, "bed")
    }

    func testTypeStringWrongCharacterResetsBuffer() {
        let s = DismissChallengeState(challenge: .typeString("bed"))
        _ = s.handle(character: "b")
        _ = s.handle(character: "x") // wrong: not a prefix of "bed"
        XCTAssertEqual(s.typed, "", "a non-matching keystroke clears progress")
        // Still dismissable by typing the phrase fresh.
        _ = s.handle(character: "b")
        _ = s.handle(character: "e")
        XCTAssertTrue(s.handle(character: "d"))
    }

    func testTypeStringWrongCharThatStartsPhraseRestarts() {
        let s = DismissChallengeState(challenge: .typeString("bb"))
        _ = s.handle(character: "b")   // typed = "b"
        _ = s.handle(character: "a")   // wrong, but "b"-restart not triggered by "a"
        XCTAssertEqual(s.typed, "")
        _ = s.handle(character: "b")   // typed = "b"
        XCTAssertTrue(s.handle(character: "b")) // typed = "bb" -> dismiss
    }

    func testBackspaceEditsBuffer() {
        let s = DismissChallengeState(challenge: .typeString("bed"))
        _ = s.handle(character: "b")
        _ = s.handle(character: "e")
        s.deleteBackward()
        XCTAssertEqual(s.typed, "b")
        s.deleteBackward()
        XCTAssertEqual(s.typed, "")
        s.deleteBackward() // no-op on empty buffer
        XCTAssertEqual(s.typed, "")
    }

    func testTypeStringPrompt() {
        let s = DismissChallengeState(challenge: .typeString("go to bed"))
        XCTAssertEqual(s.prompt, "Type \u{201C}go to bed\u{201D} to dismiss")
        XCTAssertFalse(s.escDismisses)
    }
}
