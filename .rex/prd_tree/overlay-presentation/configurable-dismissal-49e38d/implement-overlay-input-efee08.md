---
id: "efee0868-74e1-4c40-a5b2-fc0ad7b37ade"
level: "task"
title: "Implement overlay input handling for random-key and type-to-dismiss"
status: "pending"
priority: "medium"
tags:
  - "overlay"
  - "dismissal"
  - "appkit"
blockedBy:
  - "0556b490-6043-462d-8f15-d21856ed7789"
source: "/ndx-capture — conversation 2026-06-22"
acceptanceCriteria:
  - "Random-key mode dismisses only on the displayed key; other keys ignored"
  - "Type-to-dismiss dismisses only on exact string match; mismatches cleared/ignored"
  - "Required key / target string is clearly displayed in the overlay"
  - "No event-tap or menu-bar capture added; OS escape routes stay functional"
description: "In the overlay, branch dismissal behavior on the schedule's dismissalMode. Random-key: pick and display a required key, dismiss only on that exact keyDown, ignore other keys (optionally re-roll on wrong press). Type-to-dismiss: display the target string and a text field/buffer, dismiss only on exact match, clear/ignore on mismatch. Keep Esc as the default mode. Ensure no event taps or global key blocking are introduced so Cmd-Tab/Mission Control/force-quit remain functional."
---
