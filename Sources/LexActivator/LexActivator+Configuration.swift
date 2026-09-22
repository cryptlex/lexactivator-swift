import CLexActivator
import Foundation

// MARK: - Product and library configuration

extension LexActivator {
    /// Embeds the Product.dat file in the application.
    ///
    /// It can be used instead of `setProductFile()` in case you want to embed the
    /// Product.dat file in your application.
    ///
    /// This function must be called on every start of your program before any other
    /// functions are called.
    ///
    /// - Parameter productData: content of the Product.dat file
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: If this function fails to set the product data, none of the other functions will
    ///   work.
    public static func setProductData(_ productData: String) throws {
        try Native.check(Native.withCString(productData) { CLexActivator.SetProductData($0) })
    }

    /// Sets the absolute path of the Product.dat file.
    ///
    /// This function must be called on every start of your program before any other
    /// functions are called.
    ///
    /// - Parameter filePath: absolute path of the product file (Product.dat)
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: This function is deprecated. Use `setProductData()` instead.
    ///
    /// - Note: PARAMETERS: * filePath - absolute path of the product file (Product.dat)
    ///
    /// - Note: RETURN CODES: LA_OK, LA_E_FILE_PATH, LA_E_PRODUCT_FILE
    ///
    /// - Note: If this function fails to set the path of product file, none of the other
    ///   functions will work.
    public static func setProductFile(_ filePath: String) throws {
        try Native.check(Native.withCString(filePath) { CLexActivator.SetProductFile($0) })
    }

    /// Sets the product id of your application.
    ///
    /// This function must be called on every start of your program before any other
    /// functions are called, with the exception of `setProductFile()` or `setProductData()`
    /// function.
    ///
    /// - Parameters:
    ///   - productId: the unique product id of your application as mentioned on the product page in
    ///     the dashboard.
    ///   - flags: depending on your application's requirements, choose one of the following
    ///     values: LA_SYSTEM, LA_USER, LA_IN_MEMORY, LA_ALL_USERS.
    ///
    ///     - LA_USER: This flag indicates that the application does not require admin or
    ///     root permissions to run.
    ///
    ///     - LA_SYSTEM: This flag indicates that the application must be run with admin or
    ///     root permissions.
    ///
    ///     - LA_IN_MEMORY: This flag will store activation data in memory. Thus, requires
    ///     re-activation on every start of the application and should only be used in
    ///     floating licenses.
    ///
    ///     - LA_ALL_USERS: This flag is specifically designed for Windows and macOS and
    ///     should be used for system-wide activations.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: If this function fails to set the product id, none of the other functions will
    ///   work.
    public static func setProductId(_ productId: String, flags: PermissionFlags = .LA_USER) throws {
        try Native.check(Native.withCString(productId) { CLexActivator.SetProductId($0, flags.rawValue) })
    }

