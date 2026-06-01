---
id: "85859b86-c357-4f00-b834-bde823ffc893"
level: "task"
title: "Fix documentation in static-site-assets: No build step links static-site-assets content to the Swift source zones — llms. (+2 more)"
status: "completed"
priority: "high"
source: "sourcevision"
startedAt: "2026-05-25T03:20:33.160Z"
completedAt: "2026-05-25T03:28:01.717Z"
endedAt: "2026-05-25T03:28:01.717Z"
resolutionType: "code-change"
resolutionDetail: "Added \"Current version\" field to llms.txt stamped by release workflow; new check-site-docs.sh validates macOS version consistency between Info.plist and static docs; wired into make validate and release.yml stamp-docs job."
acceptanceCriteria: []
description: "- No build step links static-site-assets content to the Swift source zones — llms.txt and sitemap.xml are manually authored, creating documentation drift risk on every feature release.\n- sitemap.xml and site.webmanifest are hand-authored with no link to the authoritative version variable in app-build-scripts. Each app release can ship with stale metadata in the static site without any CI signal — the dual-artifact release model requires a shared version source, not two independently maintained version strings.\n- Add a CI step that extracts the CFBundleShortVersionString from Info.plist (or the VERSION variable from app-build-scripts) and writes it into sitemap.xml lastmod dates and any versioned download links in docs/ — eliminating the manual sync requirement on each release."
commits:
  - {"hash":"3a002c39cf5c5218243c6eae198848ae11a4c3b6","author":"Nick Daniel","authorEmail":"nick@endash.us","timestamp":"2026-05-24T23:28:25-04:00"}
recommendationMeta: {"findingHashes":["7402509b0fae","55ac356bab07","bdeeafff4539"],"category":"documentation","severityDistribution":{"warning":3},"findingCount":3}
---
