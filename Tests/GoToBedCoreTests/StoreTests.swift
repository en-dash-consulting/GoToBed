import XCTest
@testable import GoToBedCore

final class StoreTests: XCTestCase {
    private func makeStore() -> Store {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("gotobed-store-\(UUID().uuidString)")
            .appendingPathComponent("state.json")
        return Store(persistence: AppStatePersistence(fileURL: url))
    }

    func testAddUpdateDelete() {
        let store = makeStore()
        let s = store.makeSchedule(hour: 22, minute: 30, weekdays: [2], message: "Bed")
        store.add(s)
        XCTAssertEqual(store.schedules.count, 1)

        var edited = s
        edited.message = "Sleep"
        store.update(edited)
        XCTAssertEqual(store.schedule(id: s.id)?.message, "Sleep")

        store.delete(id: s.id)
        XCTAssertTrue(store.schedules.isEmpty)
    }

    // FR-15: new schedules inherit the current default appearance.
    func testNewScheduleInheritsDefaultAppearance() {
        let store = makeStore()
        var newDefault = AppearanceSettings.appDefault
        newDefault.clockFontSize = 200
        store.updateDefaultAppearance(newDefault)

        let s = store.makeSchedule(hour: 1, minute: 0, weekdays: [2], message: "x")
        XCTAssertEqual(s.appearance.clockFontSize, 200)
    }

    // FR-15: editing the default does not retroactively change existing schedules.
    func testEditingDefaultDoesNotChangeExistingSchedules() {
        let store = makeStore()
        let s = store.makeSchedule(hour: 1, minute: 0, weekdays: [2], message: "x")
        store.add(s)
        let originalSize = s.appearance.clockFontSize

        var newDefault = AppearanceSettings.appDefault
        newDefault.clockFontSize = originalSize + 50
        store.updateDefaultAppearance(newDefault)

        XCTAssertEqual(store.schedule(id: s.id)?.appearance.clockFontSize, originalSize)
    }

    func testSetEnabledToggles() {
        let store = makeStore()
        let s = store.add(store.makeSchedule(hour: 1, minute: 0, weekdays: [2], message: "x"))
        store.setEnabled(false, id: s.id)
        XCTAssertEqual(store.schedule(id: s.id)?.isEnabled, false)
    }

    func testAddSanitizesInvalidSchedule() {
        let store = makeStore()
        let bad = Schedule(hour: 30, minute: 0, weekdays: [2, 99], message: "x")
        let added = store.add(bad)
        XCTAssertTrue(added.isValid)
        XCTAssertEqual(added.hour, 23)
        XCTAssertEqual(added.weekdays, [2])
    }

    func testPersistenceSurvivesReload() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("gotobed-reload-\(UUID().uuidString)")
            .appendingPathComponent("state.json")
        let store1 = Store(persistence: AppStatePersistence(fileURL: url))
        store1.add(store1.makeSchedule(hour: 7, minute: 0, weekdays: [2], message: "Hi"))

        let store2 = Store(persistence: AppStatePersistence(fileURL: url))
        XCTAssertEqual(store2.schedules.count, 1)
        XCTAssertEqual(store2.schedules.first?.message, "Hi")
    }
}
