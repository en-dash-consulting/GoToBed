---
id: "9eac467f-5359-4d5e-9142-aac19bfc79fb"
level: "task"
title: "Resolve same-minute collisions by creation order"
status: "completed"
priority: "low"
startedAt: "2026-05-21T12:46:57.992Z"
completedAt: "2026-05-21T12:46:57.992Z"
endedAt: "2026-05-21T12:46:57.992Z"
resolutionType: "code-change"
resolutionDetail: "nextFire uses <= tie-break so same-minute collisions resolve to the later schedule in creation order; testSameMinuteTieResolvesToLaterCreationOrder."
acceptanceCriteria: []
description: "Deterministic last-writer-wins ordering for two schedules at the same minute."
---
