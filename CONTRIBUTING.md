# Contributing

## Getting set up

The published manifest downloads the native library from a GitHub release. For
local work, build it yourself instead:

```bash
Scripts/download-libs.sh      # fetch the pinned native libraries
Scripts/build-xcframework.sh  # assemble Artifacts/LexActivatorNative.xcframework
export LEXACTIVATOR_LOCAL_XCFRAMEWORK=1
swift build
swift test
```

`swift test` runs offline by default. Supply `LEXACTIVATOR_PRODUCT_DATA`,
`LEXACTIVATOR_PRODUCT_ID` and `LEXACTIVATOR_LICENSE_KEY` to also run the tests
that talk to the Cryptlex service.

## Before opening a pull request

```bash
swift build -Xswiftc -warnings-as-errors
swift test
```

CI does not run the tests today — the two workflows below only bump and
publish — so run them locally before opening a pull request.

## Things worth knowing

- **The C headers and `LexActivatorError.swift` are maintained by hand.** The
  headers carry declarations this package adds on top of the shipped ones, so a
  version bump never rewrites either file. When a native release changes a
  status code, update the header and all four places in `LexActivatorError.swift`
  — the `case`, `code`, `init(code:)` and `message` — in one pull request.
- **A library-only build never runs the linker.** A missing system framework
  shows up only when something links the static archive, which is what
  `Scripts/build-xcframework.sh` link-checks every slice for.
- **iOS needs a real app.** The native library keeps its device fingerprint in
  the keychain and crashes rather than erroring when the keychain is
  unavailable, so a bare `xctest` bundle cannot exercise it. iOS coverage goes
  through `Examples/iOSApp`.
- **Live tests consume activations.** Each one releases the activation it took;
  keep it that way, or a license runs out of activations after a few runs.

## Bumping the native version

Run the **Update version** workflow with the LexActivator version and the
package version to release as. It opens a pull request touching exactly two
files: the library version in `Scripts/download-libs.sh`, and the package
version plus xcframework checksum in `Package.swift`.

Once that is merged, run **Publish swift package**. It rebuilds the xcframework
from the pinned version, refuses to continue unless it reproduces the pinned
checksum, tags the commit, attaches the zip to the release, and then resolves
the package from a clean checkout to prove the release works.
