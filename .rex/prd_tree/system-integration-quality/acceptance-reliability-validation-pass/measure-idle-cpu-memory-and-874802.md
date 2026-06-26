---
id: "87480262-f857-414c-b390-57118d702d11"
level: "task"
title: "Measure idle CPU/memory and overlay timing vs NFR budgets"
status: "deferred"
priority: "medium"
acceptanceCriteria:
  - "Idle CPU reads ≈0% in Activity Monitor over a 5-minute idle period with no overlay"
  - "RSS stays below 80MB at idle and after overlay dismiss"
  - "Overlay appears within 150ms of a manually triggered preview fire (timed with a stopwatch or Instruments)"
  - "A live scheduled fire arrives within ±2s of the target minute"
description: "Spot-check runtime NFRs using Instruments and Activity Monitor: idle CPU ≈0%, RSS <80MB, overlay appearance within 150ms of a triggered fire, and first scheduled fire within ±2s of the target minute. These are empirical spot-checks in a live run, not automated assertions."
---
