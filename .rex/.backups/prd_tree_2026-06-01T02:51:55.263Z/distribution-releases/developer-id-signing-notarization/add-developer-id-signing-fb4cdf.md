---
id: "fb4cdf4c-f1f5-4adf-b1de-b4db124f8644"
level: "task"
title: "Add Developer ID signing + notarytool + stapling to build-app.sh"
status: "completed"
priority: "high"
startedAt: "2026-05-21T15:49:53.137Z"
completedAt: "2026-05-21T18:15:49.848Z"
endedAt: "2026-05-21T18:15:49.848Z"
resolutionType: "code-change"
resolutionDetail: "build-app.sh signs with Developer ID + hardened runtime + secure timestamp and notarizes/staples via a notarytool keychain profile. Verified on a real build: codesign authority = Developer ID Application, spctl = \"accepted, Notarized Developer ID\", stapler validate passes, entitlements remain network-free."
acceptanceCriteria: []
description: "Extend build-app.sh to sign with a Developer ID Application identity (hardened runtime), submit to notarytool, and staple the ticket; parameterize identity/credentials. Verify with spctl."
---
