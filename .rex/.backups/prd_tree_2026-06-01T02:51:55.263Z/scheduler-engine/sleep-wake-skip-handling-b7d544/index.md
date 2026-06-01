---
id: "b7d5445b-5041-41ea-ac7f-a497419e771b"
level: "feature"
title: "Sleep/wake skip handling (recompute-forward)"
status: "completed"
priority: "critical"
tags:
  - "scheduler"
  - "high-risk"
  - "sleep"
source: "PRD.md §3.1 FR-5a, §4.1 NFR-rel-2, §5.5"
startedAt: "2026-05-21T12:46:36.906Z"
completedAt: "2026-05-21T12:46:36.906Z"
endedAt: "2026-05-21T12:46:36.906Z"
acceptanceCriteria:
  - "An occurrence falling during sleep does not fire on wake; it is skipped and logged (AC-8, NFR-rel-2)"
  - "After wake, the next future occurrence is armed correctly"
  - "Recompute-forward logic covered by automated tests"
description: "Fire only while the Mac is awake. On NSWorkspace.didWakeNotification, recompute all next-fire dates forward from now, discarding any occurrence whose time passed during sleep — so a missed-during-sleep time is skipped and logged, never replayed on wake. The single most bug-prone area; must be explicitly tested."
---

## Children

| Title | Status |
|-------|--------|
| [Observe didWakeNotification and recompute-forward-from-now](./observe-didwakenotification-and-639144.md) | completed |
| [Skip and log occurrences missed during sleep (never replay)](./skip-and-log-occurrences-missed-6675c0.md) | completed |
| [Tests simulating sleep across a scheduled time](./tests-simulating-sleep-across-a-e21e1e.md) | completed |
