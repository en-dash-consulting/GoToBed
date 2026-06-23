import XCTest
@testable import GoToBedCore

/// Tests for the per-schedule dismissal challenge: defaulting, persistence
/// round-trip, backward-compatible decoding, and validation/sanitization.
final class DismissChallengeTests: XCTestCase {

    func testDefaultChallengeIsEscape() {
        let s = Schedule(hour: 22, minute: 0, weekdays: [2], message: "Bed")
        XCTAssertEqual(s.dismissChallenge, .escape)
    }

    func testRoundTripPreservesChallenge() throws {
        for challenge in [DismissChallenge.escape, .randomKey, .typeString("go to bed")] {
            var s = Schedule(hour: 22, minute: 0, weekdays: [2], message: "Bed")
            s.dismissChallenge = challenge
            let data = try JSONEncoder().encode(s)
            let decoded = try JSONDecoder().decode(Schedule.self, from: data)
            XCTAssertEqual(decoded.dismissChallenge, challenge)
            XCTAssertEqual(decoded, s)
        }
    }

    // Schedules saved before this feature have no `dismissChallenge` key and
    // must decode to `.escape` rather than tripping the persistence fallback.
    func testLegacyJSONWithoutChallengeDecodesToEscape() throws {
        let appearance = String(decoding: try JSONEncoder().encode(AppearanceSettings.appDefault), as: UTF8.self)
        let legacy = """
        {
          "id": "\(UUID().uuidString)",
          "hour": 22, "minute": 30,
          "weekdays": [2, 3, 4],
          "message": "Bed", "submessage": "",
          "isEnabled": true,
          "dismissMode": { "manual": {} },
          "appearance": \(appearance)
        }
        """
        let decoded = try JSONDecoder().decode(Schedule.self, from: Data(legacy.utf8))
        XCTAssertEqual(decoded.dismissChallenge, .escape)
    }

    func testTypeStringTooLongIsInvalid() {
        let long = String(repeating: "a", count: DismissChallenge.maxTypeStringLength + 1)
        var s = Schedule(hour: 22, minute: 0, weekdays: [2], message: "Bed")
        s.dismissChallenge = .typeString(long)
        XCTAssertTrue(s.validationErrors().contains(.typeStringTooLong(long.count)))
    }

    func testSanitizeClampsLongTypeString() {
        let long = String(repeating: "a", count: DismissChallenge.maxTypeStringLength + 50)
        var s = Schedule(hour: 22, minute: 0, weekdays: [2], message: "Bed")
        s.dismissChallenge = .typeString(long)
        if case let .typeString(clamped) = s.sanitized().dismissChallenge {
            XCTAssertEqual(clamped.count, DismissChallenge.maxTypeStringLength)
        } else {
            XCTFail("Expected a clamped typeString challenge")
        }
    }

    func testSanitizeDowngradesBlankTypeStringToEscape() {
        var s = Schedule(hour: 22, minute: 0, weekdays: [2], message: "Bed")
        s.dismissChallenge = .typeString("   \n ")
        XCTAssertEqual(s.sanitized().dismissChallenge, .escape)
    }

    // A non-empty phrase with surrounding/internal whitespace is preserved as-is.
    func testSanitizePreservesNonBlankTypeString() {
        var s = Schedule(hour: 22, minute: 0, weekdays: [2], message: "Bed")
        s.dismissChallenge = .typeString("go to bed")
        XCTAssertEqual(s.sanitized().dismissChallenge, .typeString("go to bed"))
    }
}
