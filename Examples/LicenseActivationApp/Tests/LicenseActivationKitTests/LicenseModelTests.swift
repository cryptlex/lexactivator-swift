import XCTest
import LexActivator
@testable import LicenseActivationKit

/// Drives the model behind the sample screen, which is the code that actually
/// runs when the view appears. Skipped unless credentials are supplied.
final class LicenseModelTests: XCTestCase {
    private func skipUnlessConfigured() throws {
        let environment = ProcessInfo.processInfo.environment
        let keys = ["LEXACTIVATOR_PRODUCT_DATA", "LEXACTIVATOR_PRODUCT_ID", "LEXACTIVATOR_LICENSE_KEY"]
        guard keys.allSatisfy({ !(environment[$0] ?? "").isEmpty }) else {
            throw XCTSkip("Set \(keys.joined(separator: ", ")) to run the sample app tests.")
        }
    }

    /// Waits the way the UI does: until the model stops reporting itself busy.
    private func waitUntilIdle(_ model: LicenseModel, timeout: TimeInterval = 30) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            if !model.isBusy && !model.log.isEmpty { return }
        }
        XCTFail("model stayed busy for \(timeout)s")
    }

    @MainActor
    func testChecksTheLicenseAndActivatesWhenNeeded() throws {
        try skipUnlessConfigured()

        let model = LicenseModel()
        model.checkLicense()
        waitUntilIdle(model)

        XCTAssertTrue(model.isActivated, "check failed: \(model.log)")
        XCTAssertEqual(model.summary, "Activated")
        XCTAssertFalse(model.expiry.isEmpty, "the expiry should be shown once activated")
        XCTAssertTrue(
            model.log.contains { $0.hasPrefix("LexActivator ") },
            "the log should open with the library version: \(model.log)"
        )
        XCTAssertTrue(
            model.log.contains("License is genuinely activated!"),
            "unexpected log: \(model.log)"
        )

        // Release the activation so repeated runs do not exhaust the license.
        model.deactivate()
        waitUntilIdle(model)
        XCTAssertFalse(model.isActivated)
        XCTAssertTrue(model.log.contains("Activation released."))
    }

    /// A second check on an already-activated device must validate rather than
    /// activate again — otherwise every launch would consume an activation.
    @MainActor
    func testSecondCheckValidatesInsteadOfActivating() throws {
        try skipUnlessConfigured()

        let first = LicenseModel()
        first.checkLicense()
        waitUntilIdle(first)
        XCTAssertTrue(first.isActivated, "setup failed: \(first.log)")

        let second = LicenseModel()
        second.checkLicense()
        waitUntilIdle(second)

        XCTAssertTrue(second.isActivated)
        XCTAssertFalse(
            second.log.contains("Not activated on this device, activating…"),
            "an activated device should not activate again: \(second.log)"
        )

        second.deactivate()
        waitUntilIdle(second)
    }
}
