import CLexActivator
import Foundation

/// A Swift interface to the Cryptlex LexActivator licensing library.
///
/// `LexActivator` is a namespace over a native library that keeps global state,
/// so every method is `static`. A typical launch sequence is:
///
/// ```swift
/// try LexActivator.setProductData(productData)
/// try LexActivator.setProductId(productId, flags: .LA_USER)
/// try LexActivator.setLicenseKey(licenseKey)
///
/// switch try LexActivator.activateLicense() {
/// case .LA_OK:
///     // Run the application.
/// case .LA_EXPIRED, .LA_SUSPENDED, .LA_GRACE_PERIOD_OVER:
///     // Send the user to your renewal flow.
/// }
/// ```
///
/// ## Threading
///
/// The native library is not documented as thread-safe for concurrent
/// configuration, and the network-backed calls — activation, deactivation and
/// sync — block for as long as the request takes. Configure the library once
/// during launch, and move the blocking calls off the main thread so the UI
/// stays responsive:
///
/// ```swift
/// DispatchQueue.global().async {
///     let status = try? LexActivator.activateLicense()
///     DispatchQueue.main.async { /* update the UI */ }
/// }
/// ```
public enum LexActivator {
    /// Gets the version of this library.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func getLibraryVersion() throws -> String {
        try Native.string(initialCapacity: 256) { buffer, length in
            CLexActivator.GetLibraryVersion(buffer, length)
        }
    }

    /// Gets information about the data store used by LexActivator on the current
    /// platform, including the location where the data is stored.
    ///
    /// The path member is the fully resolved location of the data and does not include
    /// the name of the data file. If a custom directory has been set using the
    /// `setDataDirectory()` function, that directory is returned.
    ///
    /// On Windows, when the LA_USER or LA_SYSTEM flag is used, the data is stored in
    /// the registry. In that case the path member is the registry key path and not a
    /// filesystem directory.
    ///
    /// When the LA_IN_MEMORY flag is used, nothing is persisted, storageKind is "in-
    /// memory" and path is empty.
    ///
    /// This function must be called after calling the `setProductId()` function.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: The path is intended for inspection only. Do not delete, move or modify its
    ///   contents. To release the activation and clear the activation data of your
    ///   product, use the `deactivateLicense()` function.
    public static func getDataStoreInfo() throws -> DataStoreInfo {
        let json = try Native.string { buffer, length in
            CLexActivator.GetDataStoreInfoInternal(buffer, length)
        }
        return try Native.decode(DataStoreInfo.self, from: json)
    }

    /// Resets the activation and trial data stored in the machine.
    ///
    /// It clears the data locally without contacting the Cryptlex servers, so the
    /// activation is not released and continues to occupy an activation slot of the
    /// license.
    ///
    /// To deactivate the license and free up the activation slot, use the
    /// `deactivateLicense()` function instead.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: The function does not reset local(unverified) trial data.
    public static func reset() throws {
        try Native.check(CLexActivator.Reset())
    }
}
