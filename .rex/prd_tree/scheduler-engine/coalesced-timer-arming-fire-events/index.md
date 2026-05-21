---
id: "8a0632a3-f720-4346-8a8c-f0abd01f0149"
level: "feature"
title: "Coalesced timer arming & fire events"
status: "completed"
priority: "critical"
tags:
  - "scheduler"
  - "timing"
source: "PRD.md §5.5, §4.1"
startedAt: "2026-05-21T12:46:31.035Z"
completedAt: "2026-05-21T12:46:31.035Z"
endedAt: "2026-05-21T12:46:31.035Z"
acceptanceCriteria:
  - "Single coalesced timer targets the soonest event (FR-rel-1 ±2s)"
  - "On fire, emits event then re-arms to next occurrence"
  - "No timer leaks or drift over a 30-day soak (NFR-rel-4)"
description: "Arm a single coalesced timer to the soonest fire across all schedules (rather than N long-lived timers) to bound drift and resource use. On fire, emit a \"schedule fired\" event and recompute that schedule's next occurrence. Must fire within ±2s and run ≥30 days without drift or timer leaks."
---

## Children

| Title | Status |
|-------|--------|
| [Compute soonest fire and arm a single coalesced timer](./compute-soonest-fire-and-arm-a-689d1d.md) | completed |
| [Emit fire event and re-arm to next occurrence](./emit-fire-event-and-re-arm-to-b2bef9.md) | completed |
| [Re-coalesce timer on schedule changes; prevent leaks](./re-coalesce-timer-on-schedule-5e751c.md) | completed |
