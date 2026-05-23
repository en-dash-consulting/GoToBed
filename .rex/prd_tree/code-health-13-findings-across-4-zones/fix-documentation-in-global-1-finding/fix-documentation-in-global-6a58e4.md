---
id: "6a58e4b1-3f06-48b9-80d1-b39ed8751c42"
level: "task"
title: "Fix documentation in global: Introduce a single VERSION file at the repository root consumed by both the Make"
status: "pending"
priority: "high"
source: "sourcevision"
acceptanceCriteria: []
description: "- Introduce a single VERSION file at the repository root consumed by both the Makefile (injected as MARKETING_VERSION into xcodebuild) and a docs-generation script (substituted into sitemap.xml lastmod, site.webmanifest version, and any DMG download URLs in docs/) — one source of truth for both release artifacts."
recommendationMeta: {"findingHashes":["42910b720c80"],"category":"documentation","severityDistribution":{"warning":1},"findingCount":1}
---
