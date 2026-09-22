## What this changes

<!-- And why. -->

## Checklist

- [ ] `swift build -Xswiftc -warnings-as-errors` passes
- [ ] `swift test` passes
- [ ] `Scripts/build-xcframework.sh` passes, if anything about linking or the binary changed
- [ ] `LexActivatorError.swift` updated to match, if the native status codes changed
      (headers and error codes belong in their own pull request, not a version bump)
- [ ] Public API changes are documented, and `CHANGELOG.md` is updated
