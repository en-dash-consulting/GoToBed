import XCTest
@testable import GoToBedCore

final class SubmessageTests: XCTestCase {
    func testSubmessageRoundTrips() throws {
        let s = Schedule(hour: 9, minute: 0, weekdays: [2], message: "Primary", submessage: "Secondary")
        let data = try JSONEncoder().encode(s)
        let decoded = try JSONDecoder().decode(Schedule.self, from: data)
        XCTAssertEqual(decoded.message, "Primary")
        XCTAssertEqual(decoded.submessage, "Secondary")
    }

    // Backward compatibility (NFR-persist-2): schedules saved before submessage
    // existed still decode, defaulting submessage to "".
    func testDecodingLegacyScheduleWithoutSubmessageKey() throws {
        let original = Schedule(hour: 9, minute: 0, weekdays: [2], message: "Hi", submessage: "x")
        let data = try JSONEncoder().encode(original)
        var dict = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        dict.removeValue(forKey: "submessage")
        let legacy = try JSONSerialization.data(withJSONObject: dict)

        let decoded = try JSONDecoder().decode(Schedule.self, from: legacy)
        XCTAssertEqual(decoded.submessage, "")
        XCTAssertEqual(decoded.message, "Hi")
    }

    func testSubmessageTooLongIsValidatedAndSanitized() {
        let long = String(repeating: "b", count: Schedule.maxMessageLength + 1)
        let s = Schedule(hour: 1, minute: 0, weekdays: [2], message: "ok", submessage: long)
        XCTAssertTrue(s.validationErrors().contains(.submessageTooLong(long.count)))
        XCTAssertEqual(s.sanitized().submessage.count, Schedule.maxMessageLength)
    }

    func testEmptySubmessageIsValid() {
        let s = Schedule(hour: 1, minute: 0, weekdays: [2], message: "ok")
        XCTAssertTrue(s.isValid)
        XCTAssertEqual(s.submessage, "")
    }
}
