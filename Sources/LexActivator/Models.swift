import Foundation

/// A key/value pair attached to a license, activation or user.
public struct Metadata: Sendable, Equatable, Codable {
    /// The metadata key.
    public let key: String

    /// The metadata value.
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// The postal address of the organization a license belongs to.
public struct OrganizationAddress: Sendable, Equatable, Codable {
    public let addressLine1: String
    public let addressLine2: String
    public let city: String
    public let state: String
    public let country: String
    public let postalCode: String

    public init(
        addressLine1: String,
        addressLine2: String,
        city: String,
        state: String,
        country: String,
        postalCode: String
    ) {
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.state = state
        self.country = country
        self.postalCode = postalCode
    }
}

/// A license belonging to the authenticated user.
///
/// Returned by ``LexActivator/getUserLicenses()``.
public struct UserLicense: Sendable, Equatable, Codable {
    /// The license key.
    public let key: String

    /// The license type, for example `node-locked` or `hosted-floating`.
    public let type: String

    /// Activations allowed by the license. A value of `-1` means unlimited.
    public let allowedActivations: Int64

    /// Deactivations allowed by the license. A value of `-1` means unlimited.
    public let allowedDeactivations: Int64

    /// Activations used so far.
    public let totalActivations: UInt32

    /// Deactivations used so far.
    public let totalDeactivations: UInt32

    /// Metadata attached to the license.
    public let metadata: [Metadata]

    private enum CodingKeys: String, CodingKey {
        case key, type, allowedActivations, allowedDeactivations
        case totalActivations, totalDeactivations, metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        allowedActivations = try container.decodeIfPresent(Int64.self, forKey: .allowedActivations) ?? 0
        allowedDeactivations = try container.decodeIfPresent(Int64.self, forKey: .allowedDeactivations) ?? 0
        totalActivations = try container.decodeIfPresent(UInt32.self, forKey: .totalActivations) ?? 0
        totalDeactivations = try container.decodeIfPresent(UInt32.self, forKey: .totalDeactivations) ?? 0
        metadata = try container.decodeIfPresent([Metadata].self, forKey: .metadata) ?? []
    }
}

/// Where the library keeps activation data on this device.
///
/// Returned by ``LexActivator/getDataStoreInfo()``.
public struct DataStoreInfo: Sendable, Equatable, Codable {
    /// The kind of storage in use: `file`, `registry` or `in-memory`.
    public let storageKind: String

    /// The permission flag in effect: `la-user`, `la-system`, `la-all-users`
    /// or `la-in-memory`.
    public let permissionFlag: String

    /// Whether a directory set with ``LexActivator/setDataDirectory(_:)`` is in effect.
    public let isCustomDataDirectory: Bool

    /// The location of the data store.
    public let path: String
}

/// A summary of a license, retrieved without activating it.
///
/// Returned by ``LexActivator/lookupLicense(licenseKey:)``.
public struct LicenseLookupInfo: Sendable, Equatable, Codable {
    /// The license key.
    public let key: String

    /// The license type, for example `node-locked` or `hosted-floating`.
    public let type: String
}

/// A feature entitlement attached to a license, directly or via an entitlement set.
public struct FeatureEntitlement: Sendable, Equatable, Codable {
    /// The internal name of the feature.
    public let featureName: String

    /// The human readable name of the feature.
    public let featureDisplayName: String

    /// The effective value of the feature.
    ///
    /// Holds the license-level override when one is set, otherwise the value
    /// inherited from the entitlement set.
    public let value: String

    /// The entitlement set's value for the feature.
    ///
    /// Empty for features that are not inherited from an entitlement set.
    public let baseValue: String

    /// The timestamp at which the entitlement expires. A value of `0` means
    /// it does not expire.
    public let expiresAt: Int64

    private enum CodingKeys: String, CodingKey {
        case featureName, featureDisplayName, value, baseValue, expiresAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        featureName = try container.decodeIfPresent(String.self, forKey: .featureName) ?? ""
        featureDisplayName = try container.decodeIfPresent(String.self, forKey: .featureDisplayName) ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
        baseValue = try container.decodeIfPresent(String.self, forKey: .baseValue) ?? ""
        expiresAt = try container.decodeIfPresent(Int64.self, forKey: .expiresAt) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(featureName, forKey: .featureName)
        try container.encode(featureDisplayName, forKey: .featureDisplayName)
        try container.encode(value, forKey: .value)
        try container.encode(baseValue, forKey: .baseValue)
        try container.encode(expiresAt, forKey: .expiresAt)
    }
}

/// A metered feature attached to a license.
///
/// Returned by ``LexActivator/getLicenseMeterAttribute(name:)``.
public struct LicenseMeterAttribute: Sendable, Equatable {
    /// The name of the meter attribute.
    public let name: String

    /// Uses allowed by the license. A value of `-1` means unlimited.
    public let allowedUses: Int64

    /// Uses recorded against the license across all activations.
    public let totalUses: UInt64

    /// Gross uses recorded against the license.
    public let grossUses: UInt64

    public init(name: String, allowedUses: Int64, totalUses: UInt64, grossUses: UInt64) {
        self.name = name
        self.allowedUses = allowedUses
        self.totalUses = totalUses
        self.grossUses = grossUses
    }
}

/// A feature flag defined on a product version.
public struct ProductVersionFeatureFlag: Sendable, Equatable {
    /// The name of the feature flag.
    public let name: String

    /// Whether the flag is enabled for this license.
    public let isEnabled: Bool

    /// Data associated with the flag.
    public let data: String

    public init(name: String, isEnabled: Bool, data: String) {
        self.name = name
        self.isEnabled = isEnabled
        self.data = data
    }
}

/// How the current activation was created and how it is running now.
///
/// Returned by ``LexActivator/getActivationMode()``.
public struct ActivationMode: Sendable, Equatable {
    /// The mode the activation was created in, for example `online` or `offline`.
    public let initialMode: String

    /// The mode the activation is currently in.
    public let currentMode: String

    public init(initialMode: String, currentMode: String) {
        self.initialMode = initialMode
        self.currentMode = currentMode
    }
}

