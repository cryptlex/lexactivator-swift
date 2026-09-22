import CLexActivator
import Foundation

// MARK: - Activation and validation

extension LexActivator {
    /// Activates the license by contacting the Cryptlex servers. It validates the key
    /// and returns with encrypted and digitally signed token which it stores and uses
    /// to activate your application.
    ///
    /// This function should be executed at the time of registration, ideally on a
    /// button click.
    ///
    /// - Important: This performs a network request and blocks until it completes. Call it off the
    ///   main thread.
    ///
    /// - Returns: The outcome as a ``LicenseStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    @discardableResult
    public static func activateLicense() throws -> LicenseStatus {
        try Native.outcome(CLexActivator.ActivateLicense(), [
            0: .LA_OK,
            20: .LA_EXPIRED,
            21: .LA_SUSPENDED,
        ])
    }

    /// Activates your licenses using the offline activation response file.
    ///
    /// - Parameter filePath: path of the offline activation response file.
    ///
    /// - Returns: The outcome as a ``LicenseStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    @discardableResult
    public static func activateLicenseOffline(filePath: String) throws -> LicenseStatus {
        let status = Native.withCString(filePath) { CLexActivator.ActivateLicenseOffline($0) }
        return try Native.outcome(status, [0: .LA_OK, 20: .LA_EXPIRED])
    }

