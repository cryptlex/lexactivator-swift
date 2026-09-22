// Deliberately empty.
//
// The LexActivator implementation lives in the prebuilt static library vended
// by the LexActivatorNative binary target. This target exists only to expose
// the C headers in include/ to Swift as the `CLexActivator` clang module, and
// to carry the linker settings the static archive needs.
//
// SwiftPM historically refused a target with no source files, which is why a
// placeholder like this is the usual pattern for a headers-only C target.
// Current SwiftPM (verified on Swift 6.1.2) builds the target fine without it.
// It is kept because the manifest declares swift-tools-version 5.7, and the
// older toolchains that range admits have not been tested. Narrow the declared
// floor to a version that is actually tested and this file can go.
