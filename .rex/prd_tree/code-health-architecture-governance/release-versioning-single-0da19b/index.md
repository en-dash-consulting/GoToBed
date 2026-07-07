---
id: "0da19bf7-4b68-41ac-af83-5297ac1c25f8"
level: "feature"
title: "Release versioning: single VERSION source of truth"
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-25T03:20:16.903Z"
completedAt: "2026-05-25T03:20:16.903Z"
endedAt: "2026-05-25T03:20:16.903Z"
acceptanceCriteria: []
description: "- Introduce a single VERSION file at the repository root consumed by both the Makefile (injected as MARKETING_VERSION into xcodebuild) and a docs-generation script (substituted into sitemap.xml lastmod, site.webmanifest version, and any DMG download URLs in docs/) — one source of truth for both release artifacts."
recommendationMeta: {"findingHashes":["42910b720c80"],"category":"documentation","severityDistribution":{"warning":1},"findingCount":1}
---

## Children

| Title | Status |
|-------|--------|
| [Create root VERSION file and wire through Makefile, build scripts, and release workflow](./create-root-version-file-and-6a58e4.md) | completed |
