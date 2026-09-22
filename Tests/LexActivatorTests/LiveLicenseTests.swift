import XCTest
import LexActivator

/// End-to-end tests against the real Cryptlex service.
///
/// Skipped unless credentials are supplied, so `swift test` stays offline and
/// deterministic by default:
///
///     LEXACTIVATOR_PRODUCT_DATA=… \
///     LEXACTIVATOR_PRODUCT_ID=… \
///     LEXACTIVATOR_LICENSE_KEY=… \
///     swift test
///
/// The lifecycle runs as a single test because it activates and then releases a
/// real activation; splitting it across methods would leave the license in a
/// different state depending on execution order.
final class LiveLicenseTests: XCTestCase {
    private struct Credentials {
        let productData: String
        let productId: String
        let licenseKey: String
    }

    private func credentials() throws -> Credentials {
        let environment = ProcessInfo.processInfo.environment
        guard
            let productData = environment["LEXACTIVATOR_PRODUCT_DATA"], !productData.isEmpty,
            let productId = environment["LEXACTIVATOR_PRODUCT_ID"], !productId.isEmpty,
            let licenseKey = environment["LEXACTIVATOR_LICENSE_KEY"], !licenseKey.isEmpty
        else {
            throw XCTSkip("Set LEXACTIVATOR_PRODUCT_DATA, LEXACTIVATOR_PRODUCT_ID and LEXACTIVATOR_LICENSE_KEY to run live tests.")
        }
        return Credentials(productData: productData, productId: productId, licenseKey: licenseKey)
    }

    func testLicenseLifecycle() throws {
        let credentials = try credentials()

        try LexActivator.setProductData(credentials.productData)
        try LexActivator.setProductId(credentials.productId, flags: .LA_USER)
        try LexActivator.setLicenseKey(credentials.licenseKey)

        // A lookup does not consume an activation, so it is safe to assert on
        // before anything is written to the data store.
        let lookup = try LexActivator.lookupLicense(licenseKey: credentials.licenseKey)
        XCTAssertEqual(lookup.key, credentials.licenseKey)
        XCTAssertFalse(lookup.type.isEmpty)

        // Registering must succeed. The callback does not fire in this test:
        // it arrives on a background server sync, and activating in the same
        // process has just synced, leaving nothing to trigger. Delivery itself
        // is covered deterministically by LicenseCallbackTests; the firing path
        // was verified by registering in a fresh process on an already-activated
        // device, where it arrived about four seconds later.
        try LexActivator.setLicenseCallback { _ in }

        XCTAssertEqual(try LexActivator.activateLicense(), .LA_OK)

        XCTAssertEqual(try LexActivator.isLicenseGenuine(), .LA_OK)
        XCTAssertEqual(try LexActivator.isLicenseValid(), .LA_OK)
        XCTAssertEqual(try LexActivator.syncLicenseActivation(), .LA_OK)

        XCTAssertEqual(try LexActivator.getLicenseKey(), credentials.licenseKey)
        XCTAssertFalse(try LexActivator.getLicenseType().isEmpty)
        XCTAssertFalse(try LexActivator.getActivationId().isEmpty)
        XCTAssertGreaterThan(try LexActivator.getLicenseTotalActivations(), 0)
        XCTAssertNotNil(try LexActivator.getActivationLastSyncedDate())
        XCTAssertNil(try LexActivator.getLastActivationError())

        let mode = try LexActivator.getActivationMode()
        XCTAssertFalse(mode.initialMode.isEmpty)
        XCTAssertFalse(mode.currentMode.isEmpty)

        let store = try LexActivator.getDataStoreInfo()
        XCTAssertFalse(store.storageKind.isEmpty)

        // Applications read license state from whatever thread they happen to be
        // on — a SwiftUI body, a background refresh, a menu validation. Hammer
        // the read-only calls concurrently to catch any regression that makes
        // that unsafe.
        let iterations = 1_000
        let failures = NSLock()
        var concurrentFailures: [String] = []

        DispatchQueue.concurrentPerform(iterations: iterations) { iteration in
            do {
                switch iteration % 5 {
                case 0: _ = try LexActivator.isLicenseValid()
                case 1: _ = try LexActivator.getLicenseKey()
                case 2: _ = try LexActivator.getLicenseExpiryDate()
                case 3: _ = try LexActivator.getFeatureEntitlements()
                default: _ = try LexActivator.getActivationId()
                }
            } catch {
                failures.lock()
                concurrentFailures.append("\(error)")
                failures.unlock()
            }
        }

        XCTAssertTrue(
            concurrentFailures.isEmpty,
            "\(concurrentFailures.count)/\(iterations) concurrent reads failed: \(Set(concurrentFailures).prefix(3))"
        )

        // Always release the activation so repeated runs do not exhaust the license.
        try LexActivator.deactivateLicense()
        LexActivator.removeLicenseCallback()
    }

    /// A key that does not exist must fail with a typed, matchable error.
    func testUnknownLicenseKeyReportsATypedError() throws {
        let credentials = try credentials()

        try LexActivator.setProductData(credentials.productData)
        try LexActivator.setProductId(credentials.productId, flags: .LA_USER)
        try LexActivator.setLicenseKey("AAAAAA-BBBBBB-CCCCCC-DDDDDD-EEEEEE-FFFFFF")

        XCTAssertThrowsError(try LexActivator.activateLicense()) { error in
            guard let error = error as? LexActivatorError else {
                return XCTFail("expected a LexActivatorError, got \(error)")
            }
            XCTAssertEqual(error, .LA_E_LICENSE_KEY, "unexpected error: \(error.message)")
        }
    }
}
