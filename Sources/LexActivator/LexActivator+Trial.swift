import CLexActivator
import Foundation

// MARK: - Trials

extension LexActivator {
    /// Starts the verified trial in your application by contacting the Cryptlex
    /// servers.
    ///
    /// This function should be executed when your application starts first time on the
    /// user's computer, ideally on a button click.
    ///
    /// - Important: Performs a network request and blocks.
    ///
    /// - Returns: The outcome as a ``TrialStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    @discardableResult
    public static func activateTrial() throws -> TrialStatus {
        try Native.outcome(CLexActivator.ActivateTrial(), [0: .LA_OK, 25: .LA_TRIAL_EXPIRED])
    }

    /// Synchronizes the trial activation data with the Cryptlex servers.
    ///
    /// The trial must already be activated when this function is called.
    ///
    /// This is a blocking call that performs a one-time synchronization to refresh the
    /// local trial data.
    ///
    /// Unlike `isTrialGenuine()`, which validates the trial activation data locally, this
    /// function performs an immediate synchronization with the servers.
    ///
    /// - Important: Performs a network request and blocks.
    ///
    /// - Returns: The outcome as a ``TrialStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: Use this function to immediately reflect server-side changes on the user's
    ///   machine, such as trial extensions.
    ///
    /// - Note: RETURN CODES: LA_OK, LA_TRIAL_EXPIRED, LA_FAIL, LA_E_PRODUCT_ID, LA_E_INET,
    ///   LA_E_VM, LA_E_TIME, LA_E_SERVER, LA_E_CLIENT, LA_E_COUNTRY, LA_E_IP,
    ///   LA_E_RATE_LIMIT, LA_E_TIME_MODIFIED, LA_E_CONTAINER
    @discardableResult
    public static func syncTrialActivation() throws -> TrialStatus {
        try Native.outcome(CLexActivator.SyncTrialActivation(), [0: .LA_OK, 25: .LA_TRIAL_EXPIRED])
    }

    /// Activates your trial using the offline activation response file.
    ///
    /// - Parameter filePath: path of the offline activation response file.
    ///
    /// - Returns: The outcome as a ``TrialStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    @discardableResult
    public static func activateTrialOffline(filePath: String) throws -> TrialStatus {
        let status = Native.withCString(filePath) { CLexActivator.ActivateTrialOffline($0) }
        return try Native.outcome(status, [0: .LA_OK, 25: .LA_TRIAL_EXPIRED])
    }

    /// Generates the offline trial activation request needed for generating offline
    /// trial activation response in the dashboard.
    ///
    /// - Parameter filePath: path of the file for the offline request.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func generateOfflineTrialActivationRequest(filePath: String) throws {
        try Native.check(
            Native.withCString(filePath) { CLexActivator.GenerateOfflineTrialActivationRequest($0) }
        )
    }

    /// It verifies whether trial has started and is genuine or not. The verification is
    /// done locally by verifying the cryptographic digital signature fetched at the
    /// time of trial activation.
    ///
    /// This function must be called on every start of your program during the trial
    /// period.
    ///
    /// - Returns: The outcome as a ``TrialStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    public static func isTrialGenuine() throws -> TrialStatus {
        try Native.outcome(CLexActivator.IsTrialGenuine(), [0: .LA_OK, 25: .LA_TRIAL_EXPIRED])
    }

    /// Starts the local(unverified) trial.
    ///
    /// This function should be executed when your application starts first time on the
    /// user's computer.
    ///
    /// - Parameter trialLength: trial length in days
    ///
    /// - Returns: The outcome as a ``TrialStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: The function is only meant for local(unverified) trials.
    @discardableResult
    public static func activateLocalTrial(trialLength: UInt32) throws -> TrialStatus {
        try Native.outcome(CLexActivator.ActivateLocalTrial(trialLength), [0: .LA_OK, 26: .LA_TRIAL_EXPIRED])
    }

    /// It verifies whether trial has started and is genuine or not. The verification is
    /// done locally.
    ///
    /// This function must be called on every start of your program during the trial
    /// period.
    ///
    /// - Returns: The outcome as a ``TrialStatus``. Outcomes that are not failures are returned
    ///   rather than thrown, so they cannot be mistaken for an error.
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: The function is only meant for local(unverified) trials.
    public static func isLocalTrialGenuine() throws -> TrialStatus {
        try Native.outcome(CLexActivator.IsLocalTrialGenuine(), [0: .LA_OK, 26: .LA_TRIAL_EXPIRED])
    }

    /// Extends the local trial.
    ///
    /// - Parameter trialExtensionLength: number of days to extend the trial
    ///
    /// - Throws: ``LexActivatorError`` if the native library reports a failure.
    ///
    /// - Note: The function is only meant for local(unverified) trials.
    public static func extendLocalTrial(trialExtensionLength: UInt32) throws {
        try Native.check(CLexActivator.ExtendLocalTrial(trialExtensionLength))
    }
}
