---
id: "c776a10e-8cfe-47a9-a2bb-080621ac4485"
level: "feature"
title: "Borderless full-screen overlay window"
status: "completed"
priority: "critical"
tags:
  - "overlay"
  - "appkit"
source: "PRD.md §3.2, §3.6, §5.4"
startedAt: "2026-05-21T13:18:11.403Z"
completedAt: "2026-05-21T13:18:11.403Z"
endedAt: "2026-05-21T13:18:11.403Z"
acceptanceCriteria:
  - "Overlay covers the active display including menu bar and Dock (FR-6)"
  - "Window level/collectionBehavior verified on macOS 13 (early prototype — risk item)"
  - "No crash/misbehavior when displays connect or disconnect while idle (FR-17)"
description: "A borderless NSWindow sized to the active screen (the one with the menu bar), at a high level (screensaver/CGShieldingWindowLevel) with collectionBehavior to appear across spaces and over fullscreen apps, covering the menu bar and Dock. Hosts SwiftUI content via NSHostingView. Must not crash on display connect/disconnect while idle."
---

## Children

| Title | Status |
|-------|--------|
| [Create borderless NSWindow at shield level sized to active screen](./create-borderless-nswindow-at-9a4eb0.md) | completed |
| [Prototype window level on macOS 13; handle display connect/disconnect](./prototype-window-level-on-macos-9f678e.md) | completed |
| [Set collectionBehavior and host NSHostingView](./set-collectionbehavior-and-host-b1f7fe.md) | completed |
