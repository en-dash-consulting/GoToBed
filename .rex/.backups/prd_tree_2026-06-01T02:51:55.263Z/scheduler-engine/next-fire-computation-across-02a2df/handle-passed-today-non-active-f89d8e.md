---
id: "f89d8e59-07dc-4b4d-9993-f0f4e2befbf4"
level: "task"
title: "Handle passed-today / non-active-day → next active occurrence"
status: "completed"
priority: "critical"
startedAt: "2026-05-21T12:46:23.127Z"
completedAt: "2026-05-21T12:46:23.127Z"
endedAt: "2026-05-21T12:46:23.127Z"
resolutionType: "code-change"
resolutionDetail: "Strictly-after-now computation gives FR-4 for free; testPassedTodayFiresNextWeek + testNonActiveDayFiresOnNextActiveDay."
acceptanceCriteria: []
description: "Ensure newly created/enabled schedules never fire immediately (FR-4)."
---
