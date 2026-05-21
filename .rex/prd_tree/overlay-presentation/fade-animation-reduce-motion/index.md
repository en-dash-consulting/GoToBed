---
id: "f28e0c59-31b7-4277-b536-826a134671c7"
level: "feature"
title: "Fade animation & Reduce Motion"
status: "completed"
priority: "low"
tags:
  - "overlay"
  - "a11y"
  - "animation"
source: "PRD.md §3.3 FR-12, §4.2 NFR-perf-2, §4.7 NFR-a11y-2"
startedAt: "2026-05-21T12:47:01.533Z"
completedAt: "2026-05-21T12:47:01.533Z"
endedAt: "2026-05-21T12:47:01.533Z"
acceptanceCriteria:
  - "Overlay appears within 150ms; fade ≤300ms (NFR-perf-2)"
  - "Reduce Motion skips/shortens the fade (NFR-a11y-2)"
description: "Brief fade animation on present/dismiss (≤300ms); overlay appears within 150ms of fire. Honor the system \"Reduce Motion\" setting by skipping/shortening animations."
---

## Children

| Title | Status |
|-------|--------|
| [Add present/dismiss fade animations within perf budget](./add-present-dismiss-fade-47d37c.md) | completed |
| [Honor Reduce Motion by skipping/shortening fades](./honor-reduce-motion-by-skipping-80aeee.md) | completed |
