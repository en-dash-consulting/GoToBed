---
id: "639144dd-9eb5-4cdb-945e-3241443da85b"
level: "task"
title: "Observe didWakeNotification and recompute-forward-from-now"
status: "completed"
priority: "critical"
startedAt: "2026-05-21T12:46:32.705Z"
completedAt: "2026-05-21T12:46:32.705Z"
endedAt: "2026-05-21T12:46:32.705Z"
resolutionType: "code-change"
resolutionDetail: "SchedulerEngine observes NSWorkspace.didWakeNotification and calls rearm(), which recomputes strictly forward from now."
acceptanceCriteria: []
description: "On wake, discard all stale next-fire dates and recompute from the current time."
---
