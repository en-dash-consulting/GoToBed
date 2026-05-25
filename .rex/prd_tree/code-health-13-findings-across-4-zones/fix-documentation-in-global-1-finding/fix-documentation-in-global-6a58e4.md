---
id: "6a58e4b1-3f06-48b9-80d1-b39ed8751c42"
level: "task"
title: "Fix documentation in global: Introduce a single VERSION file at the repository root consumed by both the Make"
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-25T03:15:06.308Z"
completedAt: "2026-05-25T03:20:16.794Z"
endedAt: "2026-05-25T03:20:16.794Z"
resolutionType: "code-change"
resolutionDetail: "Created VERSION file at repo root; wired through Makefile (MARKETING_VERSION), build-app.sh (priority chain), stamp-site-version.sh (now stamps both sitemap and webmanifest), release-please-config.json (VERSION as extra-file), and release.yml (stamp-docs commits both docs files)."
acceptanceCriteria: []
description: "- Introduce a single VERSION file at the repository root consumed by both the Makefile (injected as MARKETING_VERSION into xcodebuild) and a docs-generation script (substituted into sitemap.xml lastmod, site.webmanifest version, and any DMG download URLs in docs/) — one source of truth for both release artifacts."
recommendationMeta: {"findingHashes":["42910b720c80"],"category":"documentation","severityDistribution":{"warning":1},"findingCount":1}
---
