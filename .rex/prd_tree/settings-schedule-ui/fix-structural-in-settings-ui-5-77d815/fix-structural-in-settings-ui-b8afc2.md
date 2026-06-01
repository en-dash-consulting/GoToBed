---
id: "b8afc227-38b6-4fb4-8063-ea489a5a820d"
level: "task"
title: "Fix structural in settings-ui: If settings-ui components directly mutate project-root-models types rather than  (+4 more)"
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-25T03:51:03.275Z"
completedAt: "2026-05-25T04:03:26.197Z"
endedAt: "2026-05-25T04:03:26.197Z"
resolutionType: "code-change"
resolutionDetail: "Moved Palette tokens to GoToBedCore, moved SettingsWindowController to composition root, introduced MenuViewModel/ScheduleDisplayItem, added AppEnvironment coordinator methods for all store writes, removed direct Store write dependencies from all settings-ui views and MenuContent."
acceptanceCriteria: []
description: "- If settings-ui components directly mutate project-root-models types rather than delegating writes through a coordinator in app-lifecycle, that is a leaky abstraction: presentation layer is reaching past its intended boundary into the domain layer.\n- MenuContent.swift (the status-bar NSMenu) is co-located with settings views, making the app's primary navigation surface a subordinate member of a settings zone. Any future requirement to hide, modify, or gate the status-bar menu requires touching settings-ui rather than the composition root, which will surprise contributors.\n- Palette.swift is the sole visual-token definition file and lives inside settings-ui. If overlay-ui requires the same color values (e.g. for a dark sleep overlay that matches the app theme), the only options are duplication or an undocumented cross-zone import — both erode zone boundaries silently. Move shared visual tokens to project-root-models or extract a ui-shared zone.\n- SettingsWindowController.swift manages NSWindow lifecycle (show, hide, close, ordering) from within the UI content zone. Window controllers are composition-root concerns: AppEnvironment must call into settings-ui to present or dismiss the window, inverting the expected dependency direction where app-lifecycle owns all windowing decisions.\n- Audit MenuContent.swift for @EnvironmentObject or @Binding reads from domain state; if present, introduce a MenuViewModel owned by app-lifecycle that pre-computes the display string and passes it into MenuContent as a plain value — removing the view's direct domain dependency."
commits:
  - {"hash":"df3d76b59b8761108c84272e531175749ebaae02","author":"Nick Daniel","authorEmail":"nick@endash.us","timestamp":"2026-05-25T00:03:50-04:00"}
recommendationMeta: {"findingHashes":["932203aa7f6a","97871992cdad","0ac203c0d734","aef2f39c54e6","d7e29756210c"],"category":"structural","severityDistribution":{"warning":5},"findingCount":5}
---
