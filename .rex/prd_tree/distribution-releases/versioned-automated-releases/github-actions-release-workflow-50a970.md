---
id: "50a9709f-9592-4222-ba22-317857566514"
level: "task"
title: "GitHub Actions release workflow (build, sign, notarize, publish on tag)"
status: "completed"
priority: "high"
startedAt: "2026-05-21T18:40:45.039Z"
completedAt: "2026-05-21T18:40:45.039Z"
endedAt: "2026-05-21T18:40:45.039Z"
resolutionType: "code-change"
resolutionDetail: ".github/workflows/release.yml: on vX.Y.Z tag, imports the signing cert + notary creds from repo secrets, runs build-app.sh + make-dmg.sh, and publishes a GitHub Release with generated notes and the DMG. First real run validates once the repo + secrets exist (documented in README Releasing section)."
acceptanceCriteria: []
description: "CI workflow triggered on vX.Y.Z tags: build universal, sign + notarize (secrets for identity/credentials), package, and create a GitHub Release with auto-generated notes and the download asset."
---
