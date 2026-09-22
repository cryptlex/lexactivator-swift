#!/bin/bash
#
# Bumps the package to a new LexActivator version:
#
#   Scripts/update-version.sh 3.45.0          # package version follows the library
#   Scripts/update-version.sh 3.45.0 3.45.1   # package-only release
#
#   1. records the library version in Scripts/download-libs.sh
#   2. downloads the darwin static libraries
#   3. builds the xcframework and computes its checksum
#   4. pins the package version and that checksum into Package.swift
#
# Only two tracked files change: Scripts/download-libs.sh and Package.swift.
# The C headers, LexActivatorError.swift and THIRD-PARTY-NOTICES.txt are
# maintained by hand and are never touched by a version bump — see the comment
# at the top of Scripts/download-libs.sh.
#
# The last line printed is the space-separated list of files that changed, so
# the Update version workflow can commit exactly those.

set -euo pipefail

VERSION="${1:?usage: update-version.sh <libraryVersion> [packageVersion]}"
VERSION="${VERSION#v}"

# The package version is the git tag this is released under; it only differs
# from the library version when the package ships a fix of its own between two
# LexActivator releases. A tag is never reused, so the two can drift.
PACKAGE_VERSION="${2:-$VERSION}"
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Recording LexActivator $VERSION in Scripts/download-libs.sh"
python3 - "$ROOT/Scripts/download-libs.sh" LEXACTIVATOR_VERSION "$VERSION" <<'PY'
import pathlib, re, sys

path, name, value = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
source, count = re.subn(
    rf'^{name}="[^"]*"', f'{name}="{value}"', path.read_text(), flags=re.M
)
if count != 1:
    sys.exit(f"error: expected one `{name}=` in {path.name}, found {count}")
path.write_text(source)
PY

"$ROOT/Scripts/download-libs.sh"
"$ROOT/Scripts/build-xcframework.sh"
CHECKSUM="$(cat "$ROOT/Artifacts/LexActivatorNative.xcframework.zip.checksum")"

echo "==> Pinning package version $PACKAGE_VERSION into Package.swift"
python3 - "$ROOT/Package.swift" "$CHECKSUM" "$PACKAGE_VERSION" <<'PY'
import pathlib, re, sys

manifest = pathlib.Path(sys.argv[1])
checksum, package_version = sys.argv[2], sys.argv[3]
source = manifest.read_text()

for name, value in {"packageVersion": package_version, "nativeChecksum": checksum}.items():
    source, count = re.subn(rf'let {name} = "[^"]*"', f'let {name} = "{value}"', source)
    if count != 1:
        sys.exit(f"error: expected one `let {name}` in Package.swift, found {count}")

manifest.write_text(source)
PY

echo
echo "==> LexActivator $VERSION, released as v$PACKAGE_VERSION (checksum $CHECKSUM)"
echo "Package.swift Scripts/download-libs.sh"
