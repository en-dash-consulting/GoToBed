---
id: "135e8159-b79a-4aab-9676-2aead185f023"
level: "feature"
title: "Core domain model (Schedule, DismissMode, AppearanceSettings, AppState)"
status: "completed"
priority: "high"
tags:
  - "model"
source: "PRD.md §5.3"
startedAt: "2026-05-21T12:46:08.035Z"
completedAt: "2026-05-21T12:46:08.035Z"
endedAt: "2026-05-21T12:46:08.035Z"
acceptanceCriteria:
  - "Types match the §5.3 model and are Codable"
  - "Weekdays cannot be empty; duration constrained to 5-3600s; message capped ~500 chars"
  - "Round-trips through Codable without loss"
description: "The Codable value types: Schedule (id, hour, minute, weekdays Set, message, isEnabled, dismissMode, appearance), DismissMode (.auto(seconds:)/.manual), AppearanceSettings (RGBA bg/text colors, clock & message font sizes), and AppState (schedules + defaultAppearance). Includes validation invariants (non-empty weekdays, duration 5s–3600s, message cap ~500 chars)."
---

## Children

| Title | Status |
|-------|--------|
| [Add ColorComponents RGBA type with Codable](./add-colorcomponents-rgba-type-187714.md) | completed |
| [Add model validation (weekdays, duration, message cap)](./add-model-validation-weekdays-624a60.md) | completed |
| [Define Schedule/DismissMode/AppearanceSettings/AppState Codable types](./define-schedule-dismissmode-369a7e.md) | completed |
