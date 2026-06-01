---
id: "4ef58418-efd2-42fd-b619-232c80a01f1f"
level: "task"
title: "Configure universal binary build settings and Info.plist (LSUIElement)"
status: "completed"
priority: "high"
startedAt: "2026-05-21T12:45:53.092Z"
completedAt: "2026-05-21T12:45:53.092Z"
endedAt: "2026-05-21T12:45:53.092Z"
resolutionType: "code-change"
resolutionDetail: "Packaging/Info.plist sets LSUIElement; scripts/build-app.sh builds a universal (arm64+x86_64) bundle; runtime accessory policy enforces no Dock icon."
acceptanceCriteria: []
description: "Set arm64+x86_64 universal build and add Info.plist keys including LSUIElement=true."
---
