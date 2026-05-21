// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GoToBed",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        // Pure-logic core: models, persistence, schedule math, appearance.
        // Fully unit-testable without a running app or UI.
        .target(
            name: "GoToBedCore"
        ),
        // The menu-bar app: AppKit/SwiftUI glue around GoToBedCore.
        .executableTarget(
            name: "GoToBed",
            dependencies: ["GoToBedCore"]
        ),
        .testTarget(
            name: "GoToBedCoreTests",
            dependencies: ["GoToBedCore"]
        ),
    ],
    // App glue interoperates with AppKit timer/notification callbacks; we adopt
    // the Swift 6 toolchain in Swift 5 language mode and migrate incrementally.
    swiftLanguageModes: [.v5]
)
