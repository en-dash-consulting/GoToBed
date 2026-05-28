---
id: "6c94e060-2a39-455f-9408-2ca891cd7f5e"
level: "task"
title: "Fix structural in global: Circular dependency chains are resolved via callback closures (scheduler.onFire "
status: "pending"
priority: "high"
source: "sourcevision"
acceptanceCriteria: []
description: "- Circular dependency chains are resolved via callback closures (scheduler.onFire wired by AppEnvironment) rather than restructured imports; this makes the import graph appear acyclic to static analysis while preserving runtime coupling cycles — document this in AppEnvironment to prevent future contributors from replacing closures with direct cross-zone imports"
recommendationMeta: {"findingHashes":["0013e714ee47"],"category":"structural","severityDistribution":{"warning":1},"findingCount":1}
---
