#!/usr/bin/env bash
#
# Generate Packaging/AppIcon.icns from a square source PNG.
# Usage: scripts/make-icon.sh path/to/source.png
set -euo pipefail

cd "$(dirname "$0")/.."

SRC="${1:-Packaging/AppIcon-source.png}"
[ -f "$SRC" ] || { echo "Source icon not found: $SRC"; exit 1; }

ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"

for size in 16 32 128 256 512; do
    sips -z $size $size       "$SRC" --out "$ICONSET/icon_${size}x${size}.png"      >/dev/null
    sips -z $((size*2)) $((size*2)) "$SRC" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o Packaging/AppIcon.icns
echo "Wrote Packaging/AppIcon.icns"
