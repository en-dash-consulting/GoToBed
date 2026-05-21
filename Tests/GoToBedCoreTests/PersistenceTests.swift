import XCTest
@testable import GoToBedCore

final class PersistenceTests: XCTestCase {
    private func tempURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("gotobed-tests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("state.json")
    }

    func testRoundTripPreservesState() throws {
        let url = tempURL()
        let store = AppStatePersistence(fileURL: url)
        var state = AppState()
        state.schedules = [Schedule(hour: 22, minute: 30, weekdays: [2, 3], message: "Bed")]
        state.launchAtLogin = true

        try store.save(state)
        let loaded = AppStatePersistence(fileURL: url).load()
        XCTAssertEqual(loaded, state)
    }

    func testMissingFileReturnsEmpty() {
        let loaded = AppStatePersistence(fileURL: tempURL()).load()
        XCTAssertEqual(loaded, .empty)
    }

    // NFR-persist-2: a corrupt file degrades gracefully to defaults, not a crash.
    func testCorruptFileFallsBackToDefaults() throws {
        let url = tempURL()
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("{ this is not valid json ]".utf8).write(to: url)

        let loaded = AppStatePersistence(fileURL: url).load()
        XCTAssertEqual(loaded, .empty)
    }

    func testStoredFormatIsHumanReadableJSON() throws {
        let url = tempURL()
        let store = AppStatePersistence(fileURL: url)
        try store.save(AppState(schedules: [Schedule(hour: 7, minute: 0, weekdays: [2], message: "Hi")]))
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(text.contains("\"message\""))
        XCTAssertTrue(text.contains("\n")) // pretty-printed
    }
}
