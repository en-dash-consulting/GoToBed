---
id: "49e38d57-4fae-4ba3-8fb6-2a9de26ec52a"
level: "feature"
title: "Configurable dismissal challenge (random-key / type-to-dismiss)"
status: "pending"
priority: "medium"
tags:
  - "overlay"
  - "dismissal"
  - "settings"
source: "/ndx-capture — conversation 2026-06-22"
acceptanceCriteria:
  - "A per-schedule setting selects dismissal mode: Esc / Random key / Type-to-dismiss"
  - "Random-key mode displays the required key and dismisses only on that exact key; wrong keys are ignored (optional re-roll)"
  - "Type-to-dismiss displays a target string and dismisses only on an exact match; mismatches are ignored/cleared"
  - "Cmd-Tab, Mission Control, and force-quit are never blocked in any mode (escapability preserved, AC-4/FR-8)"
  - "Auto-dismiss still fires after the configured duration even when a challenge mode is active"
description: "A per-schedule setting that selects how the overlay is dismissed, adding deliberate friction so the reminder can't be reflexively dismissed. Modes: Esc (current default), Random key (a randomly chosen key is displayed and must be pressed), or Type-to-dismiss (a determined string is shown and must be typed exactly). This gates only the overlay's own dismiss path — OS escape routes (Cmd-Tab, Mission Control, force-quit) are never trapped, preserving the soft-overlay escapability guarantee. Works alongside auto-dismiss when a duration is configured."
---

## Children

| Title | Status |
|-------|--------|
| [Add dismissal-mode field to the schedule model](./add-dismissal-mode-field-to-the-0556b4.md) | completed |
| [Add settings UI control for per-schedule dismissal mode](./add-settings-ui-control-for-per-6485e0.md) | pending |
| [Implement overlay input handling for random-key and type-to-dismiss](./implement-overlay-input-efee08.md) | pending |
