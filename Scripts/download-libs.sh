#!/bin/bash
#
# Downloads the darwin LexActivator static libraries and stages them for
# Scripts/build-xcframework.sh.
#
# Usage: Scripts/download-libs.sh
#
# The version below is the single place the native library version is recorded.
# Scripts/update-version.sh rewrites it, the Update version workflow commits
# that change, and the Publish workflow reads it back to build the release
# asset — the same arrangement the go and dotnet bindings use.
#
# The C headers in Sources/CLexActivator/include are deliberately NOT refreshed
# here. They are checked in and maintained by hand: they carry declarations this
# package adds on top of the shipped header, and a native bump should not
# silently rewrite the module's public surface. When a native release does
# change the headers, update them and LexActivatorError.swift by hand, in their
# own pull request.

set -euo pipefail

LEXACTIVATOR_VERSION="3.45.0"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE_URL="https://dl.cryptlex.com/downloads"
STAGE="$ROOT/build/native"
TMP="$ROOT/build/tmp"

rm -rf "$STAGE" "$TMP"
mkdir -p "$STAGE/macos" "$STAGE/ios" "$STAGE/ios-simulator" "$TMP"

echo "==> Downloading LexActivator v$LEXACTIVATOR_VERSION"
curl -fsSL -o "$TMP/LexActivator-Static-Mac.zip" \
  "$BASE_URL/v$LEXACTIVATOR_VERSION/LexActivator-Static-Mac.zip"
curl -fsSL -o "$TMP/LexActivator-Static-iOS.zip" \
  "$BASE_URL/v$LEXACTIVATOR_VERSION/LexActivator-Static-iOS.zip"
unzip -qo "$TMP/LexActivator-Static-Mac.zip" -d "$TMP/mac"
unzip -qo "$TMP/LexActivator-Static-iOS.zip" -d "$TMP/ios"

MAC_LIB="$TMP/mac/libs/clang/universal/libLexActivator.a"
IOS_XCFW="$TMP/ios/libs/universal/LexActivator.xcframework"
[ -f "$MAC_LIB" ]  || { echo "error: macOS static library missing in archive" >&2; exit 1; }
[ -d "$IOS_XCFW" ] || { echo "error: iOS xcframework missing in archive" >&2; exit 1; }

# The iOS slices ship as static frameworks whose binary is a plain ar archive.
# Extract them so every slice of our xcframework is a library slice.
echo "==> Staging static libraries"
cp "$MAC_LIB" "$STAGE/macos/libLexActivator.a"
cp "$IOS_XCFW/ios-arm64/LexActivator.framework/LexActivator" "$STAGE/ios/libLexActivator.a"
cp "$IOS_XCFW/ios-arm64_x86_64-simulator/LexActivator.framework/LexActivator" \
   "$STAGE/ios-simulator/libLexActivator.a"

rm -rf "$TMP"

echo "==> Staged LexActivator v$LEXACTIVATOR_VERSION in $STAGE"