    /// Generates the offline activation request needed for generating offline
    /// activation response in the dashboard.
    ///
    /// - Parameter filePath: path of the file for the offline request.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func generateOfflineActivationRequest(filePath: String) throws {
        try Native.check(Native.withCString(filePath) { CLexActivator.GenerateOfflineActivationRequest($0) })
    }

    /// Deactivates the license activation and frees up the corresponding activation
    /// slot by contacting the Cryptlex servers.
    ///
    /// This function should be executed at the time of de-registration, ideally on a
    /// button click.
    ///
    /// - Important: Performs a network request and blocks. Call it off the main thread.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func deactivateLicense() throws {
        try Native.check(CLexActivator.DeactivateLicense())
    }

    /// Generates the offline deactivation request needed for deactivation of the
    /// license in the dashboard and deactivates the license locally.
    ///
    /// A valid offline deactivation file confirms that the license has been
    /// successfully deactivated on the user's machine.
    ///
    /// - Parameter filePath: path of the file for the offline request.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func generateOfflineDeactivationRequest(filePath: String) throws {
        try Native.check(Native.withCString(filePath) { CLexActivator.GenerateOfflineDeactivationRequest($0) })
    }

    /// It verifies whether your app is genuinely activated or not. The verification is
    /// done locally by verifying the cryptographic digital signature fetched at the
    /// time of activation.
    ///
    /// After verifying locally, it schedules a server check in a separate thread. After
    /// the first server sync it periodically does further syncs at a frequency set for
    /// the license.
    ///
    /// In case server sync fails due to network error, and it continues to fail for
    /// fixed number of days (grace period), the function returns LA_GRACE_PERIOD_OVER
    /// instead of LA_OK.
    ///
    /// This function must be called on every start of your program to verify the
    /// activation of your app.
    ///
    /// - Returns: The outcome as a ``LicenseStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: If application was activated offline using `activateLicenseOffline()` function,
    ///   you may want to set grace period to 0 to ignore grace period.
    public static func isLicenseGenuine() throws -> LicenseStatus {
        try Native.outcome(CLexActivator.IsLicenseGenuine(), [
            0: .LA_OK,
            20: .LA_EXPIRED,
            21: .LA_SUSPENDED,
            22: .LA_GRACE_PERIOD_OVER,
        ])
    }

    /// It verifies whether your app is genuinely activated or not. The verification is
    /// done locally by verifying the cryptographic digital signature fetched at the
    /// time of activation.
    ///
    /// This is just an auxiliary function which you may use in some specific cases,
    /// when you want to skip the server sync.
    ///
    /// - Returns: The outcome as a ``LicenseStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: You may want to set grace period to 0 to ignore grace period.
    public static func isLicenseValid() throws -> LicenseStatus {
        try Native.outcome(CLexActivator.IsLicenseValid(), [
            0: .LA_OK,
            20: .LA_EXPIRED,
            21: .LA_SUSPENDED,
            22: .LA_GRACE_PERIOD_OVER,
        ])
    }

    /// Synchronizes the activation data with the Cryptlex servers.
    ///
    /// The license must already be activated when this function is called.
    ///
    /// This is a blocking call that performs a one-time synchronization to refresh the
    /// local license data.
    ///
    /// In most cases, rely on `isLicenseGenuine()`, which automatically handles periodic
    /// background synchronization based on the configured interval.
    ///
    /// - Important: Performs a network request and blocks. Call it off the main thread.
    ///
    /// - Returns: The outcome as a ``LicenseStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: Do not use this function in regular application flow. Use it only when an
    ///   immediate synchronization is required.
    ///
    /// - Note: RETURN CODES: LA_OK, LA_EXPIRED, LA_SUSPENDED, LA_E_REVOKED, LA_FAIL,
    ///   LA_E_PRODUCT_ID, LA_E_INET, LA_E_VM, LA_E_TIME, LA_E_ACTIVATION_LIMIT,
    ///   LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED, LA_E_SERVER, LA_E_CLIENT,
    ///   LA_E_TIME_MODIFIED, LA_E_AUTHENTICATION_FAILED, LA_E_LICENSE_TYPE, LA_E_COUNTRY,
    ///   LA_E_IP, LA_E_RATE_LIMIT, LA_E_LICENSE_KEY, LA_E_RELEASE_VERSION_NOT_ALLOWED,
    ///   LA_E_RELEASE_VERSION_FORMAT, LA_E_LICENSE_NOT_EFFECTIVE
    @discardableResult
    public static func syncLicenseActivation() throws -> LicenseStatus {
        try Native.outcome(CLexActivator.SyncLicenseActivation(), [
            0: .LA_OK,
            20: .LA_EXPIRED,
            21: .LA_SUSPENDED,
        ])
    }

    /// It sends the request to the Cryptlex servers to authenticate the user.
    ///
    /// - Important: Performs a network request and blocks.
    ///
    /// - Parameters:
    ///   - email: user email address.
    ///   - password: user password.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func authenticateUser(email: String, password: String) throws {
        let status = email.withCString { emailPointer in
            password.withCString { passwordPointer in
                CLexActivator.AuthenticateUser(emailPointer, passwordPointer)
            }
        }
        try Native.check(status)
    }

    /// Authenticates the user via OIDC Id token.
    ///
    /// PARAMETER: * idToken - The id token obtained from the OIDC provider.
    ///
    /// - Important: Performs a network request and blocks.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func authenticateUserWithIdToken(idToken: String) throws {
        try Native.check(Native.withCString(idToken) { CLexActivator.AuthenticateUserWithIdToken($0) })
    }

    /// Retrieves the license information from the Cryptlex servers without activating
    /// the license.
    ///
    /// This function sends a network request to the Cryptlex servers. It is optional
    /// and is not required by the standard activation flow. It is intended for
    /// applications that need license information before activation, e.g. the license
    /// type.
    ///
    /// This function must be called after `setProductData()`. It does not require
    /// `setProductId()` to be called first.
    ///
    /// - Important: Performs a network request and blocks.
    ///
    /// - Parameter licenseKey: the license key to look up.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: This function neither validates the license nor stores anything on the device,
    ///   and it has no effect on the activation state of the application. Use
    ///   `activateLicense()` to activate the license.
    public static func lookupLicense(licenseKey: String) throws -> LicenseLookupInfo {
        let json = try Native.string { buffer, length in
            licenseKey.withCString { CLexActivator.LookupLicenseInternal($0, buffer, length) }
        }
        return try Native.decode(LicenseLookupInfo.self, from: json)
    }
}
