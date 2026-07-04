#!/usr/bin/env bash
set -euo pipefail

APP_NAME="ClipStack"
VOLUME_NAME="Install ClipStack"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="$ROOT_DIR/$APP_NAME.app"
DIST_DIR="$ROOT_DIR/dist"
STAGING_DIR="$ROOT_DIR/.dmg-staging"
RW_DMG="$DIST_DIR/$APP_NAME-rw.dmg"
FINAL_DMG="$DIST_DIR/$APP_NAME.dmg"
BACKGROUND_DIR="$STAGING_DIR/.background"
BACKGROUND_PATH="$BACKGROUND_DIR/background.png"

cd "$ROOT_DIR"
./build_app.sh release

rm -rf "$DIST_DIR" "$STAGING_DIR"
mkdir -p "$DIST_DIR" "$BACKGROUND_DIR"

cp -R "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

swift - "$BACKGROUND_PATH" <<'SWIFT'
import AppKit
import Foundation

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let size = NSSize(width: 720, height: 460)
let image = NSImage(size: size)

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
}

func drawText(_ text: String, at point: NSPoint, fontSize: CGFloat, weight: NSFont.Weight, color textColor: NSColor, alignment: NSTextAlignment = .center) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: weight),
        .foregroundColor: textColor,
        .paragraphStyle: paragraph
    ]
    let rect = NSRect(x: point.x, y: point.y, width: 720 - point.x * 2, height: fontSize * 2.2)
    text.draw(in: rect, withAttributes: attributes)
}

image.lockFocus()

let bounds = NSRect(origin: .zero, size: size)
let gradient = NSGradient(colors: [
    color(2, 28, 105),
    color(95, 35, 214),
    color(255, 36, 149),
    color(255, 171, 25)
])!
gradient.draw(in: bounds, angle: -28)

let glowColors: [(NSColor, NSPoint, CGFloat)] = [
    (color(0, 234, 255, 0.34), NSPoint(x: 80, y: 88), 180),
    (color(255, 255, 255, 0.22), NSPoint(x: 350, y: 330), 210),
    (color(60, 255, 112, 0.28), NSPoint(x: 642, y: 92), 190)
]

for (glow, center, radius) in glowColors {
    glow.setFill()
    NSBezierPath(ovalIn: NSRect(x: center.x - radius / 2, y: center.y - radius / 2, width: radius, height: radius)).fill()
}

for offset in stride(from: -180, through: 860, by: 82) {
    let path = NSBezierPath()
    path.move(to: NSPoint(x: CGFloat(offset), y: 95))
    path.curve(
        to: NSPoint(x: CGFloat(offset + 360), y: 360),
        controlPoint1: NSPoint(x: CGFloat(offset + 100), y: 205),
        controlPoint2: NSPoint(x: CGFloat(offset + 215), y: 250)
    )
    color(255, 255, 255, 0.13).setStroke()
    path.lineWidth = 3
    path.stroke()
}

drawText("ClipStack", at: NSPoint(x: 44, y: 370), fontSize: 34, weight: .bold, color: .white)
drawText("Drag the app into Applications", at: NSPoint(x: 44, y: 333), fontSize: 16, weight: .semibold, color: color(255, 255, 255, 0.82))

let arrow = NSBezierPath()
arrow.move(to: NSPoint(x: 282, y: 214))
arrow.line(to: NSPoint(x: 435, y: 214))
arrow.move(to: NSPoint(x: 410, y: 238))
arrow.line(to: NSPoint(x: 435, y: 214))
arrow.line(to: NSPoint(x: 410, y: 190))
color(255, 255, 255, 0.82).setStroke()
arrow.lineWidth = 7
arrow.lineCapStyle = .round
arrow.lineJoinStyle = .round
arrow.stroke()

drawText("Copy faster. Paste smarter.", at: NSPoint(x: 44, y: 32), fontSize: 13, weight: .medium, color: color(255, 255, 255, 0.72))

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    throw NSError(domain: "ClipStackDMGBackground", code: 1)
}

try png.write(to: output)
SWIFT

hdiutil create "$RW_DMG" \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -fsargs "-c c=64,a=16,e=16" \
  -format UDRW \
  -ov >/dev/null

DEVICE="$(hdiutil attach "$RW_DMG" -readwrite -noverify -noautoopen | awk '/Apple_HFS/ { print $1 }')"
MOUNT_POINT="/Volumes/$VOLUME_NAME"

sleep 2

osascript <<APPLESCRIPT >/dev/null 2>&1 || true
tell application "Finder"
  tell disk "$VOLUME_NAME"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {120, 120, 840, 580}
    set theViewOptions to the icon view options of container window
    set arrangement of theViewOptions to not arranged
    set icon size of theViewOptions to 96
    set background picture of theViewOptions to file ".background:background.png"
    set position of item "$APP_NAME.app" of container window to {190, 230}
    set position of item "Applications" of container window to {530, 230}
    close
    open
    update without registering applications
    delay 1
  end tell
end tell
APPLESCRIPT

sync
hdiutil detach "$DEVICE" >/dev/null
hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -o "$FINAL_DMG" -ov >/dev/null
rm -f "$RW_DMG"

echo "Built $FINAL_DMG"
