import XCTest
@testable import GoToBedCore

/// NFR-use-4: warn when text/background contrast is too low to read.
final class ContrastTests: XCTestCase {
    func testWhiteOnBlackIsHighContrast() {
        let a = AppearanceSettings(backgroundColor: .black, textColor: .white,
                                   clockFontSize: 100, messageFontSize: 30)
        XCTAssertFalse(a.hasLowContrast)
        XCTAssertEqual(a.contrastRatio, 21, accuracy: 0.5)
    }

    func testLightGrayOnWhiteIsLowContrast() {
        let lightGray = ColorComponents(red: 0.85, green: 0.85, blue: 0.85)
        let a = AppearanceSettings(backgroundColor: .white, textColor: lightGray,
                                   clockFontSize: 100, messageFontSize: 30)
        XCTAssertTrue(a.hasLowContrast)
    }

    func testAppDefaultIsReadable() {
        XCTAssertFalse(AppearanceSettings.appDefault.hasLowContrast)
    }

    func testTranslucentBackgroundJudgedOverBlack() {
        // Nearly transparent dark bg with light text -> still readable on the
        // dark overlay (composited over black).
        let bg = ColorComponents(red: 0, green: 0, blue: 0, alpha: 0.3)
        let a = AppearanceSettings(backgroundColor: bg, textColor: .white,
                                   clockFontSize: 100, messageFontSize: 30)
        XCTAssertFalse(a.hasLowContrast)
    }

    func testColorComponentsClampsOutOfRange() {
        let c = ColorComponents(red: 2, green: -1, blue: 0.5, alpha: 5)
        XCTAssertEqual(c.red, 1)
        XCTAssertEqual(c.green, 0)
        XCTAssertEqual(c.alpha, 1)
    }
}
