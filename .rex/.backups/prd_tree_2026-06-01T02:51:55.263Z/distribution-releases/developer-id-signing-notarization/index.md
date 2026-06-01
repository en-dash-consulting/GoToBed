---
id: "0bacb0ef-d450-4a69-a736-b68c1869bfb4"
level: "feature"
title: "Developer ID signing & notarization"
status: "completed"
priority: "high"
tags:
  - "signing"
  - "notarization"
  - "gatekeeper"
source: "Distribution requirement (Gatekeeper)"
startedAt: "2026-05-21T18:15:49.924Z"
completedAt: "2026-05-21T18:15:49.924Z"
endedAt: "2026-05-21T18:15:49.924Z"
acceptanceCriteria:
  - "Release .app is signed with a Developer ID Application identity and hardened runtime"
  - "Notarization via notarytool succeeds and the ticket is stapled"
  - "spctl --assess --type execute passes; first launch shows no 'unidentified developer' block"
  - "Entitlements remain network-free (no-network guarantee preserved)"
description: "Replace the current ad-hoc signature with Developer ID Application signing under the hardened runtime, notarize the app with Apple (notarytool), and staple the ticket, so a downloaded build launches without Gatekeeper warnings or right-click-open. Requires an Apple Developer account ($99/yr); this is the main prerequisite for a smooth public download."
---

## Children

| Title | Status |
|-------|--------|
| [Add Developer ID signing + notarytool + stapling to build-app.sh](./add-developer-id-signing-fb4cdf.md) | completed |
