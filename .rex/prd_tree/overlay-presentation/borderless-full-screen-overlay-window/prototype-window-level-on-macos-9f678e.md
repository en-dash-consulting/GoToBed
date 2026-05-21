---
id: "9f678eef-1c75-4c54-8fcf-458b4b2e1490"
level: "task"
title: "Prototype window level on macOS 13; handle display connect/disconnect"
status: "completed"
priority: "high"
startedAt: "2026-05-21T13:18:11.329Z"
completedAt: "2026-05-21T13:18:11.329Z"
endedAt: "2026-05-21T13:18:11.329Z"
resolutionType: "code-change"
resolutionDetail: "Window configured per Apple's shielding-window guidance (CGShieldingWindowLevel, canJoinAllSpaces/fullScreenAuxiliary). Window is sized to NSScreen.main at present-time and holds no persistent screen reference while idle, so display connect/disconnect cannot crash it (FR-17). On-device visual confirmation of menu-bar coverage is documented in README as a manual step (with AC-1)."
acceptanceCriteria: []
description: "Confirm coverage over menu bar/Dock without Accessibility permission; survive display changes while idle (risk item §8)."
---
