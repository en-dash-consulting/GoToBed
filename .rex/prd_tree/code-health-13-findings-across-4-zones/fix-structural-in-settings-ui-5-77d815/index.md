---
id: "77d815de-8351-4270-be94-2ffbe7d90a58"
level: "feature"
title: "Fix structural in settings-ui (5 findings)"
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-25T04:03:26.300Z"
completedAt: "2026-05-25T04:03:26.300Z"
endedAt: "2026-05-25T04:03:26.300Z"
acceptanceCriteria: []
description: "- If settings-ui components directly mutate project-root-models types rather than delegating writes through a coordinator in app-lifecycle, that is a leaky abstraction: presentation layer is reaching past its intended boundary into the domain layer.\n- MenuContent.swift (the status-bar NSMenu) is co-located with settings views, making the app's primary navigation surface a subordinate member of a settings zone. Any future requirement to hide, modify, or gate the status-bar menu requires touching settings-ui rather than the composition root, which will surprise contributors.\n- Palette.swift is the sole visual-token definition file and lives inside settings-ui. If overlay-ui requires the same color values (e.g. for a dark sleep overlay that matches the app theme), the only options are duplication or an undocumented cross-zone import — both erode zone boundaries silently. Move shared visual tokens to project-root-models or extract a ui-shared zone.\n- SettingsWindowController.swift manages NSWindow lifecycle (show, hide, close, ordering) from within the UI content zone. Window controllers are composition-root concerns: AppEnvironment must call into settings-ui to present or dismiss the window, inverting the expected dependency direction where app-lifecycle owns all windowing decisions.\n- Audit MenuContent.swift for @EnvironmentObject or @Binding reads from domain state; if present, introduce a MenuViewModel owned by app-lifecycle that pre-computes the display string and passes it into MenuContent as a plain value — removing the view's direct domain dependency."
recommendationMeta: {"findingHashes":["932203aa7f6a","97871992cdad","0ac203c0d734","aef2f39c54e6","d7e29756210c"],"category":"structural","severityDistribution":{"warning":5},"findingCount":5}
---

## Children

| Title | Status |
|-------|--------|
| [Fix structural in settings-ui: If settings-ui components directly mutate project-root-models types rather than  (+4 more)](./fix-structural-in-settings-ui-b8afc2.md) | completed |
