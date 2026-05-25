#!/usr/bin/env bash
#
# Build GoToBed.app as a code-signed universal (arm64 + x86_64) bundle, and
# optionally notarize + staple it for public distribution (PRD §5.7, NFR-compat-2).
# Output: build/GoToBed.app
#
# Usage:
#   scripts/build-app.sh [SIGNING_IDENTITY] [NOTARY_PROFILE]
#
#   SIGNING_IDENTITY  codesign identity. Default "-" (ad-hoc, local only).
#                     For distribution, pass your Developer ID, e.g.
#                     "Developer ID Application: Jane Doe (TEAMID)".
#                     Also reads $GOTOBED_SIGN_IDENTITY.
#   NOTARY_PROFILE    A notarytool keychain profile name created with
#                     `xcrun notarytool store-credentials`. When set (or
#                     $GOTOBED_NOTARY_PROFILE), the signed app is submitted to
#                     Apple, the run waits for the result, and the ticket is
#                     stapled. Omit to skip notarization.
set -euo pipefail

cd "$(dirname "$0")/.."

IDENTITY="${1:-${GOTOBED_SIGN_IDENTITY:--}}"
NOTARY_PROFILE="${2:-${GOTOBED_NOTARY_PROFILE:-}}"
APP="build/GoToBed.app"
PLIST="Packaging/Info.plist"
ENTITLEMENTS="Packaging/GoToBed.entitlements"

echo "==> Building universal release binary"
swift build -c release \
    --arch arm64 --arch x86_64 \
    --product GoToBed

BIN="$(swift build -c release --arch arm64 --arch x86_64 --product GoToBed --show-bin-path)/GoToBed"

# Resolve version using a priority chain:
#   1. MARKETING_VERSION env var (set by Makefile from the VERSION file)
#   2. VERSION env var (manual override)
#   3. VERSION file at the repository root
#   4. Nearest git tag (vX.Y.Z stripped of the leading "v")
#   5. Hard-coded dev fallback
# `|| true` keeps an untagged repo from aborting under `set -e`/`pipefail`.
VERSION="${MARKETING_VERSION:-${VERSION:-}}"
if [ -z "$VERSION" ] && [ -f VERSION ]; then
    VERSION="$(tr -d '[:space:]' < VERSION)"
fi
if [ -z "$VERSION" ]; then
    VERSION="$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)"
fi
VERSION="${VERSION:-0.0.0-dev}"
BUILD="$(git rev-list --count HEAD 2>/dev/null || echo 1)"

echo "==> Assembling $APP (version $VERSION build $BUILD)"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/GoToBed"
cp "$PLIST" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" "$APP/Contents/Info.plist"
if [ -f Packaging/AppIcon.icns ]; then
    cp Packaging/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
fi

echo "==> Verifying universal binary"
lipo -archs "$APP/Contents/MacOS/GoToBed"

echo "==> Code signing (identity: $IDENTITY)"
# --timestamp + --options runtime are required for notarization. Ad-hoc ("-")
# signing ignores --timestamp, so it stays valid for local builds too.
TS_FLAG="--timestamp"
[ "$IDENTITY" = "-" ] && TS_FLAG="--timestamp=none"
codesign --force --options runtime $TS_FLAG \
    --entitlements "$ENTITLEMENTS" \
    --sign "$IDENTITY" \
    "$APP"

codesign --verify --verbose "$APP"

if [ -n "$NOTARY_PROFILE" ]; then
    echo "==> Notarizing (profile: $NOTARY_PROFILE)"
    ZIP="build/GoToBed-notarize.zip"
    /usr/bin/ditto -c -k --keepParent "$APP" "$ZIP"
    xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait
    echo "==> Stapling ticket"
    xcrun stapler staple "$APP"
    xcrun stapler validate "$APP"
    spctl --assess --type execute --verbose "$APP" || true
    rm -f "$ZIP"
fi

echo "==> Done: $APP"
