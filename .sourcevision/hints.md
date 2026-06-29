<!-- Sourcevision Hints -->
<!-- Project context that guides AI-generated zone names, descriptions, and insights. -->

GoToBed is a native macOS menu-bar app built with SwiftPM (AppKit + SwiftUI),
organized into layered targets: GoToBedCore (pure logic — models, persistence,
schedule math, appearance), GoToBedKit (the AppKit/SwiftUI app layer — scheduler
engine, overlay, menu bar, settings UI), and the GoToBed executable.

There are two separate test targets under Tests/ — give their zones distinct
names rather than both "Tests":
- Tests/GoToBedCoreTests/ → "Core Tests" (unit tests for the GoToBedCore logic layer)
- Tests/GoToBedTests/     → "Kit Tests" (tests for the GoToBedKit app layer:
  scheduler engine, overlay controller, inter-service wiring)
