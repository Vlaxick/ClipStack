# ClipStack

A lightweight macOS clipboard manager built with Swift and SwiftUI.

## Download and Install

For normal installation, download **ClipStack.dmg** from the GitHub Releases page.

If you build it locally, open the generated disk image:

```bash
open dist/ClipStack.dmg
```

Then drag **ClipStack** onto the **Applications** folder inside the installer window.

After installing:

1. Open **Applications**.
2. Launch **ClipStack**.
3. If macOS shows a security warning, open **System Settings → Privacy & Security** and choose **Open Anyway**.
4. In ClipStack settings, turn on **Launch at Login** if you want it to start automatically.

To update an existing install:

```bash
pkill ClipStack
rm -rf /Applications/ClipStack.app
cp -R ClipStack.app /Applications/
open /Applications/ClipStack.app
```

## Features

- Lives in the macOS menu bar with no Dock icon.
- Includes a polished welcome/settings window for onboarding, launch-at-login, and support links.
- Supports Launch at Login with `SMAppService` on macOS 13+.
- Monitors `NSPasteboard.general` every 0.5 seconds.
- Stores the last 10 unique clipboard items.
- Supports plain text and images from PNG, TIFF, or standard `NSImage` pasteboard data.
- Moves duplicate clips back to the top instead of storing them twice.
- Shows a compact SwiftUI popover with text previews, image thumbnails, hover highlighting, click-to-copy, and a clear-history button.
- Shows the welcome/settings window automatically on first launch.

## Build and Run

Build the app bundle:

```bash
./build_app.sh
open ClipStack.app
```

Build the colorful drag-to-Applications installer:

```bash
./build_dmg.sh
open dist/ClipStack.dmg
```

The generated `.dmg` is intended for GitHub Releases, not for committing directly to git.

To build a debug app bundle:

```bash
./build_app.sh debug
open ClipStack.app
```

## Project Layout

- `Package.swift`: Swift Package manifest.
- `Sources/ClipboardManager/ClipboardManagerApp.swift`: SwiftUI app entry point.
- `Sources/ClipboardManager/AppDelegate.swift`: AppKit lifecycle, status item, popover, and first-run onboarding.
- `Sources/ClipboardManager/ClipboardMonitor.swift`: Pasteboard polling and history management.
- `Sources/ClipboardManager/LoginItemController.swift`: `SMAppService` launch-at-login support.
- `Sources/ClipboardManager/WelcomeSettingsView.swift`: Minimal welcome/settings window.
- `Sources/ClipboardManager/ClipboardPopoverView.swift`: Menu bar popover UI.
- `Assets.xcassets`: App icon placeholder asset catalog.
- `Info.plist`: App bundle metadata, including `LSUIElement` so the app has no Dock icon.
- `build_app.sh`: Builds the Swift executable, compiles assets when available, and wraps everything in a minimal `.app` bundle.
- `build_dmg.sh`: Builds a polished `.dmg` installer with a colorful background, `ClipStack.app`, and an `Applications` shortcut.
