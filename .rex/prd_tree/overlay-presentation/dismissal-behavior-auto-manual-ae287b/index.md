---
id: "ae287b4c-5339-4870-b2e5-1aea05cd6c35"
level: "feature"
title: "Dismissal behavior (auto, manual, escapable)"
status: "completed"
priority: "high"
tags:
  - "overlay"
  - "dismissal"
source: "PRD.md §3.3, §3.2 FR-8"
startedAt: "2026-05-21T12:46:54.611Z"
completedAt: "2026-05-21T12:46:54.611Z"
endedAt: "2026-05-21T12:46:54.611Z"
acceptanceCriteria:
  - "Auto-dismiss disappears after duration with countdown shown; manual persists until Esc/click (AC-3, FR-10/11)"
  - "Esc always dismisses; Cmd-Tab and force-quit never blocked (AC-4, FR-8)"
  - "Manual mode shows a discoverable 'Press Esc to dismiss' hint (NFR-use-2)"
description: "Per-schedule dismissal: auto-dismiss after the configured duration with a subtle countdown/progress ring (early dismiss allowed), or manual until Esc/dismiss control. The overlay is a soft overlay — Esc and the dismiss control always work, and Cmd-Tab, Mission Control, and force-quit are never blocked. Menu-bar state restored on dismiss."
---

## Children

| Title | Status |
|-------|--------|
| [Ensure Cmd-Tab/force-quit unblocked; restore menu-bar state on dismiss](./ensure-cmd-tab-force-quit-78b13f.md) | completed |
| [Implement auto-dismiss timer with countdown/progress ring](./implement-auto-dismiss-timer-53747d.md) | completed |
| [Implement manual dismiss via Esc/control with hint](./implement-manual-dismiss-via-86bef4.md) | completed |
