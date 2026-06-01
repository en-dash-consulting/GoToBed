---
id: "6ad629cd-e745-4dbb-9e05-f99a10f3312b"
level: "task"
title: "Add graceful decode-failure fallback to defaults with logging"
status: "completed"
priority: "high"
startedAt: "2026-05-21T12:46:14.788Z"
completedAt: "2026-05-21T12:46:14.788Z"
endedAt: "2026-05-21T12:46:14.788Z"
resolutionType: "code-change"
resolutionDetail: "load() returns .empty + logs on decode failure; PersistenceTests.testCorruptFileFallsBackToDefaults covers it."
acceptanceCriteria: []
description: "On corrupt/missing file, load defaults and log instead of crashing (NFR-persist-2)."
---
