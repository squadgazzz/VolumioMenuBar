#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="VolumioMenuBar"
APP_BUNDLE="${APP_NAME}.app"
ENTITLEMENTS="${APP_NAME}.entitlements"

echo "==> Building ${APP_NAME} (release)..."
swift build -c release

BINARY=$(swift build -c release --show-bin-path)/${APP_NAME}
if [ ! -f "$BINARY" ]; then
    echo "Error: Binary not found at ${BINARY}"
    exit 1
fi

echo "==> Creating app bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "$BINARY" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp AppIcon.icns "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"

# Resolve Xcode variable placeholders in Info.plist
sed -e 's/$(DEVELOPMENT_LANGUAGE)/en/g' \
    -e 's/$(EXECUTABLE_NAME)/'"${APP_NAME}"'/g' \
    -e 's/$(PRODUCT_BUNDLE_IDENTIFIER)/com.volumio.menubar/g' \
    -e 's/$(PRODUCT_NAME)/'"${APP_NAME}"'/g' \
    Info.plist > "${APP_BUNDLE}/Contents/Info.plist"

echo "==> Code-signing (ad-hoc)..."
codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_BUNDLE"

echo "==> Build complete: ${APP_BUNDLE}"

read -rp "Install to /Applications? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cp -R "$APP_BUNDLE" /Applications/
    echo "==> Installed to /Applications/${APP_BUNDLE}"
fi
