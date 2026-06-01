---
id: "938e2e4d-b027-4815-825d-be0c47e8d5f6"
level: "feature"
title: "Menu-bar status-item app (LSUIElement)"
status: "completed"
priority: "high"
tags:
  - "menu-bar"
  - "lifecycle"
blockedBy:
  - "168c542a-e60c-43f2-aa8f-c904077c01e2"
source: "PRD.md §3.7, §6"
startedAt: "2026-05-21T12:45:59.329Z"
completedAt: "2026-05-21T12:45:59.329Z"
endedAt: "2026-05-21T12:45:59.329Z"
acceptanceCriteria:
  - "App shows a menu-bar icon and no Dock icon (FR-18)"
  - "Menu exposes settings, schedule toggles, preview, launch-at-login, quit (FR-19)"
  - "Quit stops all scheduling and leaves no daemon (FR-21)"
description: "Run as a menu-bar (status item) app with LSUIElement=true (no Dock icon). The menu provides: open settings, schedule list with inline quick-toggles, preview overlay, launch-at-login toggle, and quit. Quitting stops all scheduling."
---

## Children

| Title | Status |
|-------|--------|
| [Create NSStatusItem with icon and menu](./create-nsstatusitem-with-icon-and-menu.md) | completed |
| [Implement quit path that tears down scheduler and timers](./implement-quit-path-that-tears-bcc3ae.md) | completed |
| [Wire menu actions (settings, preview, launch-at-login, quit)](./wire-menu-actions-settings-93f144.md) | completed |
