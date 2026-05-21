---
id: "eff20bd6-84d4-4db8-8123-92115b6650ef"
level: "feature"
title: "Schedule editor"
status: "completed"
priority: "high"
tags:
  - "ui"
  - "editor"
source: "PRD.md §3.1, §6"
startedAt: "2026-05-21T12:47:27.312Z"
completedAt: "2026-05-21T12:47:27.312Z"
endedAt: "2026-05-21T12:47:27.312Z"
acceptanceCriteria:
  - "Create, edit, delete schedules (FR-1)"
  - "All schedule fields editable with presets and validation (FR-2)"
  - "Duration stepper only appears in Auto mode; enforces 5-3600s"
description: "The SwiftUI schedule editor: time picker; day-of-week selector (seven toggles plus Every day / Weekdays / Weekends presets, at least one required); multi-line message field (~500 char cap); dismissal mode segmented control (Auto/Manual) with a duration stepper shown only for Auto (default 60s, 5–3600s); enabled toggle. Create/edit/delete schedules."
---

## Children

| Title | Status |
|-------|--------|
| [Add dismissal-mode control with conditional duration stepper and enabled toggle](./add-dismissal-mode-control-with-8d2cf3.md) | completed |
| [Build editor form: time picker, day selector with presets, message](./build-editor-form-time-picker-851339.md) | completed |
| [Wire create/edit/delete to Store with validation](./wire-create-edit-delete-to-e52433.md) | completed |
