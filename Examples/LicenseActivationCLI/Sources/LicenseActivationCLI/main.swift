import Foundation
import LexActivator

// Checks the license and activates it if this device is not activated yet.
//
//     swift run LicenseActivationCLI
//     swift run LicenseActivationCLI deactivate

do {
    if CommandLine.arguments.dropFirst().first == "deactivate" {
        try initialize()
        try LexActivator.deactivateLicense()
        print("Activation released.")
        exit(EXIT_SUCCESS)
    }

    try initialize()

    // Setting the license callback is recommended for floating licenses. The
    // library calls it when isLicenseGenuine() completes a server sync, which
    // is how a running application hears that its license changed.
    try LexActivator.setLicenseCallback { result in
        switch result {
        case .status(let status): print("License status:", status)
        case .failure(let error): print("License status:", error.message)
        }
    }

    switch try isLicenseGenuine() {
    case .LA_OK:
        printLicenseDetails()
        print("License is genuinely activated!")
    case .LA_EXPIRED:
        print("License is genuinely activated but has expired!")
    case .LA_SUSPENDED:
        print("License is genuinely activated but has been suspended!")
    case .LA_GRACE_PERIOD_OVER:
        print("License is genuinely activated but grace period is over!")
    case nil:
        // No activation on this device yet.
        try activate()
    }

    // Staying alive lets the server sync finish: isLicenseGenuine() starts it
    // on a background thread, and the license callback above reports the
    // result a few seconds later.
    print("Press Enter to exit...")
    _ = readLine()
} catch let error as LexActivatorError {
    print("Error code:", error.code, error.message)
    exit(EXIT_FAILURE)
}

func initialize() throws {
    try LexActivator.setProductData(Configuration.productData)
    try LexActivator.setProductId(Configuration.productId, flags: .LA_USER)
    try LexActivator.setReleaseVersion("1.0.0") // Set this to the release version of your app
}

/// Returns `nil` when this device has no activation yet, which the native
/// library reports as a plain failure rather than a distinct status.
func isLicenseGenuine() throws -> LicenseStatus? {
    do {
        return try LexActivator.isLicenseGenuine()
    } catch LexActivatorError.LA_FAIL {
        return nil
    }
}

func activate() throws {
    try LexActivator.setLicenseKey(Configuration.licenseKey)
    try LexActivator.setActivationMetadata(key: "key1", value: "value1")

    switch try LexActivator.activateLicense() {
    case .LA_OK:
        print("License activated successfully.")
        printLicenseDetails()
    case .LA_EXPIRED:
        print("License activated but has expired!")
    case .LA_SUSPENDED:
        print("License activated but has been suspended!")
    case .LA_GRACE_PERIOD_OVER:
        print("License activated but grace period is over!")
    }
}

func printLicenseDetails() {
    do {
        // The expiry date is a Unix timestamp; 0 means the license never expires.
        let expiryDate = try LexActivator.getLicenseExpiryDate()
        if expiryDate == 0 {
            print("Days left: never expires (lifetime license)")
        } else {
            let daysLeft = (Double(expiryDate) - Date().timeIntervalSince1970) / 86_400
            print("Days left:", Int(daysLeft))
        }
    } catch {
        print("Could not read the expiry date.")
    }

    if let user = try? LexActivator.getLicenseUserName(), !user.isEmpty {
        print("License user:", user)
    }
}
