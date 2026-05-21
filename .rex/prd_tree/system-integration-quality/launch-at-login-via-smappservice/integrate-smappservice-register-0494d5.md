---
id: "0494d536-8092-4b86-9be9-4d8f5aa7ddd4"
level: "task"
title: "Integrate SMAppService register/unregister; reflect state in UI"
status: "completed"
priority: "medium"
startedAt: "2026-05-21T12:47:37.850Z"
completedAt: "2026-05-21T12:47:37.850Z"
endedAt: "2026-05-21T12:47:37.850Z"
resolutionType: "code-change"
resolutionDetail: "LaunchAtLogin wraps SMAppService.mainApp register/unregister; menu toggle reads status and writes through AppEnvironment."
acceptanceCriteria: []
description: "Toggle launch-at-login via SMAppService (off by default) and keep the menu/settings toggle in sync."
---
