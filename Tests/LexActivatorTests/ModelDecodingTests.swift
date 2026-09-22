import XCTest
@testable import LexActivator

/// The native library returns these payloads as JSON; the fixtures below match
/// the shapes the other Cryptlex bindings decode.
final class ModelDecodingTests: XCTestCase {
    func testDecodesFeatureEntitlements() throws {
        let json = """
        [
          {"featureName":"seats","featureDisplayName":"Seats","value":"10","baseValue":"5","expiresAt":1767225600},
          {"featureName":"export","featureDisplayName":"Export","value":"true","baseValue":"","expiresAt":0}
        ]
        """
        let entitlements = try Native.decode([FeatureEntitlement].self, from: json)

        XCTAssertEqual(entitlements.count, 2)
        XCTAssertEqual(entitlements[0].featureName, "seats")
        XCTAssertEqual(entitlements[0].value, "10")
        XCTAssertEqual(entitlements[0].baseValue, "5")
        XCTAssertEqual(entitlements[0].expiresAt, 1_767_225_600)
        // 0 is the native "does not expire" sentinel, passed through as-is.
        XCTAssertEqual(entitlements[1].expiresAt, 0)
    }

    func testDecodesEmptyEntitlementList() throws {
        XCTAssertEqual(try Native.decode([FeatureEntitlement].self, from: "[]"), [])
    }

    func testDecodesUserLicenses() throws {
        let json = """
        [
          {
            "key":"AAAA-BBBB","type":"node-locked",
            "allowedActivations":-1,"allowedDeactivations":5,
            "totalActivations":2,"totalDeactivations":1,
            "metadata":[{"key":"tier","value":"pro"}]
          }
        ]
        """
        let licenses = try Native.decode([UserLicense].self, from: json)

        XCTAssertEqual(licenses.count, 1)
        XCTAssertEqual(licenses[0].allowedActivations, -1, "-1 is the unlimited sentinel")
        XCTAssertEqual(licenses[0].allowedDeactivations, 5)
        XCTAssertEqual(licenses[0].totalActivations, 2)
        XCTAssertEqual(licenses[0].metadata, [Metadata(key: "tier", value: "pro")])
    }

    func testDecodesUserLicenseWithMissingFields() throws {
        // A license with no metadata omits the array entirely in some responses.
        let licenses = try Native.decode([UserLicense].self, from: #"[{"key":"AAAA"}]"#)
        XCTAssertEqual(licenses[0].key, "AAAA")
        XCTAssertEqual(licenses[0].metadata, [])
        XCTAssertEqual(licenses[0].totalActivations, 0)
    }

    func testDecodesDataStoreInfo() throws {
        let json = """
        {"storageKind":"file","permissionFlag":"la-user","isCustomDataDirectory":false,"path":"/tmp/store"}
        """
        let info = try Native.decode(DataStoreInfo.self, from: json)
        XCTAssertEqual(info.storageKind, "file")
        XCTAssertEqual(info.permissionFlag, "la-user")
        XCTAssertFalse(info.isCustomDataDirectory)
        XCTAssertEqual(info.path, "/tmp/store")
    }

    func testDecodesOrganizationAddress() throws {
        let json = """
        {"addressLine1":"1 Main St","addressLine2":"","city":"Pune","state":"MH","country":"IN","postalCode":"411001"}
        """
        let address = try Native.decode(OrganizationAddress.self, from: json)
        XCTAssertEqual(address.addressLine1, "1 Main St")
        XCTAssertEqual(address.country, "IN")
    }

    func testMalformedJSONSurfacesAsLexActivatorError() {
        XCTAssertThrowsError(try Native.decode(DataStoreInfo.self, from: "not json")) { error in
            // The public error surface stays closed over LexActivatorError.
            XCTAssertTrue(error is LexActivatorError)
        }
    }
}
