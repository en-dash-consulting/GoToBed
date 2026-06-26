#!/usr/bin/env bash
#
# Print the current release version — the single source of truth.
#
# release-please maintains the version in .release-please-manifest.json (key
# "."), which it updates correctly on every release PR. A bare committed VERSION
# file could not be auto-bumped (release-please's generic updater needs an
# `x-release-please-version` annotation a plain file can't carry), so it drifted
# and mislabeled artifacts. Reading the manifest instead removes that drift.
#
# Resolution priority:
#   1. MARKETING_VERSION env  (release workflow pins the git-tag version here)
#   2. VERSION env            (manual override)
#   3. .release-please-manifest.json
#   4. Nearest git tag (vX.Y.Z, leading "v" stripped)
#   5. 0.0.0-dev fallback
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -n "${MARKETING_VERSION:-}" ]; then printf '%s\n' "$MARKETING_VERSION"; exit 0; fi
if [ -n "${VERSION:-}" ]; then printf '%s\n' "$VERSION"; exit 0; fi

MANIFEST=".release-please-manifest.json"
if [ -f "$MANIFEST" ]; then
    v="$(sed -n 's/.*"\."[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$MANIFEST" | head -1)"
    if [ -n "$v" ]; then printf '%s\n' "$v"; exit 0; fi
fi

v="$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)"
printf '%s\n' "${v:-0.0.0-dev}"
