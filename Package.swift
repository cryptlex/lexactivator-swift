// swift-tools-version: 5.7
//
// LexActivator — Swift package for the Cryptlex LexActivator licensing library.
//
// By default the native library is fetched from the GitHub release that matches
// this package version. Set LEXACTIVATOR_LOCAL_XCFRAMEWORK=1 to build against a
// locally produced Artifacts/LexActivatorNative.xcframework instead:
//
//     Scripts/download-libs.sh
//     Scripts/build-xcframework.sh
//     LEXACTIVATOR_LOCAL_XCFRAMEWORK=1 swift build
//
import PackageDescription
import Foundation

// The GitHub repository that hosts the release assets. Change this if the
// package moves, or binary downloads keep pointing at the old repository.
let repository = "cryptlex/lexactivator-swift"

// The release this manifest is published under. The xcframework is attached to
// that release, so this has to match the git tag exactly — which is also why a
// published tag can never be moved or deleted: every consumer pinned to it
// resolves the asset through this URL.
//
// It normally equals the LexActivator version recorded in
// Scripts/download-libs.sh, and only diverges when the package needs a release
// of its own between two LexActivator versions.
let packageVersion = "3.45.0"

// SHA-256 of the xcframework zip attached to that release. Both this and the
// library version in Scripts/download-libs.sh are written by
// Scripts/update-version.sh.
let nativeChecksum = "11c8cd1b017865b85caa42463ee019f837c27972d0d470e368c4dc4af6e87525"

let useLocalBinary = ProcessInfo.processInfo.environment["LEXACTIVATOR_LOCAL_XCFRAMEWORK"] == "1"

let nativeTarget: Target = useLocalBinary
    ? .binaryTarget(
        name: "LexActivatorNative",
        path: "Artifacts/LexActivatorNative.xcframework"
      )
    : .binaryTarget(
        name: "LexActivatorNative",
        url: "https://github.com/\(repository)/releases/download/v\(packageVersion)/LexActivatorNative.xcframework.zip",
        checksum: nativeChecksum
      )

let package = Package(
    name: "LexActivator",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "LexActivator", targets: ["LexActivator"]),
    ],
    targets: [
        nativeTarget,
        .target(
            name: "CLexActivator",
            dependencies: ["LexActivatorNative"],
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("CoreFoundation"),
                .linkedFramework("Security"),
                .linkedFramework("SystemConfiguration"),
                // The iOS build of LexActivator reads device information through UIDevice.
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
                .linkedLibrary("c++"),
            ]
        ),
        .target(
            name: "LexActivator",
            dependencies: ["CLexActivator"],
            // Apple aggregates privacy manifests from a package's resource
            // bundles into the host app's privacy report.
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(name: "LexActivatorTests", dependencies: ["LexActivator"]),
    ]
)
