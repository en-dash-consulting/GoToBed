---
id: "6cc56270-bae8-4679-8596-1719416140fe"
level: "feature"
title: "Fix code in scheduler-engine (1 finding)"
status: "pending"
priority: "high"
source: "sourcevision"
acceptanceCriteria: []
description: "- SchedulerEngine.onFire is declared as an optional untyped closure with no named interface; an unwired scheduler silently drops all fire events — introduce a named delegate protocol or require the callback at init time to enforce the contract at compile time"
recommendationMeta: {"findingHashes":["efec6dfc606d"],"category":"code","severityDistribution":{"warning":1},"findingCount":1}
---

## Children

| Title | Status |
|-------|--------|
| [Fix code in scheduler-engine: SchedulerEngine.onFire is declared as an optional untyped closure with no named ](./fix-code-in-scheduler-engine-89e673.md) | pending |
