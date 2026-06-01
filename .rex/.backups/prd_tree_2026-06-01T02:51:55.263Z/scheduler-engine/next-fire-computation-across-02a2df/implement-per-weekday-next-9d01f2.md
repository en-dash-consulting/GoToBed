---
id: "9d01f2de-2b45-4bf7-8e8e-cc378a15c9ea"
level: "task"
title: "Implement per-weekday next-occurrence computation"
status: "completed"
priority: "critical"
startedAt: "2026-05-21T12:46:21.134Z"
completedAt: "2026-05-21T12:46:21.134Z"
endedAt: "2026-05-21T12:46:21.134Z"
resolutionType: "code-change"
resolutionDetail: "ScheduleCalculator.nextFireDate uses Calendar.nextDate per active weekday, min of candidates. Covered by ScheduleCalculatorTests."
acceptanceCriteria: []
description: "Use Calendar.nextDate(after:matching:) per active weekday and take the minimum future date."
---
