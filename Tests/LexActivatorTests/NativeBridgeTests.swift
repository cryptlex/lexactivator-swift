import XCTest
@testable import LexActivator

final class NativeBridgeTests: XCTestCase {
    func testCheckThrowsForNonZeroStatus() {
        XCTAssertNoThrow(try Native.check(0))
        XCTAssertThrowsError(try Native.check(40)) { error in
            XCTAssertEqual(error as? LexActivatorError, .LA_E_FILE_PATH)
        }
    }

    func testOutcomeMapsKnownStatusesAndThrowsTheRest() throws {
        let outcomes: [Int32: LicenseStatus] = [0: .LA_OK, 20: .LA_EXPIRED]
        XCTAssertEqual(try Native.outcome(0, outcomes), .LA_OK)
        XCTAssertEqual(try Native.outcome(20, outcomes), .LA_EXPIRED)
        // A status the call site does not expect must never read as success.
        XCTAssertThrowsError(try Native.outcome(58, outcomes)) { error in
            XCTAssertEqual(error as? LexActivatorError, .LA_E_ACTIVATION_LIMIT)
        }
    }

    /// The buffer grows and the call is retried when the library asks for more room.
    func testStringGrowsBufferUntilTheValueFits() throws {
        let value = String(repeating: "x", count: 5_000)
        var attempts = 0

        let result = try Native.string(initialCapacity: 16) { buffer, length in
            attempts += 1
            guard Int(length) > value.utf8.count else { return Native.bufferTooSmall }
            value.withCString { source in
                _ = strlcpy(buffer, source, Int(length))
            }
            return Native.ok
        }

        XCTAssertEqual(result, value)
        XCTAssertGreaterThan(attempts, 1, "the buffer should have been grown at least once")
    }

    func testStringGivesUpOnceTheMaximumCapacityIsReached() {
        XCTAssertThrowsError(
            try Native.string(initialCapacity: 16, maximumCapacity: 64) { _, _ in
                Native.bufferTooSmall
            }
        ) { error in
            XCTAssertEqual(error as? LexActivatorError, .LA_E_BUFFER_SIZE)
        }
    }

    func testStringPropagatesOtherErrors() {
        XCTAssertThrowsError(try Native.string { _, _ in 43 }) { error in
            XCTAssertEqual(error as? LexActivatorError, .LA_E_PRODUCT_ID)
        }
    }
}
