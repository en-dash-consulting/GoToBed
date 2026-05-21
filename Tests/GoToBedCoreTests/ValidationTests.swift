import XCTest
@testable import GoToBedCore

final class ValidationTests: XCTestCase {
    func testValidScheduleHasNoErrors() {
        let s = Schedule(hour: 22, minute: 30, weekdays: [2, 3], message: "ok")
        XCTAssertTrue(s.isValid)
        XCTAssertEqual(s.validationErrors(), [])
    }

    func testEmptyWeekdaysIsInvalid() {
        let s = Schedule(hour: 22, minute: 30, weekdays: [], message: "x")
        XCTAssertTrue(s.validationErrors().contains(.emptyWeekdays))
    }

    func testOutOfRangeFieldsReported() {
        let s = Schedule(hour: 25, minute: 70, weekdays: [9], message: "x")
        let errors = s.validationErrors()
        XCTAssertTrue(errors.contains(.hourOutOfRange(25)))
        XCTAssertTrue(errors.contains(.minuteOutOfRange(70)))
        XCTAssertTrue(errors.contains(.invalidWeekday(9)))
    }

    func testDurationOutOfRangeReported() {
        let tooLong = Schedule(hour: 1, minute: 0, weekdays: [2], message: "x",
                               dismissMode: .auto(seconds: 99999))
        XCTAssertTrue(tooLong.validationErrors().contains(.durationOutOfRange(99999)))
        let tooShort = Schedule(hour: 1, minute: 0, weekdays: [2], message: "x",
                                dismissMode: .auto(seconds: 1))
        XCTAssertTrue(tooShort.validationErrors().contains(.durationOutOfRange(1)))
    }

    func testManualDismissHasNoDurationError() {
        let s = Schedule(hour: 1, minute: 0, weekdays: [2], message: "x", dismissMode: .manual)
        XCTAssertTrue(s.isValid)
    }

    func testMessageTooLongReported() {
        let long = String(repeating: "a", count: Schedule.maxMessageLength + 1)
        let s = Schedule(hour: 1, minute: 0, weekdays: [2], message: long)
        XCTAssertTrue(s.validationErrors().contains(.messageTooLong(long.count)))
    }

    func testSanitizeClampsValues() {
        let s = Schedule(hour: 30, minute: 99, weekdays: [2, 9], message: String(repeating: "a", count: 600),
                         dismissMode: .auto(seconds: 100000))
        let clean = s.sanitized()
        XCTAssertEqual(clean.hour, 23)
        XCTAssertEqual(clean.minute, 59)
        XCTAssertEqual(clean.weekdays, [2])
        XCTAssertEqual(clean.message.count, Schedule.maxMessageLength)
        XCTAssertEqual(clean.dismissMode.autoSeconds, Schedule.durationRange.upperBound)
        XCTAssertTrue(clean.isValid)
    }
}
