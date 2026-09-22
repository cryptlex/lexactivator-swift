#!/bin/bash
#
# Builds Artifacts/LexActivatorNative.xcframework from the libraries staged by
# Scripts/download-libs.sh, links a real executable against every slice, then
# zips it and prints the SwiftPM checksum.
#
# Usage: Scripts/build-xcframework.sh
#
# The xcframework is assembled directly rather than with
# `xcodebuild -create-xcframework`. An xcframework is a directory of static
# libraries plus an Info.plist, and the plist written here is byte-identical to
# the one xcodebuild produces. Doing it ourselves keeps the checksum — which
# every published manifest pins — independent of the Xcode version on the
# machine that happens to run the build, and lets everything except the link
# check run without Xcode at all.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STAGE="$ROOT/build/native"
OUT="$ROOT/Artifacts"
NAME="LexActivatorNative"
XCFRAMEWORK="$OUT/$NAME.xcframework"

[ -d "$STAGE" ] || { echo "error: run Scripts/download-libs.sh first" >&2; exit 1; }

rm -rf "$XCFRAMEWORK" "$XCFRAMEWORK.zip"
mkdir -p "$OUT"

echo "==> Assembling $NAME.xcframework"
python3 - "$XCFRAMEWORK" "$STAGE" <<'PYTHON'
import pathlib
import plistlib
import shutil
import sys

xcframework, stage = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])

# identifier, platform, architectures, platform variant, staged directory
SLICES = [
    ("ios-arm64", "ios", ["arm64"], None, "ios"),
    ("ios-arm64_x86_64-simulator", "ios", ["arm64", "x86_64"], "simulator", "ios-simulator"),
    ("macos-arm64_x86_64", "macos", ["arm64", "x86_64"], None, "macos"),
]

libraries = []
for identifier, platform, architectures, variant, staged in SLICES:
    source = stage / staged / "libLexActivator.a"
    if not source.is_file():
        sys.exit(f"error: missing staged library {source}")
    (xcframework / identifier).mkdir(parents=True)
    shutil.copy2(source, xcframework / identifier / "libLexActivator.a")

    entry = {
        "BinaryPath": "libLexActivator.a",
        "LibraryIdentifier": identifier,
        "LibraryPath": "libLexActivator.a",
        "SupportedArchitectures": architectures,
        "SupportedPlatform": platform,
    }
    if variant is not None:
        entry["SupportedPlatformVariant"] = variant
    libraries.append(entry)

# Sorted by identifier and written with sorted keys: xcodebuild emits this list
# in an order that varies between runs, which alone would change the checksum.
libraries.sort(key=lambda library: library["LibraryIdentifier"])

with open(xcframework / "Info.plist", "wb") as handle:
    plistlib.dump(
        {
            "AvailableLibraries": libraries,
            "CFBundlePackageType": "XFWK",
            "XCFrameworkFormatVersion": "1.0",
        },
        handle,
        sort_keys=True,
    )
PYTHON

# Building the Swift library only compiles; it never runs the linker against the
# static archive, so a missing system framework — UIKit on iOS, for instance —
# would first surface in a customer's app. Link a real executable instead.
echo "==> Link-checking every slice"
WORK="$ROOT/build/link-check"
rm -rf "$WORK"
mkdir -p "$WORK"

cat > "$WORK/main.c" <<'EOF'
#include "LexActivator.h"
#include <stdio.h>

int main(void) {
    char version[256];
    int status = GetLibraryVersion(version, sizeof(version));
    printf("%d %s\n", status, version);
    return status;
}
EOF

# slice | target triple | sdk | extra frameworks
link() {
  local slice="$1" target="$2" sdk="$3" extra="$4"
  echo "    $slice"
  # shellcheck disable=SC2086
  xcrun clang \
    ${target:+-target "$target"} \
    ${sdk:+-isysroot "$(xcrun --sdk "$sdk" --show-sdk-path)"} \
    -I "$ROOT/Sources/CLexActivator/include" \
    "$WORK/main.c" "$XCFRAMEWORK/$slice/libLexActivator.a" \
    -framework CoreFoundation -framework Security -framework SystemConfiguration $extra \
    -lc++ \
    -o "$WORK/link-check-$slice"
}

link "macos-arm64_x86_64"         ""                              ""                ""
link "ios-arm64"                  "arm64-apple-ios13.0"           "iphoneos"        "-framework UIKit"
link "ios-arm64_x86_64-simulator" "arm64-apple-ios13.0-simulator" "iphonesimulator" "-framework UIKit"

# The macOS binary is the only one this host can execute; running it proves the
# library initialises rather than merely resolving its symbols.
"$WORK/link-check-macos-arm64_x86_64"

echo "==> Zipping"
# The checksum has to be reproducible: anyone should be able to rebuild this
# zip and get the byte-identical file the release advertises. That needs the
# three sources of nondeterminism pinned — modification times, entry order, and
# the extra attributes zip stores by default (-X).
find "$XCFRAMEWORK" -exec touch -t 202001010000 {} +
(cd "$OUT" && find "$NAME.xcframework" -print | sort | zip -qy -X "$NAME.xcframework.zip" -@)

CHECKSUM="$(cd "$ROOT" && swift package compute-checksum "$XCFRAMEWORK.zip")"
echo "$CHECKSUM" > "$OUT/$NAME.xcframework.zip.checksum"

echo
echo "xcframework: $XCFRAMEWORK"
echo "zip:         $XCFRAMEWORK.zip"
echo "checksum:    $CHECKSUM"