    /// In case you want to change the default directory used by LexActivator to store
    /// the activation data on Linux and macOS, this function can be used to set a
    /// different directory.
    ///
    /// If you decide to use this function, then it must be called on every start of
    /// your program before calling `setProductFile()` or `setProductData()` function.
    ///
    /// Please ensure that the directory exists and your app has read and write
    /// permissions in the directory.
    ///
    /// - Parameter directoryPath: absolute path of the directory.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setDataDirectory(_ directoryPath: String) throws {
        try Native.check(Native.withCString(directoryPath) { CLexActivator.SetDataDirectory($0) })
    }

    /// Enables network logs.
    ///
    /// This function should be used for network testing only in case of network errors.
    /// By default logging is disabled.
    ///
    /// This function generates the lexactivator-logs.log file in the same directory
    /// where the application is running.
    ///
    /// PARAMETERS : *enable - 0 or 1 to disable or enable logging.
    ///
    /// RETURN CODES : LA_OK
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setDebugMode(_ enable: Bool) throws {
        try Native.check(CLexActivator.SetDebugMode(enable ? 1 : 0))
    }

    /// Enables or disables in-memory caching for LexActivator. This function is
    /// designed to control caching behavior to suit specific application requirements.
    /// Caching is enabled by default to enhance performance.
    ///
    /// Disabling caching is recommended in environments where multiple processes access
    /// the same license on a single machine and require real-time updates to the
    /// license state.
    ///
    /// * enable - 0 or 1 to disable or enable in-memory caching.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setCacheMode(_ enable: Bool) throws {
        try Native.check(CLexActivator.SetCacheMode(enable ? 1 : 0))
    }

    /// In case you don't want to use the LexActivator's advanced device fingerprinting
    /// algorithm, this function can be used to set a custom device fingerprint.
    ///
    /// If you decide to use your own custom device fingerprint then this function must
    /// be called on every start of your program immediately after calling
    /// `setProductFile()` or `setProductData()` function.
    ///
    /// The license fingerprint matching strategy is ignored if this function is used.
    ///
    /// - Parameter fingerprint: string of minimum length 64 characters and maximum length 256 characters.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setCustomDeviceFingerprint(_ fingerprint: String) throws {
        try Native.check(Native.withCString(fingerprint) { CLexActivator.SetCustomDeviceFingerprint($0) })
    }

    /// Sets the license key required to activate the license.
    ///
    /// - Parameter licenseKey: a valid license key.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setLicenseKey(_ licenseKey: String) throws {
        try Native.check(Native.withCString(licenseKey) { CLexActivator.SetLicenseKey($0) })
    }

    /// Sets the license user email and password for authentication.
    ///
    /// This function must be called before `activateLicense()` or `isLicenseGenuine()`
    /// function if 'requireAuthentication' property of the license is set to true.
    ///
    /// - Parameters:
    ///   - email: user email address.
    ///   - password: user password.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: This function is deprecated. Use `authenticateUser()` instead.
    ///
    /// - Note: PARAMETERS: * email - user email address. * password - user password.
    ///
    /// - Note: RETURN CODES: LA_OK, LA_E_PRODUCT_ID, LA_E_LICENSE_KEY
    public static func setLicenseUserCredential(email: String, password: String) throws {
        let status = email.withCString { emailPointer in
            password.withCString { passwordPointer in
                CLexActivator.SetLicenseUserCredential(emailPointer, passwordPointer)
            }
        }
        try Native.check(status)
    }

    /// Sets the lease duration for the activation.
    ///
    /// The activation lease duration is honoured when the allow client lease duration
    /// property is enabled.
    ///
    /// - Parameter leaseDuration: value of the lease duration. A value of -1 indicates unlimited lease duration.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setActivationLeaseDuration(_ leaseDuration: Int64) throws {
        try Native.check(CLexActivator.SetActivationLeaseDuration(leaseDuration))
    }

    /// Sets the activation metadata.
    ///
    /// The  metadata appears along with the activation details of the license in
    /// dashboard.
    ///
    /// - Parameters:
    ///   - key: string of maximum length 256 characters.
    ///   - value: string of maximum length 4096 characters.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setActivationMetadata(key: String, value: String) throws {
        let status = key.withCString { keyPointer in
            value.withCString { valuePointer in
                CLexActivator.SetActivationMetadata(keyPointer, valuePointer)
            }
        }
        try Native.check(status)
    }

    /// Sets the trial activation metadata.
    ///
    /// The  metadata appears along with the trial activation details of the product in
    /// dashboard.
    ///
    /// - Parameters:
    ///   - key: string of maximum length 256 characters.
    ///   - value: string of maximum length 4096 characters.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setTrialActivationMetadata(key: String, value: String) throws {
        let status = key.withCString { keyPointer in
            value.withCString { valuePointer in
                CLexActivator.SetTrialActivationMetadata(keyPointer, valuePointer)
            }
        }
        try Native.check(status)
    }

    /// Sets the application version recorded against the activation.
    @available(*, deprecated, message: "Use CLexActivator.SetReleaseVersion(_:) instead.")
    /// Sets the current app version of your application.
    ///
    /// The app version appears along with the activation details in dashboard. It is
    /// also used to generate app analytics.
    ///
    /// - Parameter appVersion: string of maximum length 256 characters.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: This function is deprecated. Use `setReleaseVersion()` instead.
    ///
    /// - Note: PARAMETERS: * appVersion - string of maximum length 256 characters.
    ///
    /// - Note: RETURN CODES: LA_OK, LA_E_PRODUCT_ID, LA_E_APP_VERSION_LENGTH
    public static func setAppVersion(_ appVersion: String) throws {
        try Native.check(Native.withCString(appVersion) { CLexActivator.SetAppVersion($0) })
    }

    /// Sets the current release version of your application.
    ///
    /// The release version appears along with the activation details in dashboard.
    ///
    /// - Parameter releaseVersion: string in following allowed formats: x.x, x.x.x, x.x.x.x
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setReleaseVersion(_ releaseVersion: String) throws {
        try Native.check(Native.withCString(releaseVersion) { CLexActivator.SetReleaseVersion($0) })
    }

    /// Sets the release published date of your application.
    ///
    /// - Parameter releasePublishedDate: unix timestamp of release published date.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setReleasePublishedDate(_ releasePublishedDate: Date) throws {
        try Native.check(CLexActivator.SetReleasePublishedDate(UInt32(releasePublishedDate.timeIntervalSince1970)))
    }

    /// Sets the release platform e.g. windows, macos, linux
    ///
    /// The release platform appears along with the activation details in dashboard.
    ///
    /// - Parameter releasePlatform: release platform e.g. windows, macos, linux
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setReleasePlatform(_ releasePlatform: String) throws {
        try Native.check(Native.withCString(releasePlatform) { CLexActivator.SetReleasePlatform($0) })
    }

    /// Sets the release channel e.g. stable, beta
    ///
    /// The release channel appears along with the activation details in dashboard.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setReleaseChannel(_ releaseChannel: String) throws {
        try Native.check(Native.withCString(releaseChannel) { CLexActivator.SetReleaseChannel($0) })
    }

    /// Records meter attribute uses in the next offline activation request.
    public static func setOfflineActivationRequestMeterAttributeUses(
        name: String,
        uses: UInt32
    ) throws {
        try Native.check(
            Native.withCString(name) { CLexActivator.SetOfflineActivationRequestMeterAttributeUses($0, uses) }
        )
    }

    /// Sets the network proxy to be used when contacting Cryptlex servers.
    ///
    /// The proxy format should be: [protocol://][username:password@]machine[:port]
    ///
    /// Following are some examples of the valid proxy strings: - http://127.0.0.1:8000/
    /// - http://user:pass@127.0.0.1:8000/ - socks5://127.0.0.1:8000/
    ///
    /// - Parameter proxy: proxy string having correct proxy format
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: Proxy settings of the computer are automatically detected. So, in most of the
    ///   cases you don't need to care whether your user is behind a proxy server or not.
    public static func setNetworkProxy(_ proxy: String) throws {
        try Native.check(Native.withCString(proxy) { CLexActivator.SetNetworkProxy($0) })
    }

    /// In case you are running Cryptlex on-premise, you can set the host for your on-
    /// premise server.
    ///
    /// - Parameter host: the address of the Cryptlex on-premise server
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setCryptlexHost(_ host: String) throws {
        try Native.check(Native.withCString(host) { CLexActivator.SetCryptlexHost($0) })
    }

    /// Sets the two-factor authentication code for the user authentication.
    ///
    /// - Parameter twoFactorAuthenticationCode: the 2FA code
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func setTwoFactorAuthenticationCode(_ twoFactorAuthenticationCode: String) throws {
        try Native.check(Native.withCString(twoFactorAuthenticationCode) { CLexActivator.SetTwoFactorAuthenticationCode($0) })
    }
}
