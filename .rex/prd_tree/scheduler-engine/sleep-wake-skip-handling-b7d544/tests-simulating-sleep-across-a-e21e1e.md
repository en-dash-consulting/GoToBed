---
id: "e21e1e84-a478-4883-8f23-0a2e0b56bec7"
level: "task"
title: "Tests simulating sleep across a scheduled time"
status: "completed"
priority: "high"
startedAt: "2026-05-21T12:46:36.835Z"
completedAt: "2026-05-21T12:46:36.835Z"
endedAt: "2026-05-21T12:46:36.835Z"
resolutionType: "code-change"
resolutionDetail: "SleepSkipTests simulate wake after a missed fire (single + multi-day) and exact-boundary recompute; all assert next future occurrence, no replay."
acceptanceCriteria: []
description: "Inject a clock to simulate a wake after a missed fire and assert skip + correct re-arm (AC-8)."
---
