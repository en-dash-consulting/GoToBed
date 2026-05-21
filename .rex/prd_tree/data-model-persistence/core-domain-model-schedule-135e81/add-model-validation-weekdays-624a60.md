---
id: "624a6042-d6f1-4a58-beae-3d8380b48476"
level: "task"
title: "Add model validation (weekdays, duration, message cap)"
status: "completed"
priority: "medium"
startedAt: "2026-05-21T12:46:07.968Z"
completedAt: "2026-05-21T12:46:07.968Z"
endedAt: "2026-05-21T12:46:07.968Z"
resolutionType: "code-change"
resolutionDetail: "Validation.swift enforces non-empty weekdays, 0-23/0-59, 5-3600s duration, 500-char message; sanitized() clamps. Covered by ValidationTests."
acceptanceCriteria: []
description: "Enforce non-empty weekdays, auto duration 5-3600s, and ~500-char message cap."
---
