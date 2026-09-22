import Foundation

// Case names are the C constants from LexStatusCodes.h and LexActivator.h,
// verbatim. Swift convention would drop the prefix and lowerCamelCase the rest
// (`ok`, `gracePeriodOver`), but the bindings deliberately keep one vocabulary
// across languages: a constant named in the Cryptlex documentation is the same
// string here, in the Rust binding's enum, and in the C header.

/// The outcome of a license activation or validation call.
///
/// Only ``LA_OK`` means the application should run unrestricted; the remaining
/// cases are reported by the server or the local cache and are not errors in
/// the "the call failed" sense, which is why they are returned rather than
/// thrown.
public enum LicenseStatus: Int32, Sendable, Equatable, CaseIterable {
    /// The license is active and valid.
    case LA_OK = 0

    /// The license has expired, or the system clock has been tampered with.
    case LA_EXPIRED = 20

    /// The license has been suspended.
    case LA_SUSPENDED = 21

    /// The server sync grace period is over.
    ///
    /// Only reported by ``LexActivator/isLicenseGenuine()`` and
    /// ``LexActivator/isLicenseValid()``.
    case LA_GRACE_PERIOD_OVER = 22
}

/// The outcome of a trial activation or validation call.
///
/// The same type covers verified (server-backed) and local trials; the native
/// library reports them with distinct codes (`LA_TRIAL_EXPIRED` and
/// `LA_LOCAL_TRIAL_EXPIRED`) but the decision the caller has to make is the same.
public enum TrialStatus: Sendable, Equatable, CaseIterable {
    /// The trial is active.
    case LA_OK

    /// The trial has expired, or the system clock has been tampered with.
    ///
    /// Reported by the native library as `LA_TRIAL_EXPIRED` for a verified
    /// trial and `LA_LOCAL_TRIAL_EXPIRED` for a local one; the decision the
    /// caller has to make is the same, so both arrive here.
    case LA_TRIAL_EXPIRED
}

/// Where activation data is stored, and what permissions the host application
/// is expected to have.
///
/// Passed to ``LexActivator/setProductId(_:flags:)``.
public enum PermissionFlags: UInt32, Sendable, Equatable, CaseIterable {
    /// The application does not require admin or root permissions to run.
    ///
    /// Activation data is stored per user. This is the right choice for most
    /// macOS and iOS applications.
    case LA_USER = 1

    /// The application must be run with admin or root permissions.
    ///
    /// Activation data is stored system-wide.
    case LA_SYSTEM = 2

    /// System-wide activation, intended for Windows. Included for completeness.
    case LA_ALL_USERS = 3

    /// Activation data is held in memory only.
    ///
    /// Requires re-activation on every launch, so it should only be used with
    /// floating licenses.
    case LA_IN_MEMORY = 4
}

/// A value delivered to the license callback registered with
/// ``LexActivator/setLicenseCallback(_:)``.
public enum LicenseCallbackResult: Sendable, Equatable {
    /// The server reported a license status.
    case status(LicenseStatus)

    /// The server sync failed.
    case failure(LexActivatorError)

    /// Creates a result from a raw native status code.
    init(code: Int32) {
        if let status = LicenseStatus(rawValue: code) {
            self = .status(status)
        } else {
            self = .failure(LexActivatorError(code: code))
        }
    }
}
