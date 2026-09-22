// swift-tools-version: 5.7
import PackageDescription
import Foundation

// SwiftPM identifies a path dependency by the name of its directory, which
// changes with the folder this repository is cloned into. Deriving it keeps the
// sample building from any checkout. A package referenced by URL — the line
// commented out below — does not need this.
let lexActivatorPackage = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // this sample
    .deletingLastPathComponent()  // Examples
    .deletingLastPathComponent()  // repository root
    .lastPathComponent
    .lowercased()

let package = Package(
    name: "LicenseActivationCLI",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        // In your own project, point this at the published package instead:
        // .package(url: "https://github.com/cryptlex/lexactivator-swift.git", from: "3.45.0"),
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "LicenseActivationCLI",
            dependencies: [.product(name: "LexActivator", package: lexActivatorPackage)]
        )
    ]
)
