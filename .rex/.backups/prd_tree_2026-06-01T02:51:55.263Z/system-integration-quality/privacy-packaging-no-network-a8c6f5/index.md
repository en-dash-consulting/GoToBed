---
id: "a8c6f598-4ca3-4fe9-9728-8a36b76182f0"
level: "feature"
title: "Privacy & packaging (no-network, universal, signing)"
status: "completed"
priority: "medium"
tags:
  - "packaging"
  - "privacy"
source: "PRD.md §4.5, §5.7"
startedAt: "2026-05-21T12:47:42.575Z"
completedAt: "2026-05-21T12:47:42.575Z"
endedAt: "2026-05-21T12:47:42.575Z"
acceptanceCriteria:
  - "No network/camera/mic/accessibility entitlements present (NFR-priv-1)"
  - "App makes no network connections, verified (AC-11)"
  - "Universal binary, code-signed"
description: "Ship fully offline: no networking/camera/mic/accessibility/screen-recording entitlements, no telemetry. Universal binary, code-signed for local use (notarization optional). Verify no network connections are made."
---

## Children

| Title | Status |
|-------|--------|
| [Audit entitlements: remove network/camera/mic/accessibility](./audit-entitlements-remove-e9226d.md) | completed |
| [Configure universal binary + code signing; verify no network calls](./configure-universal-binary-code-9b106b.md) | completed |
