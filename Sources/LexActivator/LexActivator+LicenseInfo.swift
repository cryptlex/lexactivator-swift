import CLexActivator
import Foundation

// MARK: - Product information

extension LexActivator {
    /// Gets the product metadata as set in the dashboard.
    ///
    /// This is available for trial as well as license activations.
    ///
    /// - Parameter key: key to retrieve the value
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getProductMetadata(forKey key: String) throws -> String {
        try Native.string { buffer, length in
            key.withCString { CLexActivator.GetProductMetadata($0, buffer, length) }
        }
    }

    /// Reads the name of the product version linked to the license.
    @available(*, deprecated, message: "Use CLexActivator.GetLicenseEntitlementSetName() instead.")
    /// Gets the product version name.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: This function is deprecated. Use `getLicenseEntitlementSetName()` instead.
    ///
    /// - Note: PARAMETERS: * name - pointer to a buffer that receives the value of the string *
    ///   length - size of the buffer pointed to by the name parameter
    ///
    /// - Note: RETURN CODES: LA_OK, LA_FAIL, LA_E_PRODUCT_ID, LA_E_TIME, LA_E_TIME_MODIFIED,
    ///   LA_E_PRODUCT_VERSION_NOT_LINKED, LA_E_BUFFER_SIZE
    public static func getProductVersionName() throws -> String {
        try Native.string { buffer, length in CLexActivator.GetProductVersionName(buffer, length) }
    }

    /// Reads the display name of the product version linked to the license.
    @available(*, deprecated, message: "Use CLexActivator.GetLicenseEntitlementSetDisplayName() instead.")
    /// Gets the product version display name.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: This function is deprecated. Use `getLicenseEntitlementSetDisplayName()` instead.
    ///
    /// - Note: PARAMETERS: * displayName - pointer to a buffer that receives the value of the
    ///   string * length - size of the buffer pointed to by the displayName parameter
    ///
    /// - Note: RETURN CODES: LA_OK, LA_FAIL, LA_E_PRODUCT_ID, LA_E_TIME, LA_E_TIME_MODIFIED,
    ///   LA_E_PRODUCT_VERSION_NOT_LINKED, LA_E_BUFFER_SIZE
    public static func getProductVersionDisplayName() throws -> String {
        try Native.string { buffer, length in CLexActivator.GetProductVersionDisplayName(buffer, length) }
    }

    /// Reads a feature flag defined on the product version.
    @available(*, deprecated, message: "Use CLexActivator.GetFeatureEntitlement(name:) instead.")
    /// Gets the product version feature flag.
    ///
    /// - Parameter name: name of the feature flag
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: This function is deprecated. Use `getFeatureEntitlement()` instead.
    ///
    /// - Note: PARAMETERS: * name - name of the feature flag * enabled - pointer to the integer
    ///   that receives the value - 0 or 1 * data - pointer to a buffer that receives the
    ///   value of the string * length - size of the buffer pointed to by the data
    ///   parameter
    ///
    /// - Note: RETURN CODES: LA_OK, LA_FAIL, LA_E_PRODUCT_ID, LA_E_TIME, LA_E_TIME_MODIFIED,
    ///   LA_E_PRODUCT_VERSION_NOT_LINKED, LA_E_FEATURE_FLAG_NOT_FOUND, LA_E_BUFFER_SIZE
    public static func getProductVersionFeatureFlag(name: String) throws -> ProductVersionFeatureFlag {
        var enabled: UInt32 = 0
        let data = try Native.string { buffer, length in
            name.withCString { CLexActivator.GetProductVersionFeatureFlag($0, &enabled, buffer, length) }
        }
        return ProductVersionFeatureFlag(name: name, isEnabled: enabled != 0, data: data)
    }
}

// MARK: - Entitlements

