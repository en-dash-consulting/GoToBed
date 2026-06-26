#!/usr/bin/env bash
#
# Stamp the static site (docs/) with the current release version and date.
# Reads the version from scripts/version.sh (single source of truth: the
# release-please manifest) and updates:
#   - docs/sitemap.xml       <lastmod>YYYY-MM-DD</lastmod>
#   - docs/site.webmanifest  "version": "x.y.z"
#   - docs/llms.txt          "- Current version: x.y.z"
#
# The `version` field in site.webmanifest and the "Current version" line in
# llms.txt are both driven by .release-please-manifest.json, which release-please
# bumps as part of the release PR. This script is the single docs-generation step
# that propagates that value into all site artifacts.
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
MANIFEST="docs/site.webmanifest"
LLMS="docs/llms.txt"

if [ ! -f "$SITEMAP" ]; then
    echo "stamp-site-version: $SITEMAP not found" >&2
    exit 1
fi

if [ ! -f "$MANIFEST" ]; then
    echo "stamp-site-version: $MANIFEST not found" >&2
    exit 1
fi

if [ ! -f "$LLMS" ]; then
    echo "stamp-site-version: $LLMS not found" >&2
    exit 1
fi

VERSION="$(scripts/version.sh)"

# Update sitemap <lastmod>.
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

# Update site.webmanifest "version" field.
TMP="$(mktemp)"
awk -v ver="$VERSION" '
    /"version"[[:space:]]*:/ {
        sub(/"version"[[:space:]]*:[[:space:]]*"[^"]*"/, "\"version\": \"" ver "\"")
    }
    { print }
' "$MANIFEST" > "$TMP"
mv "$TMP" "$MANIFEST"
echo "stamp-site-version: set version=$VERSION in $MANIFEST"

# Update llms.txt "Current version" line.
TMP="$(mktemp)"
awk -v ver="$VERSION" '
    /^- Current version:/ {
        sub(/^- Current version: [^[:space:]]+/, "- Current version: " ver)
    }
    { print }
' "$LLMS" > "$TMP"
mv "$TMP" "$LLMS"
echo "stamp-site-version: set version=$VERSION in $LLMS"
