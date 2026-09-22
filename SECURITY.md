# Security

## Reporting a vulnerability

Please report security issues privately to **support@cryptlex.com** rather than
opening a public issue.

Include the package version, the platform and OS version, and enough detail to
reproduce.

## Scope

This repository contains the Swift interface to LexActivator. The native
library itself is proprietary Cryptlex software distributed as a prebuilt
binary; vulnerabilities in it are handled through the same address and fixed in
a native release, which this package then picks up.

## Verifying the binary

The native library is published as a release asset and pinned in `Package.swift`
by SHA-256 checksum, so Swift Package Manager refuses a binary that does not
match what the release advertises.

The build is reproducible: modification times, archive entry order and the
xcframework's `Info.plist` ordering are all normalised, so rebuilding a given
native version produces a byte-identical zip. To verify a release yourself:

```bash
Scripts/download-libs.sh              # fetches the pinned native version
Scripts/build-xcframework.sh          # prints the checksum
grep nativeChecksum Package.swift     # must match
```

The xcframework is assembled by the script itself rather than by `xcodebuild`,
so the checksum does not depend on the installed Xcode. It does depend on the
`zip` implementation producing identical bytes, so verify on a macOS version
close to the one that built the release if a checksum does not reproduce.
