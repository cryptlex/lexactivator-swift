import XCTest
import CLexActivator
@testable import LexActivator

final class StatusTests: XCTestCase {
    func testLicenseStatusMatchesNativeConstants() {
        XCTAssertEqual(LicenseStatus.LA_OK.rawValue, Int32(LA_OK.rawValue))
        XCTAssertEqual(LicenseStatus.LA_EXPIRED.rawValue, Int32(LA_EXPIRED.rawValue))
        XCTAssertEqual(LicenseStatus.LA_SUSPENDED.rawValue, Int32(LA_SUSPENDED.rawValue))
        XCTAssertEqual(LicenseStatus.LA_GRACE_PERIOD_OVER.rawValue, Int32(LA_GRACE_PERIOD_OVER.rawValue))
    }

    /// TrialStatus has no raw values; the call sites map the two native codes,
    /// so those codes are pinned here instead.
    func testTrialStatusNativeCodes() {
        XCTAssertEqual(LA_TRIAL_EXPIRED.rawValue, 25)
        XCTAssertEqual(LA_LOCAL_TRIAL_EXPIRED.rawValue, 26)
    }

    func testPermissionFlagsMatchNativeConstants() {
        XCTAssertEqual(PermissionFlags.LA_USER.rawValue, LA_USER)
        XCTAssertEqual(PermissionFlags.LA_SYSTEM.rawValue, LA_SYSTEM)
        XCTAssertEqual(PermissionFlags.LA_ALL_USERS.rawValue, LA_ALL_USERS)
        XCTAssertEqual(PermissionFlags.LA_IN_MEMORY.rawValue, LA_IN_MEMORY)
    }

    func testCallbackResultMapsStatusesAndErrors() {
        XCTAssertEqual(LicenseCallbackResult(code: 0), .status(.LA_OK))
        XCTAssertEqual(LicenseCallbackResult(code: 20), .status(.LA_EXPIRED))
        XCTAssertEqual(LicenseCallbackResult(code: 21), .status(.LA_SUSPENDED))
        XCTAssertEqual(LicenseCallbackResult(code: 53), .failure(.LA_E_REVOKED))
        XCTAssertEqual(LicenseCallbackResult(code: 9_999), .failure(.unknown(code: 9_999)))
    }
}
