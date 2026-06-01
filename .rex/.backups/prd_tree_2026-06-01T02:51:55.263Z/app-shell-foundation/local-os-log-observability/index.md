---
id: "129b2f04-2e28-43f3-ba30-74c5e657e1b8"
level: "feature"
title: "Local os_log observability"
status: "completed"
priority: "medium"
tags:
  - "logging"
  - "observability"
blockedBy:
  - "168c542a-e60c-43f2-aa8f-c904077c01e2"
source: "PRD.md §4.8"
startedAt: "2026-05-21T12:46:02.814Z"
completedAt: "2026-05-21T12:46:02.814Z"
endedAt: "2026-05-21T12:46:02.814Z"
acceptanceCriteria:
  - "Fires, sleep-skips, and dismissals are logged via os_log (NFR-obs-1)"
  - "Log categories are inspectable in Console.app"
description: "A lightweight local logging facility via os_log that records schedule fires, skips (sleep/grace), and dismissals to aid debugging of reliability issues. Used by the scheduler and overlay subsystems."
---

## Children

| Title | Status |
|-------|--------|
| [Add log points for fires, sleep-skips, and dismissals](./add-log-points-for-fires-sleep-fed8ff.md) | completed |
| [Define os_log Logger categories](./define-os-log-logger-categories.md) | completed |
