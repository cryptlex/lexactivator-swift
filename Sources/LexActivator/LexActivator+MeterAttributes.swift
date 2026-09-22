import CLexActivator
import Foundation

// MARK: - Meter attributes

extension LexActivator {
    /// Gets the license meter attribute allowed, total and gross uses.
    ///
    /// - Parameter name: name of the meter attribute
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLicenseMeterAttribute(name: String) throws -> LicenseMeterAttribute {
        var allowedUses: Int64 = 0
        var totalUses: UInt64 = 0
        var grossUses: UInt64 = 0
        let status = name.withCString { namePointer in
            CLexActivator.GetLicenseMeterAttribute(namePointer, &allowedUses, &totalUses, &grossUses)
        }
        try Native.check(status)
        return LicenseMeterAttribute(
            name: name,
            allowedUses: allowedUses,
            totalUses: totalUses,
            grossUses: grossUses
        )
    }

    /// Gets the meter attribute uses consumed by the activation.
    ///
    /// - Parameter name: name of the meter attribute
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getActivationMeterAttributeUses(name: String) throws -> UInt32 {
        try Native.uint32Value { uses in
            name.withCString { CLexActivator.GetActivationMeterAttributeUses($0, uses) }
        }
    }

    /// Increments this activation's use count for a meter attribute.
    ///
    /// - Important: Performs a network request and blocks.
    /// - Throws: ``LexActivatorError/LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED`` when the
    ///   increment would exceed the allowed uses.
    public static func incrementActivationMeterAttributeUses(
        name: String,
        by increment: UInt32
    ) throws {
        try Native.check(
            name.withCString { CLexActivator.IncrementActivationMeterAttributeUses($0, increment) }
        )
    }

    /// Decrements this activation's use count for a meter attribute.
    ///
    /// - Important: Performs a network request and blocks.
    public static func decrementActivationMeterAttributeUses(
        name: String,
        by decrement: UInt32
    ) throws {
        try Native.check(
            name.withCString { CLexActivator.DecrementActivationMeterAttributeUses($0, decrement) }
        )
    }

    /// Resets the meter attribute uses consumed by the activation.
    ///
    /// - Important: Performs a network request and blocks.
    ///
    /// - Parameter name: name of the meter attribute
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func resetActivationMeterAttributeUses(name: String) throws {
        try Native.check(name.withCString { CLexActivator.ResetActivationMeterAttributeUses($0) })
    }
}
