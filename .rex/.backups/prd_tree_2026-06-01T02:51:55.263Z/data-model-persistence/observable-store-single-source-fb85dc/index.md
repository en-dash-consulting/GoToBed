---
id: "fb85dca8-09c7-4425-b613-00d0904b8888"
level: "feature"
title: "Observable Store (single source of truth)"
status: "completed"
priority: "high"
tags:
  - "model"
  - "state"
blockedBy:
  - "135e8159-b79a-4aab-9676-2aead185f023"
source: "PRD.md §5.2"
startedAt: "2026-05-21T12:46:11.523Z"
completedAt: "2026-05-21T12:46:11.523Z"
endedAt: "2026-05-21T12:46:11.523Z"
acceptanceCriteria:
  - "Store is observable; UI and scheduler react to changes"
  - "Create/edit/delete schedule and edit default appearance supported"
  - "New schedules inherit current default appearance (FR-15)"
description: "An observable Store that owns AppState as the single source of truth, exposes CRUD on schedules and the default appearance, and notifies observers (UI and scheduler) of changes. New schedules are seeded from the app-wide default appearance."
---

## Children

| Title | Status |
|-------|--------|
| [Implement observable Store owning AppState with CRUD](./implement-observable-store-ceb9bf.md) | completed |
| [Seed new schedules from default appearance](./seed-new-schedules-from-default-e2760f.md) | completed |
