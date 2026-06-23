---
id: "6485e074-0b01-4456-b5c0-dba0c4c0a58e"
level: "task"
title: "Add settings UI control for per-schedule dismissal mode"
status: "completed"
priority: "medium"
tags:
  - "settings"
  - "ui"
  - "dismissal"
blockedBy:
  - "0556b490-6043-462d-8f15-d21856ed7789"
source: "/ndx-capture — conversation 2026-06-22"
startedAt: "2026-06-23T03:42:38.162Z"
completedAt: "2026-06-23T03:43:22.544Z"
endedAt: "2026-06-23T03:43:22.544Z"
resolutionType: "code-change"
resolutionDetail: "Added a \"To dismiss\" picker (Press Esc / Press a random key / Type a phrase) to the Dismissal section of ScheduleEditorView, with a conditional TextField for the phrase when Type-a-phrase is selected and an inline warning when blank. Bindings write through to draft.dismissChallenge; a remembered typePhrase preserves the phrase across mode switches. Persists via the existing onChange→env.updateSchedule path (sanitized). Full `make validate` green (74 tests)."
acceptanceCriteria:
  - "Settings UI exposes a dismissal-mode picker per schedule"
  - "Selecting Type-to-dismiss reveals a text box for the determined string"
  - "Selection persists to the schedule and is honored by the overlay"
description: "In the schedule settings UI, add a control to choose the dismissal mode (Esc / Random key / Type-to-dismiss). When Type-to-dismiss is selected, show a text box to enter the determined string. Bind to the new schedule model field; reflect changes on save."
---
