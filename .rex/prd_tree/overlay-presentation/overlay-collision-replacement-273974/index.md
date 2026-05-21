---
id: "2739743c-cea7-4966-8aef-3ff97359872d"
level: "feature"
title: "Overlay collision replacement (newer wins)"
status: "completed"
priority: "medium"
tags:
  - "overlay"
source: "PRD.md §3.5 FR-16, §3.2 FR-9"
startedAt: "2026-05-21T12:46:58.063Z"
completedAt: "2026-05-21T12:46:58.063Z"
endedAt: "2026-05-21T12:46:58.063Z"
acceptanceCriteria:
  - "At most one overlay visible at any time (FR-9)"
  - "A new fire replaces the current overlay immediately (FR-16)"
  - "Same-minute collision resolves deterministically by creation order"
description: "Only one overlay is ever shown. If a schedule fires while an overlay is visible, the new overlay replaces the current one immediately (newer message wins); overlays are never stacked or queued. Two schedules at the same minute resolve to whichever fires last by creation order."
---

## Children

| Title | Status |
|-------|--------|
| [Resolve same-minute collisions by creation order](./resolve-same-minute-collisions-9eac46.md) | completed |
| [Track single active overlay and replace on new fire](./track-single-active-overlay-and-d56cf5.md) | completed |
