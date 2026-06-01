---
id: "65f65a55-f55b-4d4e-aaef-1a06e88fc536"
level: "epic"
title: "Scheduler Engine"
status: "completed"
priority: "critical"
tags:
  - "scheduler"
  - "timing"
  - "high-risk"
blockedBy:
  - "135e8159-b79a-4aab-9676-2aead185f023"
source: "PRD.md §3.1, §5.5, §4.1"
startedAt: "2026-05-21T12:46:41.290Z"
completedAt: "2026-05-21T12:46:41.290Z"
endedAt: "2026-05-21T12:46:41.290Z"
description: "The timing core: computes each enabled schedule's next weekly fire date, arms a single coalesced timer to the soonest event, and emits fire events. Handles sleep/wake by recomputing forward from now (skip, never replay missed occurrences) and recomputes on system clock/timezone/DST changes. Highest-risk area — must fire within ±2s while awake and run ≥30 days without drift or timer leaks."
---

## Children

| Title | Status |
|-------|--------|
| [Clock/timezone/DST change recomputation](./clock-timezone-dst-change-recomputation/index.md) | completed |
| [Coalesced timer arming & fire events](./coalesced-timer-arming-fire-events/index.md) | completed |
| [Fix code in scheduler-engine (1 finding)](./fix-code-in-scheduler-engine-1-finding/index.md) | completed |
| [Next-fire computation across active weekdays](./next-fire-computation-across-02a2df/index.md) | completed |
| [Sleep/wake skip handling (recompute-forward)](./sleep-wake-skip-handling-b7d544/index.md) | completed |
