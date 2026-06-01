---
id: "4eba8007-608e-4188-9065-328988be338b"
level: "task"
title: "Derive version from git tag, inject into Info.plist, show in menu"
status: "completed"
priority: "high"
startedAt: "2026-05-21T18:40:40.434Z"
completedAt: "2026-05-21T18:40:40.434Z"
endedAt: "2026-05-21T18:40:40.434Z"
resolutionType: "code-change"
resolutionDetail: "build-app.sh derives the version from the git tag (vX.Y.Z, fallback 0.0.0-dev) and injects CFBundleShortVersionString + CFBundleVersion via PlistBuddy; AppInfo reads it and MenuContent shows it. Verified: VERSION=1.2.3 produces a 1.2.3 bundle; untagged falls back cleanly."
acceptanceCriteria: []
description: "Single-source the version from the git tag (vX.Y.Z) into CFBundleShortVersionString + CFBundleVersion at build time; display the running version in the menu."
---