extension LexActivator {
    /// Gets the license entitlement set name.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseEntitlementSetName() throws -> String {
        try Native.string { buffer, length in CLexActivator.GetLicenseEntitlementSetName(buffer, length) }
    }

    /// Gets the license entitlement set display name.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseEntitlementSetDisplayName() throws -> String {
        try Native.string { buffer, length in CLexActivator.GetLicenseEntitlementSetDisplayName(buffer, length) }
    }

    /// Gets the license entitlement set tier.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseEntitlementSetTier() throws -> Int64 {
        try Native.int64Value { CLexActivator.GetLicenseEntitlementSetTier($0) }
    }

    /// Gets the feature entitlements associated with the license.
    ///
    /// Feature entitlements can be linked directly to a license (license feature
    /// entitlements) or via entitlement sets. If a feature entitlement is defined in
    /// both, the value from the license feature entitlement takes precedence,
    /// overriding the entitlement set value.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getFeatureEntitlements() throws -> [FeatureEntitlement] {
        let json = try Native.string(initialCapacity: 4096) { buffer, length in
            CLexActivator.GetFeatureEntitlementsInternal(buffer, length)
        }
        return try Native.decode([FeatureEntitlement].self, from: json)
    }

    /// Gets the feature entitlement associated with the license.
    ///
    /// Feature entitlements can be linked directly to a license (license feature
    /// entitlements) or via entitlement sets. If a feature entitlement is defined in
    /// both, the value from the license feature entitlement takes precedence,
    /// overriding the entitlement set value.
    ///
    /// - Parameter featureName: name of the feature
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getFeatureEntitlement(featureName: String) throws -> FeatureEntitlement {
        let json = try Native.string(initialCapacity: 1024) { buffer, length in
            featureName.withCString { CLexActivator.GetFeatureEntitlementInternal($0, buffer, length) }
        }
        return try Native.decode(FeatureEntitlement.self, from: json)
    }
}

// MARK: - License information

extension LexActivator {
    /// Gets the license metadata as set in the dashboard.
    ///
    /// - Parameter key: key to retrieve the value
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseMetadata(forKey key: String) throws -> String {
        try Native.string { buffer, length in
            key.withCString { CLexActivator.GetLicenseMetadata($0, buffer, length) }
        }
    }

    /// Gets the license key used for activation.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseKey() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetLicenseKey(buffer, length)
        }
    }

    /// Gets the license type (node-locked or hosted-floating).
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseType() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetLicenseType(buffer, length)
        }
    }

    /// Gets the allowed activations of the license.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseAllowedActivations() throws -> Int64 {
        try Native.int64Value { CLexActivator.GetLicenseAllowedActivations($0) }
    }

    /// Gets the total activations of the license.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseTotalActivations() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetLicenseTotalActivations($0) }
    }

    /// Gets the allowed deactivations of the license.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseAllowedDeactivations() throws -> Int64 {
        try Native.int64Value { CLexActivator.GetLicenseAllowedDeactivations($0) }
    }

    /// Gets the total deactivations of the license.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseTotalDeactivations() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetLicenseTotalDeactivations($0) }
    }

    /// Gets the license creation date timestamp.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseCreationDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetLicenseCreationDate($0) }
    }

    /// Gets the activation creation date timestamp.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseActivationDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetLicenseActivationDate($0) }
    }

    /// Gets the license expiry date timestamp.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseExpiryDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetLicenseExpiryDate($0) }
    }

    /// Gets the license maintenance expiry date timestamp.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseMaintenanceExpiryDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetLicenseMaintenanceExpiryDate($0) }
    }

    /// Gets the maximum allowed release version of the license.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseMaxAllowedReleaseVersion() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetLicenseMaxAllowedReleaseVersion(buffer, length)
        }
    }

    /// Gets the email associated with license user.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseUserEmail() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetLicenseUserEmail(buffer, length)
        }
    }

    /// Gets the name associated with the license user.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseUserName() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetLicenseUserName(buffer, length)
        }
    }

    /// Gets the company associated with the license user.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseUserCompany() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetLicenseUserCompany(buffer, length)
        }
    }

    /// Gets the metadata associated with the license user.
    ///
    /// - Parameter key: key to retrieve the value
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseUserMetadata(forKey key: String) throws -> String {
        try Native.string { buffer, length in
            key.withCString { CLexActivator.GetLicenseUserMetadata($0, buffer, length) }
        }
    }

    /// Gets the name associated with the license organization.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseOrganizationName() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetLicenseOrganizationName(buffer, length)
        }
    }

    /// Gets the address associated with the license organization.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseOrganizationAddress() throws -> OrganizationAddress {
        let json = try Native.string(initialCapacity: 1024) { buffer, length in
            CLexActivator.GetLicenseOrganizationAddressInternal(buffer, length)
        }
        return try Native.decode(OrganizationAddress.self, from: json)
    }

    /// Gets the user licenses for the product.
    ///
    /// This function sends a network request to Cryptlex servers to get the licenses.
    ///
    /// Make sure `authenticateUser()` function is called before calling this function.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getUserLicenses() throws -> [UserLicense] {
        let json = try Native.string(initialCapacity: 4096) { buffer, length in
            CLexActivator.GetUserLicensesInternal(buffer, length)
        }
        return try Native.decode([UserLicense].self, from: json)
    }
}

