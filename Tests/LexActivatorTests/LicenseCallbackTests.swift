import XCTest
@testable import LexActivator

/// The native library decides *when* the license callback fires — only when a
/// background server sync happens, which an application cannot force. These
/// tests drive the bridge the same way the native library does, so everything
/// on this side of the C boundary is covered deterministically.
final class LicenseCallbackTests: XCTestCase {
    override func tearDown() {
        LicenseCallbackBox.shared.setHandler(nil)
        super.tearDown()
    }

    func testTrampolineDeliversMappedStatuses() {
        var received: [LicenseCallbackResult] = []
        LicenseCallbackBox.shared.setHandler { received.append($0) }

        // The native library passes the status as a uint32.
        licenseCallbackTrampoline(code: 0)
        licenseCallbackTrampoline(code: 20)
        licenseCallbackTrampoline(code: 21)

        XCTAssertEqual(received, [.status(.LA_OK), .status(.LA_EXPIRED), .status(.LA_SUSPENDED)])
    }

    /// The codes the header documents for this callback must all arrive as
    /// something the caller can act on, not as an unknown blob.
    func testTrampolineDeliversDocumentedFailures() {
        var received: [LicenseCallbackResult] = []
        LicenseCallbackBox.shared.setHandler { received.append($0) }

        // LA_E_REVOKED, LA_E_ACTIVATION_NOT_FOUND, LA_E_MACHINE_FINGERPRINT,
        // LA_E_AUTHENTICATION_FAILED, LA_E_COUNTRY, LA_E_INET, LA_E_SERVER,
        // LA_E_RATE_LIMIT, LA_E_IP — the set SetLicenseCallback documents.
        for code in [53, 59, 63, 71, 81, 48, 91, 90, 82] as [UInt32] {
            licenseCallbackTrampoline(code: code)
        }

        XCTAssertEqual(received.count, 9)
        XCTAssertEqual(received.first, .failure(.LA_E_REVOKED))
        XCTAssertEqual(received[1], .failure(.LA_E_ACTIVATION_NOT_FOUND))
        for result in received {
            guard case .failure(let error) = result else {
                return XCTFail("expected a failure, got \(result)")
            }
            if case .unknown = error {
                XCTFail("documented callback code \(error.code) is not mapped")
            }
        }
    }

    func testRemovingTheHandlerStopsDelivery() {
        var received = 0
        LicenseCallbackBox.shared.setHandler { _ in received += 1 }
        licenseCallbackTrampoline(code: 0)
        XCTAssertEqual(received, 1)

        LexActivator.removeLicenseCallback()
        licenseCallbackTrampoline(code: 0)
        XCTAssertEqual(received, 1, "the handler kept receiving after removal")
    }

    /// A callback arriving on a library thread while the app replaces the
    /// handler must not race. This is the crash an app would see in the field.
    func testHandlerSurvivesConcurrentDeliveryAndReplacement() {
        let deliveries = 500
        let finished = expectation(description: "all callbacks delivered")
        finished.expectedFulfillmentCount = deliveries

        let counter = NSLock()
        var received = 0

        LicenseCallbackBox.shared.setHandler { _ in
            counter.lock()
            received += 1
            counter.unlock()
            finished.fulfill()
        }

        // Deliveries from many threads at once, while the handler is swapped
        // underneath them.
        DispatchQueue.concurrentPerform(iterations: deliveries) { iteration in
            if iteration % 50 == 0 {
                LicenseCallbackBox.shared.setHandler { _ in
                    counter.lock()
                    received += 1
                    counter.unlock()
                    finished.fulfill()
                }
            }
            licenseCallbackTrampoline(code: 0)
        }

        wait(for: [finished], timeout: 10)
        counter.lock()
        XCTAssertEqual(received, deliveries)
        counter.unlock()
    }

    /// The callback is invoked on whatever thread the library used, and must
    /// not be silently hopped to main — apps rely on knowing that.
    func testCallbackRunsOnTheCallingThread() {
        let delivered = expectation(description: "callback delivered")
        var wasMainThread: Bool?

        LicenseCallbackBox.shared.setHandler { _ in
            wasMainThread = Thread.isMainThread
            delivered.fulfill()
        }

        DispatchQueue.global().async { licenseCallbackTrampoline(code: 0) }

        wait(for: [delivered], timeout: 5)
        XCTAssertEqual(wasMainThread, false, "the callback should arrive on the library's thread")
    }
}
