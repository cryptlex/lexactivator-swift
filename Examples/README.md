# Examples

Three samples, all doing the same thing: check the license, activate the device
if it is not activated yet, show the expiry.

Before running any of them, open the sample's `Configuration.swift` and replace
the placeholders with your product data, product id and a license key from the
Cryptlex dashboard.

## LicenseActivationCLI

A command line tool.

```bash
cd Examples/LicenseActivationCLI
swift run LicenseActivationCLI              # check, activating if needed
swift run LicenseActivationCLI deactivate   # release this device's activation
```

The run does not exit immediately: `isLicenseGenuine()` starts a server sync on
a background thread, and the sample waits at a prompt so you can see the
callback result arrive a few seconds later.

## LicenseActivationApp

The same flow as a SwiftUI screen, shared between iOS and macOS. One button
releases the activation.

```bash
# from the repository root
Scripts/run-sample.sh macos
```

## iOSApp

An Xcode project, which is how you would ship this in a real application.
Open `LexActivatorSample.xcodeproj` and run it, or:

```bash
Scripts/run-sample.sh ios "iPhone 16 Pro"
```

## Before you start

Xcode 14 or later, plus an iOS Simulator runtime for the iOS sample. The iOS
scripts use `xcodebuild` and `xcrun simctl`, so the full Xcode must be selected:

```bash
xcode-select -p     # must print .../Xcode.app/Contents/Developer
```

If it prints `/Library/Developer/CommandLineTools`, run
`sudo xcode-select -s /Applications/Xcode.app`.
