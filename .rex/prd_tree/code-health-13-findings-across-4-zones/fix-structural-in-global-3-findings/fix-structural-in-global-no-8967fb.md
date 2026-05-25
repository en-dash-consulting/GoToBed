---
id: "8967fb56-9233-47c1-9f6a-89d0d7652733"
level: "task"
title: "Fix structural in global: No automated enforcement of cross-zone layering exists: the architectural bounda (+2 more)"
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-25T03:45:20.822Z"
completedAt: "2026-05-25T03:50:28.253Z"
endedAt: "2026-05-25T03:50:28.253Z"
resolutionType: "code-change"
resolutionDetail: "Added scripts/check-zone-layering.sh enforcing the three intra-module zone boundaries within GoToBedKit; wired into make validate and CI."
acceptanceCriteria: []
description: "- No automated enforcement of cross-zone layering exists: the architectural boundary between domain (project-root-models), UI (settings-ui, overlay-ui), and composition (app-lifecycle) is expressed only by file organization, not by Swift module visibility rules or CI checks — this boundary will erode silently as the codebase grows.\n- The full inter-service event chain (Store → SchedulerEngine → AppEnvironment closure → OverlayController) is tested by no automated path; a regression in any link would only surface at runtime.\n- Add a Swift Package Manager build-phase script or a CI lint rule that verifies GoToBedCore compiles with no AppKit or SwiftUI imports; this makes the UI-framework-free constraint machine-enforced rather than convention-only and will catch accidental framework imports before they reach main."
recommendationMeta: {"findingHashes":["17956696e1f1","b392eb569e5b","6b11ec6e6ad2"],"category":"structural","severityDistribution":{"warning":3},"findingCount":3}
---
