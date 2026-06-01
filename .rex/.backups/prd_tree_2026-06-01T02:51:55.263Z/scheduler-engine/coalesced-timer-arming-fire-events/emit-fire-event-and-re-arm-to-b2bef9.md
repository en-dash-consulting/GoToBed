---
id: "b2bef986-6ee1-460d-a5c7-6a7b19d71148"
level: "task"
title: "Emit fire event and re-arm to next occurrence"
status: "completed"
priority: "critical"
startedAt: "2026-05-21T12:46:29.461Z"
completedAt: "2026-05-21T12:46:29.461Z"
endedAt: "2026-05-21T12:46:29.461Z"
resolutionType: "code-change"
resolutionDetail: "On fire, SchedulerEngine re-reads the schedule, calls onFire (overlay), then rearm(). Loop logic verified by SchedulerLoopTests."
acceptanceCriteria: []
description: "On fire, publish the firing schedule to the overlay presenter, then recompute and re-arm."
---
