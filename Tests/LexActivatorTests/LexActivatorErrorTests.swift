import XCTest
import CLexActivator
@testable import LexActivator

/// Guards the hand-written Swift error surface against the C headers it mirrors.
final class LexActivatorErrorTests: XCTestCase {
    /// Every case must round-trip through its native code.
    func testErrorCodesRoundTrip() {
        for code in Int32(0)...Int32(200) {
            let error = LexActivatorError(code: code)
            if case .unknown = error { continue }
            XCTAssertEqual(error.code, code, "LexActivatorError(code: \(code)) reports code \(error.code)")
        }
    }

    /// The Swift cases must agree with the constants in LexStatusCodes.h. If a
    /// native upgrade renumbers a code, this fails instead of silently
    /// mislabelling errors in production.
    func testCasesMatchNativeConstants() {
        let expected: [(LexActivatorError, LexStatusCodes)] = [
            (.LA_FAIL, LA_FAIL),
            (.LA_E_FILE_PATH, LA_E_FILE_PATH),
            (.LA_E_PRODUCT_FILE, LA_E_PRODUCT_FILE),
            (.LA_E_PRODUCT_DATA, LA_E_PRODUCT_DATA),
            (.LA_E_PRODUCT_ID, LA_E_PRODUCT_ID),
            (.LA_E_BUFFER_SIZE, LA_E_BUFFER_SIZE),
            (.LA_E_REVOKED, LA_E_REVOKED),
            (.LA_E_LICENSE_KEY, LA_E_LICENSE_KEY),
            (.LA_E_ACTIVATION_LIMIT, LA_E_ACTIVATION_LIMIT),
            (.LA_E_ACTIVATION_NOT_FOUND, LA_E_ACTIVATION_NOT_FOUND),
            (.LA_E_DEACTIVATION_LIMIT, LA_E_DEACTIVATION_LIMIT),
            (.LA_E_INET, LA_E_INET),
            (.LA_E_METADATA_KEY_NOT_FOUND, LA_E_METADATA_KEY_NOT_FOUND),
            (.LA_E_METER_ATTRIBUTE_NOT_FOUND, LA_E_METER_ATTRIBUTE_NOT_FOUND),
            (.LA_E_FEATURE_ENTITLEMENT_NOT_FOUND, LA_E_FEATURE_ENTITLEMENT_NOT_FOUND),
            (.LA_E_ENTITLEMENT_SET_NOT_LINKED, LA_E_ENTITLEMENT_SET_NOT_LINKED),
            (.LA_E_USER_NOT_AUTHENTICATED, LA_E_USER_NOT_AUTHENTICATED),
            (.LA_E_RATE_LIMIT, LA_E_RATE_LIMIT),
            (.LA_E_SERVER, LA_E_SERVER),
            (.LA_E_CLIENT, LA_E_CLIENT),
            (.LA_E_ACTIVATION_CLONE_DETECTED, LA_E_ACTIVATION_CLONE_DETECTED),
        ]

        for (error, native) in expected {
            XCTAssertEqual(error.code, Int32(native.rawValue), "\(error) does not match its native constant")
        }
    }

    /// The internal buffer-growth path keys off LA_E_BUFFER_SIZE.
    func testBufferSizeConstantMatchesNative() {
        XCTAssertEqual(Native.bufferTooSmall, Int32(LA_E_BUFFER_SIZE.rawValue))
        XCTAssertEqual(Native.ok, Int32(LA_OK.rawValue))
    }

    func testUnknownCodeIsPreserved() {
        let error = LexActivatorError(code: 9_999)
        XCTAssertEqual(error, .unknown(code: 9_999))
        XCTAssertEqual(error.code, 9_999)
        XCTAssertTrue(error.message.contains("9999"))
    }

    func testEveryCaseHasAMessage() {
        for code in Int32(0)...Int32(200) {
            let error = LexActivatorError(code: code)
            XCTAssertFalse(error.message.isEmpty, "code \(code) has no message")
        }
    }

    func testErrorIsPresentableToUsers() {
        let error = LexActivatorError.LA_E_ACTIVATION_LIMIT
        XCTAssertEqual(error.errorDescription, error.message)
        XCTAssertTrue(error.description.contains("58"))
    }
}
