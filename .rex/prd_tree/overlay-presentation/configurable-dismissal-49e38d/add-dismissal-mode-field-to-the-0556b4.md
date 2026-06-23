---
id: "0556b490-6043-462d-8f15-d21856ed7789"
level: "task"
title: "Add dismissal-mode field to the schedule model"
status: "completed"
priority: "medium"
tags:
  - "data-model"
  - "dismissal"
source: "/ndx-capture — conversation 2026-06-22"
startedAt: "2026-06-23T03:38:52.677Z"
completedAt: "2026-06-23T03:40:36.919Z"
endedAt: "2026-06-23T03:40:36.919Z"
resolutionType: "code-change"
resolutionDetail: "Added DismissChallenge enum (escape/randomKey/typeString) and a dismissChallenge field on Schedule, defaulting to .escape with decodeIfPresent for backward-compatible loading. Added typeStringTooLong validation + sanitize (clamp to maxTypeStringLength=100; blank phrase downgrades to .escape). Covered by DismissChallengeTests (7 tests)."
acceptanceCriteria:
  - "Schedule model carries a dismissalMode enum (esc/randomKey/typeString) plus mode config"
  - "Existing persisted schedules decode to esc by default (no migration breakage)"
  - "Field round-trips through persistence"
description: "Add a per-schedule dismissal-mode setting to the schedule data model and persistence: an enum (esc / randomKey / typeString) plus any mode-specific config (e.g. the target string for type-to-dismiss, or allowed key set for random-key). Default to esc for backward compatibility with existing persisted schedules."
---
