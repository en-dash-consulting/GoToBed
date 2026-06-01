---
id: "e9226de1-251c-4fdd-85ec-5e9fec46c732"
level: "task"
title: "Audit entitlements: remove network/camera/mic/accessibility"
status: "completed"
priority: "medium"
startedAt: "2026-05-21T12:47:40.154Z"
completedAt: "2026-05-21T12:47:40.154Z"
endedAt: "2026-05-21T12:47:40.154Z"
resolutionType: "code-change"
resolutionDetail: "Packaging/GoToBed.entitlements: app-sandbox only, zero capability keys (no network/camera/mic/accessibility). Enforced by scripts/verify-no-network.sh."
acceptanceCriteria: []
description: "Ensure the entitlements file declares no networking or sensitive-device access (NFR-priv-1)."
---
