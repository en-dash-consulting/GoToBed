#!/usr/bin/env bash
#
# Architectural guard: GoToBedCore is a pure-logic module — models, persistence,
# schedule math, appearance values. It must compile without AppKit, SwiftUI,
# Cocoa, or any other macOS UI framework so it can be tested headlessly and
# (if ever needed) ported. The convention is enforced by Package.swift target
# boundaries today; this script makes the rule machine-checkable so accidental
# UI imports surface in CI rather than at integration time.
#
# Runs in CI and `make validate` (see Makefile).
set -euo pipefail

cd "$(dirname "$0")/.."

CORE_DIR="Sources/GoToBedCore"

if [ ! -d "$CORE_DIR" ]; then
    echo "ERROR: $CORE_DIR not found." >&2
    exit 1
fi

# Forbidden top-level imports. Add to this list if other UI frameworks creep in.
forbidden='^[[:space:]]*import[[:space:]]+(AppKit|SwiftUI|Cocoa|UIKit)\b'

echo "==> Checking $CORE_DIR for forbidden UI-framework imports"
if grep -REn "$forbidden" "$CORE_DIR" ; then
    echo "ERROR: GoToBedCore must not import AppKit/SwiftUI/Cocoa/UIKit." >&2
    echo "       The core is pure logic — UI glue belongs in the GoToBed target." >&2
    exit 1
fi

echo "OK: GoToBedCore imports no UI frameworks."
