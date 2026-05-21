---
id: "9b106b26-f412-4164-a797-b5658e5d58fa"
level: "task"
title: "Configure universal binary + code signing; verify no network calls"
status: "completed"
priority: "medium"
startedAt: "2026-05-21T12:47:42.491Z"
completedAt: "2026-05-21T12:47:42.491Z"
endedAt: "2026-05-21T12:47:42.491Z"
resolutionType: "code-change"
resolutionDetail: "scripts/build-app.sh builds universal arm64+x86_64, assembles GoToBed.app, codesigns with entitlements; verify-no-network.sh asserts no networking APIs/entitlements."
acceptanceCriteria: []
description: "Code-sign the universal build for local use; verify zero network connections at runtime (AC-11)."
---
