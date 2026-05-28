---
id: "d1509356-712e-4f6d-a80a-c1c446877712"
level: "feature"
title: "Fix structural in global (3 findings)"
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-25T03:50:28.355Z"
completedAt: "2026-05-25T03:50:28.355Z"
endedAt: "2026-05-25T03:50:28.355Z"
acceptanceCriteria: []
description: "- No automated enforcement of cross-zone layering exists: the architectural boundary between domain (project-root-models), UI (settings-ui, overlay-ui), and composition (app-lifecycle) is expressed only by file organization, not by Swift module visibility rules or CI checks — this boundary will erode silently as the codebase grows.\n- The full inter-service event chain (Store → SchedulerEngine → AppEnvironment closure → OverlayController) is tested by no automated path; a regression in any link would only surface at runtime.\n- Add a Swift Package Manager build-phase script or a CI lint rule that verifies GoToBedCore compiles with no AppKit or SwiftUI imports; this makes the UI-framework-free constraint machine-enforced rather than convention-only and will catch accidental framework imports before they reach main."
recommendationMeta: {"findingHashes":["17956696e1f1","b392eb569e5b","6b11ec6e6ad2"],"category":"structural","severityDistribution":{"warning":3},"findingCount":3}
---

## Children

| Title | Status |
|-------|--------|
| [Fix structural in global: No automated enforcement of cross-zone layering exists: the architectural bounda (+2 more)](./fix-structural-in-global-no-8967fb.md) | completed |
