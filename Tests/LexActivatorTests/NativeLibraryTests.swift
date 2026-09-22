import XCTest
import LexActivator

/// Checks the package is actually bound to the native library it claims to be.
final class NativeLibraryTests: XCTestCase {
    func testLibraryVersionMatchesTheVendoredBinary() throws {
        let version = try LexActivator.getLibraryVersion()
        XCTAssertEqual(version, LexActivatorTestSupport.expectedNativeVersion)
    }

    func testLibraryVersionIsReadableWithoutConfiguration() throws {
        // Proves the binary links and runs before any product data is set —
        // the first thing to check when a consumer reports a link failure.
        XCTAssertFalse(try LexActivator.getLibraryVersion().isEmpty)
    }
}

enum LexActivatorTestSupport {
    /// The native version the package is pinned to, read from the one place it
    /// is recorded. Parsing it rather than restating it keeps the expectation
    /// correct across a version bump, which only rewrites that script and
    /// `Package.swift`.
    static let expectedNativeVersion: String = {
        // Tests/LexActivatorTests/<this file> -> repository root.
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let script = root.appendingPathComponent("Scripts/download-libs.sh")

        guard let source = try? String(contentsOf: script, encoding: .utf8) else {
            fatalError("cannot read \(script.path)")
        }
        for line in source.split(separator: "\n") where line.hasPrefix("LEXACTIVATOR_VERSION=") {
            return String(line.dropFirst("LEXACTIVATOR_VERSION=".count))
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
        fatalError("no LEXACTIVATOR_VERSION in \(script.path)")
    }()
}
