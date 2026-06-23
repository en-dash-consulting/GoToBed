---
id: "15d5b00d-2d57-467c-8747-b10903ad1f77"
level: "epic"
title: "Overlay Presentation"
status: "completed"
priority: "critical"
tags:
  - "overlay"
  - "appkit"
  - "swiftui"
blockedBy:
  - "135e8159-b79a-4aab-9676-2aead185f023"
source: "PRD.md §3.2-§3.6, §5.4"
startedAt: "2026-05-21T13:18:11.451Z"
completedAt: "2026-06-23T03:43:22.699Z"
endedAt: "2026-06-23T03:43:22.699Z"
description: "The full-screen \"soft overlay\" shown when a schedule fires: a borderless NSWindow at shield/screensaver level covering the active display, hosting a SwiftUI view with a live clock and the schedule's message. Implements auto and manual dismissal, escapability (Esc/Cmd-Tab/force-quit never trapped), collision replacement (newer wins), fade animation, and Reduce Motion."
---

## Children

| Title | Status |
|-------|--------|
| [Borderless full-screen overlay window](./borderless-full-screen-overlay-window/index.md) | completed |
| [Configurable dismissal challenge (random-key / type-to-dismiss)](./configurable-dismissal-49e38d/index.md) | completed |
| [Dismissal behavior (auto, manual, escapable)](./dismissal-behavior-auto-manual-ae287b/index.md) | completed |
| [Fade animation & Reduce Motion](./fade-animation-reduce-motion/index.md) | completed |
| [Overlay collision replacement (newer wins)](./overlay-collision-replacement-273974/index.md) | completed |
| [SwiftUI overlay view (live clock + message)](./swiftui-overlay-view-live-clock-af176a/index.md) | completed |
