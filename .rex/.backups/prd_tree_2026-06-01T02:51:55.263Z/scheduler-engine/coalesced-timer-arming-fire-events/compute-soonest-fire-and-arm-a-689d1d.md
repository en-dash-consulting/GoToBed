---
id: "689d1d85-fd6a-4b54-9829-94433db66059"
level: "task"
title: "Compute soonest fire and arm a single coalesced timer"
status: "completed"
priority: "critical"
startedAt: "2026-05-21T12:46:27.071Z"
completedAt: "2026-05-21T12:46:27.071Z"
endedAt: "2026-05-21T12:46:27.071Z"
resolutionType: "code-change"
resolutionDetail: "SchedulerEngine.rearm computes nextFire across schedules and arms a single Timer with tolerance."
acceptanceCriteria: []
description: "Find the minimum next-fire across all enabled schedules and schedule one timer to it."
---
