---
id: "b6cd6bcc-16b0-4432-a337-a91bcdab9b25"
level: "feature"
title: "Versioned, automated releases"
status: "completed"
priority: "high"
tags:
  - "versioning"
  - "ci"
  - "release"
blockedBy:
  - "0bacb0ef-d450-4a69-a736-b68c1869bfb4"
source: "User request (versioning + downloadable area)"
startedAt: "2026-05-21T18:40:45.120Z"
completedAt: "2026-05-21T18:40:45.120Z"
endedAt: "2026-05-21T18:40:45.120Z"
acceptanceCriteria:
  - "Version is derived from the git tag and written into Info.plist at build time"
  - "App displays its version (e.g. in the menu)"
  - "Pushing a vX.Y.Z tag publishes a GitHub Release with a notarized universal download asset and release notes"
description: "A single-source semantic version driven by git tags (vX.Y.Z), injected into Info.plist (CFBundleShortVersionString + build number) and surfaced in the app, plus a downloadable artifact and CI automation: on a version tag push, GitHub Actions builds the universal binary, signs + notarizes it, packages it (DMG/zip), and publishes a GitHub Release with auto-generated notes and the download asset."
---

## Children

| Title | Status |
|-------|--------|
| [Derive version from git tag, inject into Info.plist, show in menu](./derive-version-from-git-tag-4eba80.md) | completed |
| [GitHub Actions release workflow (build, sign, notarize, publish on tag)](./github-actions-release-workflow-50a970.md) | completed |
| [Package signed app as .dmg/.zip download artifact](./package-signed-app-as-dmg-zip-d5f41a.md) | completed |
