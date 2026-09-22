import CLexActivator
import Foundation

/// Holds the Swift closure behind the C callback.
///
/// The native library invokes the callback from one of its own threads, so the
/// handler is read under a lock and called outside it.
///
/// Internal rather than private so tests can drive it the way the native
/// library does. When the callback fires is decided by the native library —
/// only on a background server sync — so this side of the boundary is the part
/// that can be tested deterministically.
final class LicenseCallbackBox: @unchecked Sendable {
    static let shared = LicenseCallbackBox()

    private let lock = NSLock()
    private var handler: (@Sendable (LicenseCallbackResult) -> Void)?

    func setHandler(_ handler: (@Sendable (LicenseCallbackResult) -> Void)?) {
        lock.lock()
        defer { lock.unlock() }
        self.handler = handler
    }

    func invoke(code: Int32) {
        lock.lock()
        let handler = self.handler
        lock.unlock()
        handler?(LicenseCallbackResult(code: code))
    }
}

/// The C entry point handed to `SetLicenseCallback`.
func licenseCallbackTrampoline(code: UInt32) {
    LicenseCallbackBox.shared.invoke(code: Int32(bitPattern: code))
}

extension LexActivator {
    /// Sets server sync callback function.
    ///
    /// Whenever the server sync occurs in a separate thread, and server returns the
    /// response, license callback function gets invoked with the following status codes:
    /// ``LicenseStatus/LA_OK``, ``LicenseStatus/LA_EXPIRED``,
    /// ``LicenseStatus/LA_SUSPENDED``, ``LexActivatorError/LA_E_REVOKED``,
    /// ``LexActivatorError/LA_E_ACTIVATION_NOT_FOUND``,
    /// ``LexActivatorError/LA_E_MACHINE_FINGERPRINT``,
    /// ``LexActivatorError/LA_E_AUTHENTICATION_FAILED``, ``LexActivatorError/LA_E_COUNTRY``,
    /// ``LexActivatorError/LA_E_INET``, ``LexActivatorError/LA_E_SERVER``,
    /// ``LexActivatorError/LA_E_RATE_LIMIT``, ``LexActivatorError/LA_E_IP``,
    /// ``LexActivatorError/LA_E_RELEASE_VERSION_NOT_ALLOWED``,
    /// ``LexActivatorError/LA_E_RELEASE_VERSION_FORMAT``.
    ///
    /// - Register the callback **before** the first ``isLicenseGenuine()``, or the
    ///   first sync result is lost.
    /// - Calling ``activateLicense()`` first suppresses it, because activation has
    ///   itself just synced and leaves nothing for the sync to do. At launch, check
    ///   ``isLicenseGenuine()`` first and only activate when the device has no
    ///   activation yet.
    ///
    /// ```swift
    /// try LexActivator.setLicenseCallback { result in
    ///     DispatchQueue.main.async {
    ///         switch result {
    ///         case .status(.LA_OK): break
    ///         case .status(let status): presentLicenseProblem(status)
    ///         case .failure(let error): log(error)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Important: The closure is invoked on a library-owned background thread. Hop to
    ///   the main queue before touching UI.
    ///
    /// - Parameter callback: name of the callback function
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setLicenseCallback(
        _ callback: @escaping @Sendable (LicenseCallbackResult) -> Void
    ) throws {
        LicenseCallbackBox.shared.setHandler(callback)
        try Native.check(CLexActivator.SetLicenseCallback(licenseCallbackTrampoline))
    }

    /// Stops delivering server sync results to a previously registered closure.
    ///
    /// The native callback stays registered; it simply becomes a no-op, which
    /// avoids any window where the library could call into a released closure.
    public static func removeLicenseCallback() {
        LicenseCallbackBox.shared.setHandler(nil)
    }
}
