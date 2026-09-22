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
    name: "LicenseActivationApp",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        // Add this library to an iOS or macOS app target to reuse the sample UI.
        .library(name: "LicenseActivationKit", targets: ["LicenseActivationKit"]),
    ],
    dependencies: [
        // In your own project, point this at the published package instead:
        // .package(url: "https://github.com/cryptlex/lexactivator-swift.git", from: "3.45.0"),
        .package(path: "../..")
    ],
    targets: [
        .target(
            name: "LicenseActivationKit",
            dependencies: [.product(name: "LexActivator", package: lexActivatorPackage)]
        ),
        .executableTarget(name: "LicenseActivationApp", dependencies: ["LicenseActivationKit"]),
        .testTarget(name: "LicenseActivationKitTests", dependencies: ["LicenseActivationKit"]),
    ]
)
