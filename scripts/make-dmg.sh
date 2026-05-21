#!/usr/bin/env bash
#
# Package build/GoToBed.app into a distributable DMG with an /Applications
# drop target. Optionally notarizes + staples the DMG.
# Output: build/GoToBed-<version>.dmg
#
# Run scripts/build-app.sh first. Usage:
#   scripts/make-dmg.sh [NOTARY_PROFILE]
#     NOTARY_PROFILE  notarytool keychain profile; when set (or
#                     $GOTOBED_NOTARY_PROFILE) the DMG is notarized + stapled.
set -euo pipefail

cd "$(dirname "$0")/.."

APP="build/GoToBed.app"
[ -d "$APP" ] || { echo "Missing $APP — run scripts/build-app.sh first."; exit 1; }

NOTARY_PROFILE="${1:-${GOTOBED_NOTARY_PROFILE:-}}"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")"
DMG="build/GoToBed-$VERSION.dmg"

echo "==> Building $DMG"
STAGE="$(mktemp -d)"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
rm -f "$DMG"
hdiutil create -volname "GoToBed" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGE"

if [ -n "$NOTARY_PROFILE" ]; then
    echo "==> Notarizing DMG (profile: $NOTARY_PROFILE)"
    xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG"
    xcrun stapler validate "$DMG"
fi

# Also publish a stable, version-independent copy so the website can link to
# https://github.com/.../releases/latest/download/GoToBed.dmg (the staple lives
# in the DMG bytes, so the copy stays notarized).
cp "$DMG" "build/GoToBed.dmg"

echo "==> Done: $DMG (+ build/GoToBed.dmg)"
