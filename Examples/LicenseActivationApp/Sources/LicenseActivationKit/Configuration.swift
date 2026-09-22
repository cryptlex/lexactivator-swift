import Foundation

/// Product credentials for the sample.
///
/// Replace the placeholders with the values from your Cryptlex dashboard.
public enum Configuration {
    public static let productData = "PASTE_CONTENT_OF_PRODUCT.DAT_FILE"
    public static let productId = "PASTE_PRODUCT_ID"
    public static let licenseKey = "PASTE_LICENSE_KEY"

    /// Releases the activation once the check finishes.
    ///
    /// Not a credential — a switch for unattended runs, where leaving an
    /// activation behind on every launch would eventually exhaust the license.
    public static let releasesActivationAfterwards =
        ProcessInfo.processInfo.environment["LEXACTIVATOR_RELEASE_AFTER_CHECK"] == "1"
}
