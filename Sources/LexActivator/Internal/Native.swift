import CLexActivator
import Foundation

/// Bridges the C API's conventions — `int` status codes, caller-allocated
/// `char*` buffers and integer sentinels — to Swift values and errors.
enum Native {
    static let ok: Int32 = 0
    static let bufferTooSmall: Int32 = 51 // LA_E_BUFFER_SIZE

    /// Throws a ``LexActivatorError`` unless the native call reported `LA_OK`.
    @inline(__always)
    static func check(_ status: Int32) throws {
        guard status != ok else { return }
        throw LexActivatorError(code: status)
    }

    /// Maps a native status onto a caller-supplied set of non-error outcomes.
    ///
    /// Anything outside `outcomes` is thrown as a ``LexActivatorError``, so a
    /// status the package does not expect can never be mistaken for success.
    @inline(__always)
    static func outcome<T>(_ status: Int32, _ outcomes: [Int32: T]) throws -> T {
        if let value = outcomes[status] { return value }
        throw LexActivatorError(code: status)
    }

    // MARK: - Strings

    /// Runs a native getter that fills a caller-allocated buffer.
    ///
    /// The buffer grows and the call is retried whenever the library reports
    /// `LA_E_BUFFER_SIZE`, so callers never have to guess a size. JSON-returning
    /// getters in particular can exceed any fixed guess once a license carries
    /// enough metadata or entitlements.
    static func string(
        initialCapacity: Int = 512,
        maximumCapacity: Int = 1 << 22,
        _ body: (UnsafeMutablePointer<CChar>, UInt32) -> Int32
    ) throws -> String {
        var capacity = initialCapacity
        while true {
            var buffer = [CChar](repeating: 0, count: capacity)
            let status = buffer.withUnsafeMutableBufferPointer { pointer in
                body(pointer.baseAddress!, UInt32(capacity))
            }
            if status == ok {
                return buffer.withUnsafeBufferPointer { String(cString: $0.baseAddress!) }
            }
            guard status == bufferTooSmall, capacity < maximumCapacity else {
                throw LexActivatorError(code: status)
            }
            capacity = min(capacity * 4, maximumCapacity)
        }
    }

    /// Passes a Swift string to the native API as a NUL-terminated C string.
    @inline(__always)
    static func withCString<Result>(_ value: String, _ body: (UnsafePointer<CChar>) -> Result) -> Result {
        value.withCString(body)
    }

    // MARK: - Scalars

    static func uint32Value(_ body: (UnsafeMutablePointer<UInt32>) -> Int32) throws -> UInt32 {
        var value: UInt32 = 0
        try check(body(&value))
        return value
    }

    static func int64Value(_ body: (UnsafeMutablePointer<Int64>) -> Int32) throws -> Int64 {
        var value: Int64 = 0
        try check(body(&value))
        return value
    }

    // MARK: - JSON

    static func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        guard let data = json.data(using: .utf8) else {
            throw LexActivatorError.LA_FAIL
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            // The native library returned something we cannot model. Surfacing
            // LA_FAIL keeps the public error surface closed over LexActivatorError.
            throw LexActivatorError.LA_FAIL
        }
    }
}
