#!/bin/bash
#
# Builds and runs the SwiftUI sample.
#
#   Scripts/run-sample.sh macos
#   Scripts/run-sample.sh ios
#   Scripts/run-sample.sh ios "iPhone 16 Pro"
#
# Credentials come from each sample's Configuration.swift. The sample checks the
# license as soon as it appears, so there is nothing to tap.
#
# macOS gets a hand-assembled .app bundle: without one the process has no Dock
# presence and no reliable window focus. iOS needs the Xcode project in
# Examples/iOSApp — LexActivator keeps its device fingerprint in the keychain,
# keychain access needs entitlements, and a hand-assembled bundle carrying
# entitlements is refused by AMFI at launch.

set -euo pipefail

PLATFORM="${1:?usage: run-sample.sh <macos|ios> [device]}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

export LEXACTIVATOR_LOCAL_XCFRAMEWORK="${LEXACTIVATOR_LOCAL_XCFRAMEWORK:-1}"

case "$PLATFORM" in
macos)
  SAMPLE="$ROOT/Examples/LicenseActivationApp"
  APP_NAME="LicenseActivationApp"
  APP="$ROOT/build/sample-app/macos/$APP_NAME.app"

  swift build --package-path "$SAMPLE" --configuration release > /dev/null
  BIN_PATH="$(swift build --package-path "$SAMPLE" --configuration release --show-bin-path)"

  rm -rf "$APP"
  mkdir -p "$APP/Contents/MacOS"
  cp "$BIN_PATH/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"

  cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>$APP_NAME</string>
    <key>CFBundleIdentifier</key><string>com.cryptlex.lexactivator.sample</string>
    <key>CFBundleName</key><string>LexActivator Sample</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>11.0</string>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

  codesign --force --sign - "$APP" > /dev/null 2>&1 || true
  echo "==> Built $APP"
  open "$APP"
  echo "==> Launched"
  ;;

ios)
  PROJECT="$ROOT/Examples/iOSApp/LexActivatorSample.xcodeproj"
  BUNDLE_ID="com.cryptlex.LexActivatorSample"
  DERIVED="$ROOT/build/ios-sample"

  # A udid rather than a name: `-destination "name=iPhone 15 Pro"` pairs the
  # name with the *latest* installed runtime, and a device may only exist on an
  # older one, which fails with "no available devices matched the request".
  DEVICE="$(python3 - "${2:-}" <<'PY'
import json
import subprocess
import sys

wanted = sys.argv[1] or None
devices = json.loads(
    subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"])
)["devices"]


def runtime_version(identifier):
    # com.apple.CoreSimulator.SimRuntime.iOS-18-6 -> (18, 6)
    tail = identifier.rsplit(".", 1)[-1].split("-")[1:]
    return tuple(int(part) for part in tail if part.isdigit())


candidates = []
for runtime, entries in devices.items():
    if "iOS" not in runtime:
        continue
    for device in entries:
        if wanted is not None:
            if wanted not in (device["name"], device["udid"]):
                continue
        elif not device["name"].startswith("iPhone"):
            continue
        # Booted first, then the newest runtime: booting a second simulator is
        # slow, and the newest runtime is what a released app is tested against.
        candidates.append((device["state"] == "Booted", runtime_version(runtime), device["udid"]))

if not candidates:
    sys.stderr.write("error: no matching iOS simulator is available\n")
    raise SystemExit(1)

print(max(candidates)[2])
PY
)"
  NAME="$(xcrun simctl list devices | sed -n "s/^ *\(.*\) ($DEVICE).*/\1/p" | head -1)"

  echo "==> Building for ${NAME:-$DEVICE}"
  xcodebuild -project "$PROJECT" -scheme LexActivatorSample \
    -destination "platform=iOS Simulator,id=$DEVICE" \
    -derivedDataPath "$DERIVED" build > /dev/null

  APP="$(find "$DERIVED/Build/Products" -name 'LexActivatorSample.app' -maxdepth 2 | head -1)"
  [ -n "$APP" ] || { echo "error: built app not found" >&2; exit 1; }

  echo "==> Booting ${NAME:-$DEVICE}"
  xcrun simctl boot "$DEVICE" 2>/dev/null || true
  xcrun simctl bootstatus "$DEVICE" -b > /dev/null

  echo "==> Installing"
  xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl install "$DEVICE" "$APP"

  echo "==> Launching"
  # SIMCTL_CHILD_* forwards a variable into the app running on the simulator.
  # Credentials are not forwarded: the sample reads them from Configuration.swift,
  # the same way a real application would.
  SIMCTL_CHILD_LEXACTIVATOR_RELEASE_AFTER_CHECK="${LEXACTIVATOR_RELEASE_AFTER_CHECK:-}" \
    xcrun simctl launch "$DEVICE" "$BUNDLE_ID"

  open -a Simulator 2>/dev/null || true
  echo
  echo "Log: xcrun simctl spawn '$DEVICE' log stream --predicate 'process == \"LexActivatorSample\"'"
  ;;

*)
  echo "usage: $0 <macos|ios> [device]" >&2
  exit 1
  ;;
esac
