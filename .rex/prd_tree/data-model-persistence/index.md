---
id: "6c5657f4-b04c-4fd9-bd87-bc78be700ba2"
level: "epic"
title: "Data Model & Persistence"
status: "completed"
priority: "high"
tags:
  - "model"
  - "persistence"
blockedBy:
  - "168c542a-e60c-43f2-aa8f-c904077c01e2"
source: "PRD.md §5.3, §5.6, §4.6"
startedAt: "2026-05-21T12:46:14.903Z"
completedAt: "2026-05-21T12:46:14.903Z"
endedAt: "2026-05-21T12:46:14.903Z"
description: "The Codable domain model (Schedule, DismissMode, AppearanceSettings, AppState) and the single observable Store that owns app state. Persists schedules and appearance to local JSON with graceful degradation to defaults on decode failure. Survives restart, crash, and reboot (NFR-persist)."
---

## Children

| Title | Status |
|-------|--------|
| [Core domain model (Schedule, DismissMode, AppearanceSettings, AppState)](./core-domain-model-schedule-135e81/index.md) | completed |
| [JSON persistence with graceful fallback](./json-persistence-with-graceful-fallback/index.md) | completed |
| [Observable Store (single source of truth)](./observable-store-single-source-fb85dc/index.md) | completed |
