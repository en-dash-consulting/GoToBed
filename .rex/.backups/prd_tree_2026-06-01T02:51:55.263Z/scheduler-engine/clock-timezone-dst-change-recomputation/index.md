---
id: "2afc8857-c8c2-4f26-bbe2-59c264bfb740"
level: "feature"
title: "Clock/timezone/DST change recomputation"
status: "completed"
priority: "high"
tags:
  - "scheduler"
  - "timing"
source: "PRD.md §4.1 NFR-rel-3, §5.5"
startedAt: "2026-05-21T12:46:41.245Z"
completedAt: "2026-05-21T12:46:41.245Z"
endedAt: "2026-05-21T12:46:41.245Z"
acceptanceCriteria:
  - "Timers recompute on clock/timezone change notifications (NFR-rel-3)"
  - "DST transition does not cause double-fire or missed legitimate fire"
  - "Schedules interpreted in current local time"
description: "Keep scheduling correct across system clock changes, timezone changes, and DST transitions by interpreting schedules in current local time and recomputing all timers on NSSystemClockDidChange / NSSystemTimeZoneDidChange."
---

## Children

| Title | Status |
|-------|--------|
| [Observe clock/timezone change notifications and recompute timers](./observe-clock-timezone-change-1d012d.md) | completed |
| [Tests for DST transition correctness](./tests-for-dst-transition-correctness.md) | completed |
