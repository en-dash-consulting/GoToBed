---
id: "89e6735e-c0a9-4620-b0ad-85feecfc92f7"
level: "task"
title: "Fix code in scheduler-engine: SchedulerEngine.onFire is declared as an optional untyped closure with no named "
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-28T03:57:19.475Z"
completedAt: "2026-05-28T03:57:19.475Z"
endedAt: "2026-05-28T03:57:19.475Z"
resolutionType: "code-change"
resolutionDetail: "SchedulerEngine.onFire changed from optional `((Schedule) -> Void)?` to non-optional `(Schedule) -> Void` required at init. An unwired scheduler can no longer exist — the compile-time check replaces the silent-drop risk. Kept as `var` (not `let`) so tests can swap handlers. Updated 10 test call sites + AppEnvironment to pass onFire at construction."
acceptanceCriteria: []
description: "- SchedulerEngine.onFire is declared as an optional untyped closure with no named interface; an unwired scheduler silently drops all fire events — introduce a named delegate protocol or require the callback at init time to enforce the contract at compile time"
recommendationMeta: {"findingHashes":["efec6dfc606d"],"category":"code","severityDistribution":{"warning":1},"findingCount":1}
---
