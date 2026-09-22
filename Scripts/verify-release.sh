#!/bin/bash
#
# Resolves the published package from a throwaway project, exactly as a
# customer would. Catches a wrong checksum, a missing release asset or a broken
# manifest before anyone else hits it.
#
# Usage: Scripts/verify-release.sh <owner/repo> <version>

set -euo pipefail

REPOSITORY="${1:?usage: verify-release.sh <owner/repo> <version>}"
VERSION="${2:?usage: verify-release.sh <owner/repo> <version>}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/Sources/Consumer"

cat > "$WORK/Package.swift" <<EOF
// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Consumer",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/${REPOSITORY}.git", exact: "${VERSION}")
    ],
    targets: [
        .executableTarget(
            name: "Consumer",
            dependencies: [.product(name: "LexActivator", package: "$(basename "$REPOSITORY")")]
        )
    ]
)
EOF

cat > "$WORK/Sources/Consumer/main.swift" <<'EOF'
import LexActivator

let version = try LexActivator.getLibraryVersion()
print("Resolved LexActivator \(version)")
guard !version.isEmpty else { fatalError("empty library version") }
EOF

echo "==> Resolving https://github.com/${REPOSITORY}.git @ ${VERSION}"
# Explicitly unset so the consumer build takes the published binary, never a
# local artifact that happens to be lying around.
env -u LEXACTIVATOR_LOCAL_XCFRAMEWORK swift run --package-path "$WORK" Consumer

echo "==> Release verified"
