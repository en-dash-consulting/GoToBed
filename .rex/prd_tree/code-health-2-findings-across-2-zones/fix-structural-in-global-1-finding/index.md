---
id: "234abacf-691d-491c-90e7-987b07fce602"
level: "feature"
title: "Fix structural in global (1 finding)"
status: "pending"
priority: "high"
source: "sourcevision"
acceptanceCriteria: []
description: "- Circular dependency chains are resolved via callback closures (scheduler.onFire wired by AppEnvironment) rather than restructured imports; this makes the import graph appear acyclic to static analysis while preserving runtime coupling cycles — document this in AppEnvironment to prevent future contributors from replacing closures with direct cross-zone imports"
recommendationMeta: {"findingHashes":["0013e714ee47"],"category":"structural","severityDistribution":{"warning":1},"findingCount":1}
---

## Children

| Title | Status |
|-------|--------|
| [Fix structural in global: Circular dependency chains are resolved via callback closures (scheduler.onFire ](./fix-structural-in-global-6c94e0.md) | pending |
