---
id: "02a2df16-a695-4ed4-a06e-67209f3c59a8"
level: "feature"
title: "Next-fire computation across active weekdays"
status: "completed"
priority: "critical"
tags:
  - "scheduler"
  - "timing"
source: "PRD.md §3.1, §5.5"
startedAt: "2026-05-21T12:46:25.510Z"
completedAt: "2026-05-21T12:46:25.510Z"
endedAt: "2026-05-21T12:46:25.510Z"
acceptanceCriteria:
  - "Next-fire date is correct for arbitrary weekday subsets (FR-3)"
  - "A schedule whose time already passed today fires at next active occurrence, not immediately (FR-4)"
  - "Disabled schedules produce no fire date (FR-5)"
description: "Compute each enabled schedule's soonest next occurrence using Calendar.nextDate over its active weekdays (one candidate per weekday, take the minimum). Already-passed-today or non-active-day schedules resolve to the next active-day occurrence — never fire immediately on create/enable."
---

## Children

| Title | Status |
|-------|--------|
| [Handle passed-today / non-active-day → next active occurrence](./handle-passed-today-non-active-f89d8e.md) | completed |
| [Implement per-weekday next-occurrence computation](./implement-per-weekday-next-9d01f2.md) | completed |
| [Unit tests for weekday subsets and edge times](./unit-tests-for-weekday-subsets-c13d93.md) | completed |
