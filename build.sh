#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="VolumioMenuBar"
APP_BUNDLE="${APP_NAME}.app"
ENTITLEMENTS="${APP_NAME}.entitlements"

echo "==> Building ${APP_NAME} (arm64)..."
swift build -c release --triple arm64-apple-macosx

echo "==> Building ${APP_NAME} (x86_64)..."
swift build -c release --triple x86_64-apple-macosx

echo "==> Creating universal binary..."
BINARY=.build/${APP_NAME}-universal
lipo -create \
    .build/arm64-apple-macosx/release/${APP_NAME} \
    .build/x86_64-apple-macosx/release/${APP_NAME} \
    -output "$BINARY"

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
    -e 's/$(PRODUCT_NAME)/Volumio Menu Bar/g' \
    Info.plist > "${APP_BUNDLE}/Contents/Info.plist"

echo "==> Code-signing (ad-hoc)..."
codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_BUNDLE"

echo "==> Build complete: ${APP_BUNDLE}"

read -rp "Install to /Applications? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cp -R "$APP_BUNDLE" /Applications/
    echo "==> Installed to /Applications/${APP_BUNDLE}"
fi
