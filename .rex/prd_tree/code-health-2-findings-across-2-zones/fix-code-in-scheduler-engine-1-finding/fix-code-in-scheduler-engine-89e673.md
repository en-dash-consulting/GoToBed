---
id: "89e6735e-c0a9-4620-b0ad-85feecfc92f7"
level: "task"
title: "Fix code in scheduler-engine: SchedulerEngine.onFire is declared as an optional untyped closure with no named "
status: "pending"
priority: "high"
source: "sourcevision"
acceptanceCriteria: []
description: "- SchedulerEngine.onFire is declared as an optional untyped closure with no named interface; an unwired scheduler silently drops all fire events — introduce a named delegate protocol or require the callback at init time to enforce the contract at compile time"
recommendationMeta: {"findingHashes":["efec6dfc606d"],"category":"code","severityDistribution":{"warning":1},"findingCount":1}
---
