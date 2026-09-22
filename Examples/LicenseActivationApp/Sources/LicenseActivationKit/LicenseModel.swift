import Foundation
import LexActivator

/// Checks the license at launch and activates the device if it is not
/// activated yet — the flow most applications need.
///
/// The network-backed calls block, so they run off the main thread and publish
/// results back onto it.
public final class LicenseModel: ObservableObject, @unchecked Sendable {
    /// A headline for the current state.
    @Published public private(set) var summary = "Checking license…"

    /// When the license expires, ready to display.
    @Published public private(set) var expiry = ""

    /// What happened, in order, the way the command line samples print it.
    @Published public private(set) var log: [String] = []

    @Published public private(set) var isBusy = false
    @Published public private(set) var isActivated = false

    private let queue = DispatchQueue(label: "com.cryptlex.sample.license")

    public init() {}

    /// Runs the check once. Safe to call from `onAppear`.
    public func checkLicense() {
        guard !isBusy, log.isEmpty else { return }
        isBusy = true

        queue.async { [weak self] in
            self?.performCheck()
        }
    }

    /// Releases this device's activation, freeing it for another device.
    public func deactivate() {
        guard !isBusy else { return }
        isBusy = true

        queue.async { [weak self] in
            guard let self else { return }
            do {
                try LexActivator.deactivateLicense()
                self.finish(summary: "Not activated", activated: false, message: "Activation released.")
            } catch let error as LexActivatorError {
                self.finish(summary: "Not activated", activated: false, message: "Error code: \(error.code) \(error.message)")
            } catch {
                self.finish(summary: "Not activated", activated: false, message: "\(error)")
            }
        }
    }

    // MARK: - The flow

    private func performCheck() {
        do {
            try LexActivator.setProductData(Configuration.productData)
            try LexActivator.setProductId(Configuration.productId, flags: .LA_USER)
            try LexActivator.setReleaseVersion("1.0.0") // Set this to the release version of your app

            append("LexActivator \(try LexActivator.getLibraryVersion())")

            // Setting the license callback is recommended for floating
            // licenses. The library calls it when isLicenseGenuine() completes
            // a server sync, on a thread of its own.
            try LexActivator.setLicenseCallback { [weak self] result in
                switch result {
                case .status(let status): self?.append("License status: \(status)")
                case .failure(let error): self?.append("License status: \(error.message)")
                }
            }

            switch try licenseStatus() {
            case .LA_OK:
                showDetails()
                finish(summary: "Activated", activated: true, message: "License is genuinely activated!")
            case .LA_EXPIRED:
                finish(summary: "Expired", activated: true, message: "License is genuinely activated but has expired!")
            case .LA_SUSPENDED:
                finish(summary: "Suspended", activated: true, message: "License is genuinely activated but has been suspended!")
            case .LA_GRACE_PERIOD_OVER:
                finish(summary: "Grace period over", activated: true, message: "License is genuinely activated but grace period is over!")
            case nil:
                try activate()
            }
        } catch let error as LexActivatorError {
            finish(summary: "Error", activated: false, message: "Error code: \(error.code) \(error.message)")
        } catch {
            finish(summary: "Error", activated: false, message: "\(error)")
        }
    }

    /// Returns `nil` when this device has no activation yet, which the native
    /// library reports as a plain failure rather than a distinct status.
    private func licenseStatus() throws -> LicenseStatus? {
        do {
            return try LexActivator.isLicenseGenuine()
        } catch LexActivatorError.LA_FAIL {
            return nil
        }
    }

    private func activate() throws {
        append("Not activated on this device, activating…")
        try LexActivator.setLicenseKey(Configuration.licenseKey)

        switch try LexActivator.activateLicense() {
        case .LA_OK:
            append("License activated successfully.")
            showDetails()
            finish(summary: "Activated", activated: true, message: "License is genuinely activated!")
        case .LA_EXPIRED:
            finish(summary: "Expired", activated: true, message: "License activated but has expired!")
        case .LA_SUSPENDED:
            finish(summary: "Suspended", activated: true, message: "License activated but has been suspended!")
        case .LA_GRACE_PERIOD_OVER:
            finish(summary: "Grace period over", activated: true, message: "License activated but grace period is over!")
        }
    }

    private func showDetails() {
        do {
            // The expiry date is a Unix timestamp; 0 means the license never expires.
            let expiryDate = try LexActivator.getLicenseExpiryDate()
            if expiryDate == 0 {
                setExpiry("Never (lifetime license)")
                append("Days left: never expires (lifetime license)")
            } else {
                let date = Date(timeIntervalSince1970: TimeInterval(expiryDate))
                setExpiry(Self.format(date))
                append("Days left: \(Int(date.timeIntervalSinceNow / 86_400))")
            }
        } catch {
            setExpiry("Unknown")
        }

        if let user = try? LexActivator.getLicenseUserName(), !user.isEmpty {
            append("License user: \(user)")
        }
    }

    // MARK: - Publishing

    private func append(_ message: String) {
        // Mirrored to the device log so automated runs can read it.
        NSLog("LexActivator sample: %@", message)
        DispatchQueue.main.async { self.log.append(message) }
    }

    private func setExpiry(_ value: String) {
        DispatchQueue.main.async { self.expiry = value }
    }

    private func finish(summary: String, activated: Bool, message: String) {
        append(message)
        DispatchQueue.main.async {
            self.summary = summary
            self.isActivated = activated
            self.isBusy = false
        }

        if activated && Configuration.releasesActivationAfterwards {
            try? LexActivator.deactivateLicense()
            append("Activation released.")
        }
    }

    private static func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