// MARK: - Activation information

extension LexActivator {
    /// Gets the activation id.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getActivationId() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetActivationId(buffer, length)
        }
    }

    /// Gets the activation metadata.
    ///
    /// - Parameter key: key to retrieve the value
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getActivationMetadata(forKey key: String) throws -> String {
        try Native.string { buffer, length in
            key.withCString { CLexActivator.GetActivationMetadata($0, buffer, length) }
        }
    }

    /// Gets the mode of activation (online or offline).
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getActivationMode() throws -> ActivationMode {
        var initialBuffer = [CChar](repeating: 0, count: 256)
        var currentBuffer = [CChar](repeating: 0, count: 256)
        let status = initialBuffer.withUnsafeMutableBufferPointer { initial in
            currentBuffer.withUnsafeMutableBufferPointer { current in
                CLexActivator.GetActivationMode(initial.baseAddress!, 256, current.baseAddress!, 256)
            }
        }
        try Native.check(status)
        return ActivationMode(
            initialMode: initialBuffer.withUnsafeBufferPointer { String(cString: $0.baseAddress!) },
            currentMode: currentBuffer.withUnsafeBufferPointer { String(cString: $0.baseAddress!) }
        )
    }

    /// Gets the activation creation date timestamp for the current activation.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getActivationCreationDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetActivationCreationDate($0) }
    }

    /// Gets the activation last synced date timestamp.
    ///
    /// Initially, this timestamp matches the activation creation date, and then updates
    /// with each successful server sync.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getActivationLastSyncedDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetActivationLastSyncedDate($0) }
    }

    /// Gets the server sync grace period expiry date timestamp.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getServerSyncGracePeriodExpiryDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetServerSyncGracePeriodExpiryDate($0) }
    }

    /// Gets the error code that caused the activation data to be cleared.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLastActivationError() throws -> LexActivatorError? {
        let code = try Native.uint32Value { CLexActivator.GetLastActivationError($0) }
        guard code != 0 else { return nil }
        return LexActivatorError(code: Int32(bitPattern: code))
    }
}

// MARK: - Trial information

extension LexActivator {
    /// Gets the trial activation metadata.
    ///
    /// - Parameter key: key to retrieve the value
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getTrialActivationMetadata(forKey key: String) throws -> String {
        try Native.string { buffer, length in
            key.withCString { CLexActivator.GetTrialActivationMetadata($0, buffer, length) }
        }
    }

    /// Gets the trial expiry date timestamp.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getTrialExpiryDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetTrialExpiryDate($0) }
    }

    /// Gets the trial activation id. Used in case of trial extension.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getTrialId() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetTrialId(buffer, length)
        }
    }

    /// Gets the trial expiry date timestamp.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLocalTrialExpiryDate() throws -> UInt32 {
        try Native.uint32Value { CLexActivator.GetLocalTrialExpiryDate($0) }
    }
}
