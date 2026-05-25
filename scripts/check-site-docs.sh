#!/usr/bin/env bash
#
# Validate that static site docs are consistent with Packaging/Info.plist.
#
# Checks that the minimum macOS version declared in Info.plist is reflected in
# docs/llms.txt and docs/index.html — providing a CI signal when
# LSMinimumSystemVersion is updated without updating the static docs.
#
# Run as part of `make validate` or directly in CI.
set -euo pipefail

cd "$(dirname "$0")/.."

ERRORS=0
PLIST="Packaging/Info.plist"

if [ ! -f "$PLIST" ]; then
    echo "check-site-docs: $PLIST not found" >&2
    exit 1
fi

# Extract the major macOS version from LSMinimumSystemVersion (e.g., "13.0" → "13").
# Uses grep + sed to be portable across both BSD (macOS) and GNU (Linux/CI) toolchains.
MIN_VERSION=$(grep -A1 'LSMinimumSystemVersion' "$PLIST" \
    | grep '<string>' \
    | sed 's|[^0-9]*\([0-9]*\).*|\1|')

if [ -z "$MIN_VERSION" ]; then
    echo "check-site-docs: could not read LSMinimumSystemVersion from $PLIST" >&2
    exit 1
fi

check_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "check-site-docs: FAIL — $file not found" >&2
        ERRORS=$((ERRORS + 1))
        return
    fi
    if ! grep -q "macOS $MIN_VERSION" "$file"; then
        echo "check-site-docs: FAIL — $file does not mention 'macOS $MIN_VERSION'" >&2
        echo "  Info.plist LSMinimumSystemVersion is ${MIN_VERSION}.x — update the docs to match." >&2
        ERRORS=$((ERRORS + 1))
    else
        echo "check-site-docs: OK — $file mentions 'macOS $MIN_VERSION'"
    fi
}

check_file docs/llms.txt
check_file docs/index.html

if [ "$ERRORS" -gt 0 ]; then
    echo "check-site-docs: $ERRORS check(s) failed." >&2
    exit 1
fi

echo "check-site-docs: all checks passed (LSMinimumSystemVersion ${MIN_VERSION}.x)"
