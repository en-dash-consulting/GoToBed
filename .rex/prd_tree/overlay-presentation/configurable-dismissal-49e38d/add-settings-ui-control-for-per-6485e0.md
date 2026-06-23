---
id: "6485e074-0b01-4456-b5c0-dba0c4c0a58e"
level: "task"
title: "Add settings UI control for per-schedule dismissal mode"
status: "pending"
priority: "medium"
tags:
  - "settings"
  - "ui"
  - "dismissal"
blockedBy:
  - "0556b490-6043-462d-8f15-d21856ed7789"
source: "/ndx-capture — conversation 2026-06-22"
acceptanceCriteria:
  - "Settings UI exposes a dismissal-mode picker per schedule"
  - "Selecting Type-to-dismiss reveals a text box for the determined string"
  - "Selection persists to the schedule and is honored by the overlay"
description: "In the schedule settings UI, add a control to choose the dismissal mode (Esc / Random key / Type-to-dismiss). When Type-to-dismiss is selected, show a text box to enter the determined string. Bind to the new schedule model field; reflect changes on save."
---
