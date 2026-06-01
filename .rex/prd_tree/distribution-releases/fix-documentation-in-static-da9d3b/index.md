---
id: "da9d3bc2-d569-4e2d-ae7b-7a1679cb228b"
level: "feature"
title: "Fix documentation in static-site-assets (3 findings)"
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-25T03:28:01.821Z"
completedAt: "2026-05-25T03:28:01.821Z"
endedAt: "2026-05-25T03:28:01.821Z"
acceptanceCriteria: []
description: "- No build step links static-site-assets content to the Swift source zones — llms.txt and sitemap.xml are manually authored, creating documentation drift risk on every feature release.\n- sitemap.xml and site.webmanifest are hand-authored with no link to the authoritative version variable in app-build-scripts. Each app release can ship with stale metadata in the static site without any CI signal — the dual-artifact release model requires a shared version source, not two independently maintained version strings.\n- Add a CI step that extracts the CFBundleShortVersionString from Info.plist (or the VERSION variable from app-build-scripts) and writes it into sitemap.xml lastmod dates and any versioned download links in docs/ — eliminating the manual sync requirement on each release."
recommendationMeta: {"findingHashes":["7402509b0fae","55ac356bab07","bdeeafff4539"],"category":"documentation","severityDistribution":{"warning":3},"findingCount":3}
---

## Children

| Title | Status |
|-------|--------|
| [Fix documentation in static-site-assets: No build step links static-site-assets content to the Swift source zones — llms. (+2 more)](./fix-documentation-in-static-85859b.md) | completed |
