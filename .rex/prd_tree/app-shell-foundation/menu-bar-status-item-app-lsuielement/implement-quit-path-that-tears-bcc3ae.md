---
id: "bcc3aebd-1166-405a-839b-b54718e14b66"
level: "task"
title: "Implement quit path that tears down scheduler and timers"
status: "completed"
priority: "medium"
startedAt: "2026-05-21T12:45:59.257Z"
completedAt: "2026-05-21T12:45:59.257Z"
endedAt: "2026-05-21T12:45:59.257Z"
resolutionType: "code-change"
resolutionDetail: "AppDelegate.applicationWillTerminate calls AppEnvironment.shutdown() which stops the scheduler and dismisses any overlay."
acceptanceCriteria: []
description: "On quit, invalidate timers and stop scheduling so no work persists after exit (FR-21)."
---
