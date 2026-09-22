# LexActivator for Swift

![Platforms](https://img.shields.io/badge/platforms-iOS%2013%2B%20%7C%20macOS%2010.15%2B-lightgrey)
![Swift](https://img.shields.io/badge/swift-5.7%2B-orange)

A Swift package for [LexActivator](https://cryptlex.com), the Cryptlex software
licensing library. Add the package, import it, call it — no dylibs to copy, no
bridging headers to write, no linker flags to set.

Refer to following for documentation:

https://cryptlex.com/docs/sdks-and-apis/lexactivator

Supports **iOS 13+** and **macOS 10.15+**, on Apple silicon and Intel, device
and simulator.

## Installation

### Swift Package Manager

In Xcode, choose **File → Add Package Dependencies…** and enter:

```
https://github.com/cryptlex/lexactivator-swift.git
```

Or add it to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/cryptlex/lexactivator-swift.git", from: "3.45.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [.product(name: "LexActivator", package: "lexactivator-swift")]
    )
]
```

The native library ships as a static `xcframework`, so there is nothing to embed
and nothing to sign. It is downloaded and linked for you.

## Getting started

```swift
import LexActivator

// 1. Configure once, at launch.
try LexActivator.setProductData("<contents of Product.dat>")
try LexActivator.setProductId("<your product id>", flags: .LA_USER)
try LexActivator.setLicenseKey("XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX")

// 2. Activate.
switch try LexActivator.activateLicense() {
case .LA_OK:                startApplication()
case .LA_EXPIRED:           showRenewalScreen()
case .LA_SUSPENDED:         showSupportScreen()
case .LA_GRACE_PERIOD_OVER: showReconnectScreen()
}

// 3. Verify on every subsequent launch.
if try LexActivator.isLicenseGenuine() == .LA_OK {
    startApplication()
}
```

### Errors

Every failure is a `LexActivatorError`, so one `catch` handles anything the
library can report, and each case carries a message you can show to a user:

```swift
do {
    try LexActivator.activateLicense()
} catch let error as LexActivatorError {
    switch error {
    case .LA_E_INET:             show("No internet connection.")
    case .LA_E_ACTIVATION_LIMIT: show("This license is already in use on another device.")
    case .LA_E_LICENSE_KEY:      show("That license key is not valid.")
    default:                     show(error.message)
    }
}
```

Cases are named after the C constants, so a code seen in
[`LexStatusCodes.h`](Sources/CLexActivator/include/LexStatusCodes.h), the
[Cryptlex documentation](https://cryptlex.com/docs/sdks-and-apis/lexactivator)
or a support thread is the same spelling here — `LA_E_INET` is `.LA_E_INET`, not
`.inet`. `error.code` gives you the raw number, `error.message` the documented
text. A code newer than this package surfaces as `.unknown(code:)` rather than
being swallowed.

### Reacting to server-side changes

`isLicenseGenuine()` starts a server sync on a background thread when one is
due, and reports the outcome through a callback rather than in its return
value. That is how an application notices a license revoked, suspended or
expired on the server *while it is already running*.

```swift
// 1. Register before the first isLicenseGenuine(), or the first result is lost.
try LexActivator.setLicenseCallback { result in
    DispatchQueue.main.async {
        switch result {
        case .status(.LA_OK):       break
        case .status(let status):   handleLicenseProblem(status)
        case .failure(let error):   log(error)   // .LA_E_REVOKED, .LA_E_ACTIVATION_NOT_FOUND, …
        }
    }
}

// 2. Check first; only activate when this device has no activation yet.
if try LexActivator.isLicenseGenuine() == .LA_OK {
    startApplication()
}
```

## Documentation

Every public method carries a documentation comment, so the reference travels
with the package — nothing to install, nothing to browse to.

For licensing concepts — products, policies, entitlements, offline activation —
see the [Cryptlex documentation](https://cryptlex.com/docs/sdks-and-apis/lexactivator).

## Examples

Two runnable samples live in [`Examples/`](Examples):

- **[`LicenseActivationCLI`](Examples/LicenseActivationCLI)** — a command line
  tool: check the license, activate if needed, print the expiry.
- **[`LicenseActivationApp`](Examples/LicenseActivationApp)** — the same flow as
  a SwiftUI screen, shared by iOS and macOS.
- **[`iOSApp`](Examples/iOSApp)** — an Xcode iOS app project wired to the
  package, which is how you would ship it in a real application.

Fill in your product data, product id and license key in the sample's
`Configuration.swift`, then:

```bash
cd Examples/LicenseActivationCLI
swift run LicenseActivationCLI
```

See [`Examples/README.md`](Examples/README.md) for details.

## Working on the package

The published manifest resolves the native library from a GitHub release. To
build against a locally produced xcframework instead:

```bash
Scripts/download-libs.sh           # fetch the pinned native libraries
Scripts/build-xcframework.sh       # assemble and link-check the xcframework
LEXACTIVATOR_LOCAL_XCFRAMEWORK=1 swift build
LEXACTIVATOR_LOCAL_XCFRAMEWORK=1 swift test
```

`swift test` runs offline by default. Supply `LEXACTIVATOR_PRODUCT_DATA`,
`LEXACTIVATOR_PRODUCT_ID` and `LEXACTIVATOR_LICENSE_KEY` to also run the live
tests against the Cryptlex service.

| Script | What it does |
|---|---|
| `Scripts/download-libs.sh` | Downloads the native libraries for the version recorded at the top of the script |
| `Scripts/update-version.sh <lib> [pkg]` | Bumps to a new native version: rewrites that recorded version, rebuilds the xcframework, pins the package version and checksum |
| `Scripts/build-xcframework.sh` | Assembles the xcframework, link-checks every slice, zips it, prints the checksum |
| `Scripts/run-sample.sh <macos\|ios>` | Builds and runs the SwiftUI sample |
| `Scripts/verify-release.sh <repo> <version>` | Resolves the published package as a customer would |

### Releasing

Two workflows, both run manually:

1. **Update version** — takes a LexActivator version and the package version to
   release as, runs `Scripts/update-version.sh` and opens a pull request. That
   pull request changes two files and nothing else: the library version in
   `Scripts/download-libs.sh`, and the package version plus checksum in
   `Package.swift`. The two versions normally match; they only diverge when the
   package needs a release of its own between two LexActivator versions.
2. **Publish swift package** — builds the release asset from `main`, checks it
   reproduces the pinned checksum, tags the commit, attaches the zip to the
   release, then resolves the package from a throwaway project to prove the
   release works.

## Licensing

The Swift source in this repository is published under the terms in
[LICENSE](LICENSE). The bundled LexActivator native library is proprietary
Cryptlex software; see [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt).
