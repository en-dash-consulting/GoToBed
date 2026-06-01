---
id: "6675c08e-5070-403c-9562-072d2188606e"
level: "task"
title: "Skip and log occurrences missed during sleep (never replay)"
status: "completed"
priority: "critical"
startedAt: "2026-05-21T12:46:34.974Z"
completedAt: "2026-05-21T12:46:34.974Z"
endedAt: "2026-05-21T12:46:34.974Z"
resolutionType: "code-change"
resolutionDetail: "Recompute-forward invariant means missed-during-sleep occurrences are never produced; wake logs the recompute. SleepSkipTests assert no replay."
acceptanceCriteria: []
description: "Ensure a time that passed during sleep does not fire on wake; log the skip (NFR-rel-2)."
---
