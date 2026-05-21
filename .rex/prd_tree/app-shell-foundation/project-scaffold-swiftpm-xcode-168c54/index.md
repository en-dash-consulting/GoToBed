---
id: "168c542a-e60c-43f2-aa8f-c904077c01e2"
level: "feature"
title: "Project scaffold (SwiftPM/Xcode, universal, macOS 13+)"
status: "completed"
priority: "high"
tags:
  - "foundation"
  - "build"
source: "PRD.md §5.1, §4.4"
startedAt: "2026-05-21T12:45:53.900Z"
completedAt: "2026-05-21T12:45:53.900Z"
endedAt: "2026-05-21T12:45:53.900Z"
acceptanceCriteria:
  - "Project builds a runnable macOS 13+ universal .app"
  - "SwiftUI app entry point launches without a Dock icon"
  - "Build/test commands documented in repo"
description: "Create the buildable app project targeting macOS 13 (Ventura)+ as a universal binary (Apple Silicon + Intel), Swift + SwiftUI with AppKit interop. Produces a standalone .app that launches."
---

## Children

| Title | Status |
|-------|--------|
| [Add @main SwiftUI App entry point with AppDelegate hook](./add-main-swiftui-app-entry-456780.md) | completed |
| [Configure universal binary build settings and Info.plist (LSUIElement)](./configure-universal-binary-4ef584.md) | completed |
| [Initialize SwiftPM/Xcode project with macOS 13 target](./initialize-swiftpm-xcode-5d6ef2.md) | completed |
