---
id: "65caef31-1904-4c5e-b601-77a0af2444e2"
level: "feature"
title: "Offline-preserving update path"
status: "completed"
priority: "medium"
tags:
  - "updates"
  - "privacy"
blockedBy:
  - "b6cd6bcc-16b0-4432-a337-a91bcdab9b25"
source: "User decision (keep app fully offline)"
startedAt: "2026-05-21T18:40:52.566Z"
completedAt: "2026-05-21T18:40:52.566Z"
endedAt: "2026-05-21T18:40:52.566Z"
acceptanceCriteria:
  - "Menu shows current version and a 'Check for Updates…' item that opens the releases page in the browser"
  - "No network entitlement added; scripts/verify-no-network.sh still passes"
  - "Manual update steps documented in README and on the website"
description: "Give users a clear path to updates without breaking the app's zero-network guarantee (NFR-priv-1). Add a \"Check for Updates…\" menu item that opens the latest GitHub release page in the default browser (NSWorkspace.open — no network entitlement), show the current version in the menu, and document the manual update flow (download the new .app, replace it in /Applications). Note: a true in-app auto-updater (e.g. Sparkle) was deliberately not chosen because it requires network access; recorded here as a future option if the privacy stance is ever relaxed."
---

## Children

| Title | Status |
|-------|--------|
| [Add 'Check for Updates…' menu item + version display](./add-check-for-updates-menu-item-97308a.md) | completed |
| [Document the manual update flow (README + website)](./document-the-manual-update-flow-955f90.md) | completed |
