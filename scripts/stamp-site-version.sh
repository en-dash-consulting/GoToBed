#!/usr/bin/env bash
#
# Stamp the static site (docs/) with the current release date. The `version`
# field in `docs/site.webmanifest` is maintained automatically by release-please
# (via `extra-files` in release-please-config.json), so this script only needs
# to refresh the sitemap `<lastmod>`.
#
# Run this from the release workflow *after* release-please has produced a tag,
# or locally before pushing a release commit.
#
# Usage:
#   scripts/stamp-site-version.sh [YYYY-MM-DD]
#
#   Defaults to today (UTC).
set -euo pipefail

cd "$(dirname "$0")/.."

DATE="${1:-$(date -u +%Y-%m-%d)}"
SITEMAP="docs/sitemap.xml"

if [ ! -f "$SITEMAP" ]; then
    echo "stamp-site-version: $SITEMAP not found" >&2
    exit 1
fi

# Replace the first <lastmod>YYYY-MM-DD</lastmod> with the new date.
# Using a temp file + mv keeps the change atomic and avoids sed -i portability
# differences between BSD (macOS) and GNU sed.
TMP="$(mktemp)"
awk -v new="$DATE" '
    !done && /<lastmod>/ {
        sub(/<lastmod>[^<]*<\/lastmod>/, "<lastmod>" new "</lastmod>")
        done = 1
    }
    { print }
' "$SITEMAP" > "$TMP"
mv "$TMP" "$SITEMAP"

echo "stamp-site-version: set lastmod=$DATE in $SITEMAP"
