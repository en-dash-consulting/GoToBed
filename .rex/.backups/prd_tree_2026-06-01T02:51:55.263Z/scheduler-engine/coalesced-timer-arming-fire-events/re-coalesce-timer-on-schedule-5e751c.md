---
id: "5e751ccb-f681-4996-9276-b632bc78b123"
level: "task"
title: "Re-coalesce timer on schedule changes; prevent leaks"
status: "completed"
priority: "high"
startedAt: "2026-05-21T12:46:30.965Z"
completedAt: "2026-05-21T12:46:30.965Z"
endedAt: "2026-05-21T12:46:30.965Z"
resolutionType: "code-change"
resolutionDetail: "rearm() invalidates the prior Timer before arming; subscribes to store.objectWillChange to re-coalesce on edits. No accumulation."
acceptanceCriteria: []
description: "Invalidate and re-arm when schedules are added/edited/toggled; ensure no leaked timers."
---
