#!/usr/bin/env bash
set -euo pipefail

APP_NAME="ClipStack"
CONFIGURATION="${1:-release}"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT_DIR/.build"
APP_DIR="$ROOT_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BUILD_DIR/$CONFIGURATION/$APP_NAME" "$MACOS_DIR/$APP_NAME"
cp "$ROOT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"

if command -v xcrun >/dev/null && ACTOOL="$(xcrun -f actool 2>/dev/null)" && [ -d "$ROOT_DIR/Assets.xcassets" ]; then
  "$ACTOOL" "$ROOT_DIR/Assets.xcassets" \
    --compile "$RESOURCES_DIR" \
    --platform macosx \
    --minimum-deployment-target 13.0 \
    --app-icon AppIcon \
    --output-partial-info-plist "$BUILD_DIR/assetcatalog-info.plist" >/dev/null
elif command -v iconutil >/dev/null && [ -d "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset" ]; then
  ICONSET_DIR="$BUILD_DIR/AppIcon.iconset"
  rm -rf "$ICONSET_DIR"
  mkdir -p "$ICONSET_DIR"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-16.png" "$ICONSET_DIR/icon_16x16.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-32.png" "$ICONSET_DIR/icon_16x16@2x.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-32.png" "$ICONSET_DIR/icon_32x32.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-64.png" "$ICONSET_DIR/icon_32x32@2x.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-128.png" "$ICONSET_DIR/icon_128x128.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-256.png" "$ICONSET_DIR/icon_128x128@2x.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-256.png" "$ICONSET_DIR/icon_256x256.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-512.png" "$ICONSET_DIR/icon_256x256@2x.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-512.png" "$ICONSET_DIR/icon_512x512.png"
  cp "$ROOT_DIR/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" "$ICONSET_DIR/icon_512x512@2x.png"
  iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
fi

echo "Built $APP_DIR"
