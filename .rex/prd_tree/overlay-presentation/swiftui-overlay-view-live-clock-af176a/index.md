---
id: "af176a2a-dda4-483b-92cc-f43426f3b1c5"
level: "feature"
title: "SwiftUI overlay view (live clock + message)"
status: "completed"
priority: "high"
tags:
  - "overlay"
  - "swiftui"
source: "PRD.md §3.2 FR-7, §6, §4.3"
startedAt: "2026-05-21T12:46:48.610Z"
completedAt: "2026-05-21T12:46:48.610Z"
endedAt: "2026-05-21T12:46:48.610Z"
acceptanceCriteria:
  - "Clock updates live ≥1/sec; message displayed (FR-7)"
  - "View styled by the firing schedule's appearance (FR-13/14)"
  - "Legible at default settings on Retina/non-Retina without clipping (NFR-use-3)"
  - "Live clock CPU < 1% on a single core (NFR-perf-3)"
description: "The SwiftUI overlay content: a large centered live clock updating at least once per second, the schedule's message below it, and a subtle dismiss hint. Styled by the firing schedule's AppearanceSettings (colors, font sizes). Legible on Retina and non-Retina; respects large-size choices without clipping."
---

## Children

| Title | Status |
|-------|--------|
| [Build overlay layout: centered live clock, message, dismiss hint](./build-overlay-layout-centered-c1222b.md) | completed |
| [Drive live clock with 1s timeline; style from AppearanceSettings](./drive-live-clock-with-1s-45e8c1.md) | completed |
