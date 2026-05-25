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
        // App-layer library: AppKit/SwiftUI glue around GoToBedCore.
        // Extracted from the executable so SchedulerEngine, OverlayController,
        // and AppEnvironment wiring can be unit-tested by GoToBedTests.
        .target(
            name: "GoToBedKit",
            dependencies: ["GoToBedCore"],
            path: "Sources/GoToBed"
        ),
        // The menu-bar app entry point: thin wrapper that wires AppKit lifecycle
        // to GoToBedKit's AppEnvironment singleton.
        .executableTarget(
            name: "GoToBed",
            dependencies: ["GoToBedKit", "GoToBedCore"],
            path: "Sources/GoToBedApp"
        ),
        .testTarget(
            name: "GoToBedCoreTests",
            dependencies: ["GoToBedCore"]
        ),
        // App-layer tests: SchedulerEngine, OverlayController, inter-service wiring.
        .testTarget(
            name: "GoToBedTests",
            dependencies: ["GoToBedKit", "GoToBedCore"]
        ),
    ],
    // App glue interoperates with AppKit timer/notification callbacks; we adopt
    // the Swift 6 toolchain in Swift 5 language mode and migrate incrementally.
    swiftLanguageModes: [.v5]
)
