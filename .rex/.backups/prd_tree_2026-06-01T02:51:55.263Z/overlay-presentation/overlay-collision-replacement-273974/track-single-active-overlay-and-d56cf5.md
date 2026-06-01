---
id: "d56cf5ab-68e9-4d65-a340-64e08a7d78ee"
level: "task"
title: "Track single active overlay and replace on new fire"
status: "completed"
priority: "medium"
startedAt: "2026-05-21T12:46:56.150Z"
completedAt: "2026-05-21T12:46:56.150Z"
endedAt: "2026-05-21T12:46:56.150Z"
resolutionType: "code-change"
resolutionDetail: "OverlayController holds a single window ref; present() tears down any existing overlay first (newer wins)."
acceptanceCriteria: []
description: "Hold a reference to the current overlay; on a new fire, tear it down and show the new one (FR-16)."
---
