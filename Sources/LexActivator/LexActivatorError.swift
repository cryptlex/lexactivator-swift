// Mirrors the LA_E_* error codes in Sources/CLexActivator/include/LexStatusCodes.h.
//
// Maintained by hand. When a native release adds or changes a status code,
// update this file alongside the headers, in the same pull request. Each code
// appears in four places, and all four have to move together:
//
//   1. the `case`, with the header's MESSAGE text as its doc comment
//   2. `code`        — case -> Int32
//   3. `init(code:)` — Int32 -> case
//   4. `message`     — the human readable text
//
// Codes that are outcomes rather than failures (LA_OK, LA_EXPIRED, LA_SUSPENDED,
// LA_GRACE_PERIOD_OVER, the LA_*TRIAL_EXPIRED and LA_RELEASE_* codes) belong in
// LicenseStatus / TrialStatus, not here. Deprecated codes are left out.

import Foundation

/// An error reported by the LexActivator native library.
///
/// Every case maps one-to-one onto a `LA_E_*` code from `LexStatusCodes.h`, so a
/// code seen in the Cryptlex documentation or in a support thread can be matched
/// directly to a case here. Unrecognised codes surface as ``unknown(code:)``
/// rather than being silently dropped.
public enum LexActivatorError: Error, Equatable, Sendable {

    /// Failure code.
    ///
    /// Native code: `LA_FAIL` (1).
    case LA_FAIL

    /// Invalid file path.
    ///
    /// Native code: `LA_E_FILE_PATH` (40).
    case LA_E_FILE_PATH

    /// Invalid or corrupted product file.
    ///
    /// Native code: `LA_E_PRODUCT_FILE` (41).
    case LA_E_PRODUCT_FILE

    /// Invalid product data.
    ///
    /// Native code: `LA_E_PRODUCT_DATA` (42).
    case LA_E_PRODUCT_DATA

    /// The product id is incorrect.
    ///
    /// Native code: `LA_E_PRODUCT_ID` (43).
    case LA_E_PRODUCT_ID

    /// Insufficient system permissions. Occurs when LA_SYSTEM flag is used but application is
    /// not run with admin privileges.
    ///
    /// Native code: `LA_E_SYSTEM_PERMISSION` (44).
    case LA_E_SYSTEM_PERMISSION

    /// No permission to write to file.
    ///
    /// Native code: `LA_E_FILE_PERMISSION` (45).
    case LA_E_FILE_PERMISSION

    /// Fingerprint couldn't be generated because Windows Management Instrumentation (WMI)
    /// service has been disabled. This error is specific to Windows only.
    ///
    /// Native code: `LA_E_WMIC` (46).
    case LA_E_WMIC

    /// The difference between the network time and the system time is more than allowed clock
    /// offset.
    ///
    /// Native code: `LA_E_TIME` (47).
    case LA_E_TIME

    /// Failed to connect to the server due to network error.
    ///
    /// Native code: `LA_E_INET` (48).
    case LA_E_INET

    /// Invalid network proxy.
    ///
    /// Native code: `LA_E_NET_PROXY` (49).
    case LA_E_NET_PROXY

    /// Invalid Cryptlex host url.
    ///
    /// Native code: `LA_E_HOST_URL` (50).
    case LA_E_HOST_URL

    /// The buffer size was smaller than required.
    ///
    /// Native code: `LA_E_BUFFER_SIZE` (51).
    case LA_E_BUFFER_SIZE

    /// App version length is more than 256 characters.
    ///
    /// Native code: `LA_E_APP_VERSION_LENGTH` (52).
    case LA_E_APP_VERSION_LENGTH

    /// The license has been revoked.
    ///
    /// Native code: `LA_E_REVOKED` (53).
    case LA_E_REVOKED

    /// Invalid license key.
    ///
    /// Native code: `LA_E_LICENSE_KEY` (54).
    case LA_E_LICENSE_KEY

    /// Invalid license type. Make sure floating license is not being used.
    ///
    /// Native code: `LA_E_LICENSE_TYPE` (55).
    case LA_E_LICENSE_TYPE

    /// Invalid offline activation response file.
    ///
    /// Native code: `LA_E_OFFLINE_RESPONSE_FILE` (56).
    case LA_E_OFFLINE_RESPONSE_FILE

    /// The offline activation response has expired.
    ///
    /// Native code: `LA_E_OFFLINE_RESPONSE_FILE_EXPIRED` (57).
    case LA_E_OFFLINE_RESPONSE_FILE_EXPIRED

    /// The license has reached it's allowed activations limit.
    ///
    /// Native code: `LA_E_ACTIVATION_LIMIT` (58).
    case LA_E_ACTIVATION_LIMIT

    /// The license activation was deleted on the server.
    ///
    /// Native code: `LA_E_ACTIVATION_NOT_FOUND` (59).
    case LA_E_ACTIVATION_NOT_FOUND

    /// The license has reached it's allowed deactivations limit.
    ///
    /// Native code: `LA_E_DEACTIVATION_LIMIT` (60).
    case LA_E_DEACTIVATION_LIMIT

    /// Trial not allowed for the product.
    ///
    /// Native code: `LA_E_TRIAL_NOT_ALLOWED` (61).
    case LA_E_TRIAL_NOT_ALLOWED

    /// Your account has reached it's trial activations limit.
    ///
    /// Native code: `LA_E_TRIAL_ACTIVATION_LIMIT` (62).
    case LA_E_TRIAL_ACTIVATION_LIMIT

    /// Machine fingerprint has changed since activation.
    ///
    /// Native code: `LA_E_MACHINE_FINGERPRINT` (63).
    case LA_E_MACHINE_FINGERPRINT

    /// Metadata key length is more than 256 characters.
    ///
    /// Native code: `LA_E_METADATA_KEY_LENGTH` (64).
    case LA_E_METADATA_KEY_LENGTH

    /// Metadata value length is more than 4096 characters.
    ///
    /// Native code: `LA_E_METADATA_VALUE_LENGTH` (65).
    case LA_E_METADATA_VALUE_LENGTH

    /// The license has reached it's metadata fields limit.
    ///
    /// Native code: `LA_E_ACTIVATION_METADATA_LIMIT` (66).
    case LA_E_ACTIVATION_METADATA_LIMIT

    /// The trial has reached it's metadata fields limit.
    ///
    /// Native code: `LA_E_TRIAL_ACTIVATION_METADATA_LIMIT` (67).
    case LA_E_TRIAL_ACTIVATION_METADATA_LIMIT

    /// The metadata key does not exist.
    ///
    /// Native code: `LA_E_METADATA_KEY_NOT_FOUND` (68).
    case LA_E_METADATA_KEY_NOT_FOUND

    /// The system time has been tampered (backdated).
    ///
    /// Native code: `LA_E_TIME_MODIFIED` (69).
    case LA_E_TIME_MODIFIED

    /// Invalid version format.
    ///
    /// Native code: `LA_E_RELEASE_VERSION_FORMAT` (70).
    case LA_E_RELEASE_VERSION_FORMAT

    /// Incorrect email or password.
    ///
    /// Native code: `LA_E_AUTHENTICATION_FAILED` (71).
    case LA_E_AUTHENTICATION_FAILED

    /// The meter attribute does not exist.
    ///
    /// Native code: `LA_E_METER_ATTRIBUTE_NOT_FOUND` (72).
    case LA_E_METER_ATTRIBUTE_NOT_FOUND

    /// The meter attribute has reached it's usage limit.
    ///
    /// Native code: `LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED` (73).
    case LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED

    /// Custom device fingerprint length is less than 64 characters or more than 256 characters.
    ///
    /// Native code: `LA_E_CUSTOM_FINGERPRINT_LENGTH` (74).
    case LA_E_CUSTOM_FINGERPRINT_LENGTH

    /// No product version is linked with the license.
    ///
    /// Native code: `LA_E_PRODUCT_VERSION_NOT_LINKED` (75).
    case LA_E_PRODUCT_VERSION_NOT_LINKED

    /// The product version feature flag does not exist.
    ///
    /// Native code: `LA_E_FEATURE_FLAG_NOT_FOUND` (76).
    case LA_E_FEATURE_FLAG_NOT_FOUND

    /// The release version is not allowed.
    ///
    /// Native code: `LA_E_RELEASE_VERSION_NOT_ALLOWED` (77).
    case LA_E_RELEASE_VERSION_NOT_ALLOWED

    /// Release platform length is more than 256 characters.
    ///
    /// Native code: `LA_E_RELEASE_PLATFORM_LENGTH` (78).
    case LA_E_RELEASE_PLATFORM_LENGTH

    /// Release channel length is more than 256 characters.
    ///
    /// Native code: `LA_E_RELEASE_CHANNEL_LENGTH` (79).
    case LA_E_RELEASE_CHANNEL_LENGTH

    /// Application is being run inside a virtual machine / hypervisor, and activation has been
    /// disallowed in the VM.
    ///
    /// Native code: `LA_E_VM` (80).
    case LA_E_VM

    /// Country is not allowed.
    ///
    /// Native code: `LA_E_COUNTRY` (81).
    case LA_E_COUNTRY

    /// IP address is not allowed.
    ///
    /// Native code: `LA_E_IP` (82).
    case LA_E_IP

    /// Application is being run inside a container and activation has been disallowed in the
    /// container.
    ///
    /// Native code: `LA_E_CONTAINER` (83).
    case LA_E_CONTAINER

    /// Invalid release version. Make sure the release version uses the following formats: x.x,
    /// x.x.x, x.x.x.x (where x is a number).
    ///
    /// Native code: `LA_E_RELEASE_VERSION` (84).
    case LA_E_RELEASE_VERSION

    /// Release platform not set.
    ///
    /// Native code: `LA_E_RELEASE_PLATFORM` (85).
    case LA_E_RELEASE_PLATFORM

    /// Release channel not set.
    ///
    /// Native code: `LA_E_RELEASE_CHANNEL` (86).
    case LA_E_RELEASE_CHANNEL

    /// The user is not authenticated.
    ///
    /// Native code: `LA_E_USER_NOT_AUTHENTICATED` (87).
    case LA_E_USER_NOT_AUTHENTICATED

    /// The two-factor authentication code for the user authentication is missing.
    ///
    /// Native code: `LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING` (88).
    case LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING

    /// The two-factor authentication code provided by the user is invalid.
    ///
    /// Native code: `LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID` (89).
    case LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID

    /// Rate limit for API has reached, try again later.
    ///
    /// Native code: `LA_E_RATE_LIMIT` (90).
    case LA_E_RATE_LIMIT

    /// Server error.
    ///
    /// Native code: `LA_E_SERVER` (91).
    case LA_E_SERVER

    /// Client error.
    ///
    /// Native code: `LA_E_CLIENT` (92).
    case LA_E_CLIENT

    /// Invalid account ID.
    ///
    /// Native code: `LA_E_ACCOUNT_ID` (93).
    case LA_E_ACCOUNT_ID

    /// The user account has been temporarily locked for 5 mins due to 5 failed attempts.
    ///
    /// Native code: `LA_E_LOGIN_TEMPORARILY_LOCKED` (100).
    case LA_E_LOGIN_TEMPORARILY_LOCKED

    /// Invalid authentication ID token.
    ///
    /// Native code: `LA_E_AUTHENTICATION_ID_TOKEN_INVALID` (101).
    case LA_E_AUTHENTICATION_ID_TOKEN_INVALID

    /// OIDC SSO is not enabled.
    ///
    /// Native code: `LA_E_OIDC_SSO_NOT_ENABLED` (102).
    case LA_E_OIDC_SSO_NOT_ENABLED

    /// The allowed users for this account has reached its limit.
    ///
    /// Native code: `LA_E_USERS_LIMIT_REACHED` (103).
    case LA_E_USERS_LIMIT_REACHED

    /// OS user has changed since activation and the license is user-locked.
    ///
    /// Native code: `LA_E_OS_USER` (104).
    case LA_E_OS_USER

    /// Invalid permission flag.
    ///
    /// Native code: `LA_E_INVALID_PERMISSION_FLAG` (105).
    case LA_E_INVALID_PERMISSION_FLAG

    /// The free plan has reached it's activation limit.
    ///
    /// Native code: `LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED` (106).
    case LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED

    /// Invalid feature entitlements.
    ///
    /// Native code: `LA_E_FEATURE_ENTITLEMENTS_INVALID` (107).
    case LA_E_FEATURE_ENTITLEMENTS_INVALID

    /// The feature entitlement does not exist.
    ///
    /// Native code: `LA_E_FEATURE_ENTITLEMENT_NOT_FOUND` (108).
    case LA_E_FEATURE_ENTITLEMENT_NOT_FOUND

    /// No entitlement set is linked to the license.
    ///
    /// Native code: `LA_E_ENTITLEMENT_SET_NOT_LINKED` (109).
    case LA_E_ENTITLEMENT_SET_NOT_LINKED

    /// The license cannot be activated before its effective date.
    ///
    /// Native code: `LA_E_LICENSE_NOT_EFFECTIVE` (110).
    case LA_E_LICENSE_NOT_EFFECTIVE

    /// Device not found.
    ///
    /// Native code: `LA_E_DEVICE_NOT_FOUND` (111).
    case LA_E_DEVICE_NOT_FOUND

    /// Device validation failed.
    ///
    /// Native code: `LA_E_DEVICE_VALIDATION_FAILED` (112).
    case LA_E_DEVICE_VALIDATION_FAILED

    /// Fingerprint validation grace period is over. Please connect to internet and restart the
    /// application.
    ///
    /// Native code: `LA_E_FINGERPRINT_VALIDATION_GRACE_PERIOD_OVER` (113).
    case LA_E_FINGERPRINT_VALIDATION_GRACE_PERIOD_OVER

    /// Activation clone detected.
    ///
    /// Native code: `LA_E_ACTIVATION_CLONE_DETECTED` (114).
    case LA_E_ACTIVATION_CLONE_DETECTED

    /// A status code that this version of the package does not recognise.
    ///
    /// Returned when the native library reports a code newer than the headers
    /// this package was generated from.
    case unknown(code: Int32)
}

extension LexActivatorError {
    /// The underlying `LA_E_*` status code reported by the native library.
    public var code: Int32 {
        switch self {
        case .LA_FAIL: return 1
        case .LA_E_FILE_PATH: return 40
        case .LA_E_PRODUCT_FILE: return 41
        case .LA_E_PRODUCT_DATA: return 42
        case .LA_E_PRODUCT_ID: return 43
        case .LA_E_SYSTEM_PERMISSION: return 44
        case .LA_E_FILE_PERMISSION: return 45
        case .LA_E_WMIC: return 46
        case .LA_E_TIME: return 47
        case .LA_E_INET: return 48
        case .LA_E_NET_PROXY: return 49
        case .LA_E_HOST_URL: return 50
        case .LA_E_BUFFER_SIZE: return 51
        case .LA_E_APP_VERSION_LENGTH: return 52
        case .LA_E_REVOKED: return 53
        case .LA_E_LICENSE_KEY: return 54
        case .LA_E_LICENSE_TYPE: return 55
        case .LA_E_OFFLINE_RESPONSE_FILE: return 56
        case .LA_E_OFFLINE_RESPONSE_FILE_EXPIRED: return 57
        case .LA_E_ACTIVATION_LIMIT: return 58
        case .LA_E_ACTIVATION_NOT_FOUND: return 59
        case .LA_E_DEACTIVATION_LIMIT: return 60
        case .LA_E_TRIAL_NOT_ALLOWED: return 61
        case .LA_E_TRIAL_ACTIVATION_LIMIT: return 62
        case .LA_E_MACHINE_FINGERPRINT: return 63
        case .LA_E_METADATA_KEY_LENGTH: return 64
        case .LA_E_METADATA_VALUE_LENGTH: return 65
        case .LA_E_ACTIVATION_METADATA_LIMIT: return 66
        case .LA_E_TRIAL_ACTIVATION_METADATA_LIMIT: return 67
        case .LA_E_METADATA_KEY_NOT_FOUND: return 68
        case .LA_E_TIME_MODIFIED: return 69
        case .LA_E_RELEASE_VERSION_FORMAT: return 70
        case .LA_E_AUTHENTICATION_FAILED: return 71
        case .LA_E_METER_ATTRIBUTE_NOT_FOUND: return 72
        case .LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED: return 73
        case .LA_E_CUSTOM_FINGERPRINT_LENGTH: return 74
        case .LA_E_PRODUCT_VERSION_NOT_LINKED: return 75
        case .LA_E_FEATURE_FLAG_NOT_FOUND: return 76
        case .LA_E_RELEASE_VERSION_NOT_ALLOWED: return 77
        case .LA_E_RELEASE_PLATFORM_LENGTH: return 78
        case .LA_E_RELEASE_CHANNEL_LENGTH: return 79
        case .LA_E_VM: return 80
        case .LA_E_COUNTRY: return 81
        case .LA_E_IP: return 82
        case .LA_E_CONTAINER: return 83
        case .LA_E_RELEASE_VERSION: return 84
        case .LA_E_RELEASE_PLATFORM: return 85
        case .LA_E_RELEASE_CHANNEL: return 86
        case .LA_E_USER_NOT_AUTHENTICATED: return 87
        case .LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING: return 88
        case .LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID: return 89
        case .LA_E_RATE_LIMIT: return 90
        case .LA_E_SERVER: return 91
        case .LA_E_CLIENT: return 92
        case .LA_E_ACCOUNT_ID: return 93
        case .LA_E_LOGIN_TEMPORARILY_LOCKED: return 100
        case .LA_E_AUTHENTICATION_ID_TOKEN_INVALID: return 101
        case .LA_E_OIDC_SSO_NOT_ENABLED: return 102
        case .LA_E_USERS_LIMIT_REACHED: return 103
        case .LA_E_OS_USER: return 104
        case .LA_E_INVALID_PERMISSION_FLAG: return 105
        case .LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED: return 106
        case .LA_E_FEATURE_ENTITLEMENTS_INVALID: return 107
        case .LA_E_FEATURE_ENTITLEMENT_NOT_FOUND: return 108
        case .LA_E_ENTITLEMENT_SET_NOT_LINKED: return 109
        case .LA_E_LICENSE_NOT_EFFECTIVE: return 110
        case .LA_E_DEVICE_NOT_FOUND: return 111
        case .LA_E_DEVICE_VALIDATION_FAILED: return 112
        case .LA_E_FINGERPRINT_VALIDATION_GRACE_PERIOD_OVER: return 113
        case .LA_E_ACTIVATION_CLONE_DETECTED: return 114
        case .unknown(let code): return code
        }
    }

    /// Creates an error from a raw native status code.
    public init(code: Int32) {
        switch code {
        case 1: self = .LA_FAIL
        case 40: self = .LA_E_FILE_PATH
        case 41: self = .LA_E_PRODUCT_FILE
        case 42: self = .LA_E_PRODUCT_DATA
        case 43: self = .LA_E_PRODUCT_ID
        case 44: self = .LA_E_SYSTEM_PERMISSION
        case 45: self = .LA_E_FILE_PERMISSION
        case 46: self = .LA_E_WMIC
        case 47: self = .LA_E_TIME
        case 48: self = .LA_E_INET
        case 49: self = .LA_E_NET_PROXY
        case 50: self = .LA_E_HOST_URL
        case 51: self = .LA_E_BUFFER_SIZE
        case 52: self = .LA_E_APP_VERSION_LENGTH
        case 53: self = .LA_E_REVOKED
        case 54: self = .LA_E_LICENSE_KEY
        case 55: self = .LA_E_LICENSE_TYPE
        case 56: self = .LA_E_OFFLINE_RESPONSE_FILE
        case 57: self = .LA_E_OFFLINE_RESPONSE_FILE_EXPIRED
        case 58: self = .LA_E_ACTIVATION_LIMIT
        case 59: self = .LA_E_ACTIVATION_NOT_FOUND
        case 60: self = .LA_E_DEACTIVATION_LIMIT
        case 61: self = .LA_E_TRIAL_NOT_ALLOWED
        case 62: self = .LA_E_TRIAL_ACTIVATION_LIMIT
        case 63: self = .LA_E_MACHINE_FINGERPRINT
        case 64: self = .LA_E_METADATA_KEY_LENGTH
        case 65: self = .LA_E_METADATA_VALUE_LENGTH
        case 66: self = .LA_E_ACTIVATION_METADATA_LIMIT
        case 67: self = .LA_E_TRIAL_ACTIVATION_METADATA_LIMIT
        case 68: self = .LA_E_METADATA_KEY_NOT_FOUND
        case 69: self = .LA_E_TIME_MODIFIED
        case 70: self = .LA_E_RELEASE_VERSION_FORMAT
        case 71: self = .LA_E_AUTHENTICATION_FAILED
        case 72: self = .LA_E_METER_ATTRIBUTE_NOT_FOUND
        case 73: self = .LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED
        case 74: self = .LA_E_CUSTOM_FINGERPRINT_LENGTH
        case 75: self = .LA_E_PRODUCT_VERSION_NOT_LINKED
        case 76: self = .LA_E_FEATURE_FLAG_NOT_FOUND
        case 77: self = .LA_E_RELEASE_VERSION_NOT_ALLOWED
        case 78: self = .LA_E_RELEASE_PLATFORM_LENGTH
        case 79: self = .LA_E_RELEASE_CHANNEL_LENGTH
        case 80: self = .LA_E_VM
        case 81: self = .LA_E_COUNTRY
        case 82: self = .LA_E_IP
        case 83: self = .LA_E_CONTAINER
        case 84: self = .LA_E_RELEASE_VERSION
        case 85: self = .LA_E_RELEASE_PLATFORM
        case 86: self = .LA_E_RELEASE_CHANNEL
        case 87: self = .LA_E_USER_NOT_AUTHENTICATED
        case 88: self = .LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING
        case 89: self = .LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID
        case 90: self = .LA_E_RATE_LIMIT
        case 91: self = .LA_E_SERVER
        case 92: self = .LA_E_CLIENT
        case 93: self = .LA_E_ACCOUNT_ID
        case 100: self = .LA_E_LOGIN_TEMPORARILY_LOCKED
        case 101: self = .LA_E_AUTHENTICATION_ID_TOKEN_INVALID
        case 102: self = .LA_E_OIDC_SSO_NOT_ENABLED
        case 103: self = .LA_E_USERS_LIMIT_REACHED
        case 104: self = .LA_E_OS_USER
        case 105: self = .LA_E_INVALID_PERMISSION_FLAG
        case 106: self = .LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED
        case 107: self = .LA_E_FEATURE_ENTITLEMENTS_INVALID
        case 108: self = .LA_E_FEATURE_ENTITLEMENT_NOT_FOUND
        case 109: self = .LA_E_ENTITLEMENT_SET_NOT_LINKED
        case 110: self = .LA_E_LICENSE_NOT_EFFECTIVE
        case 111: self = .LA_E_DEVICE_NOT_FOUND
        case 112: self = .LA_E_DEVICE_VALIDATION_FAILED
        case 113: self = .LA_E_FINGERPRINT_VALIDATION_GRACE_PERIOD_OVER
        case 114: self = .LA_E_ACTIVATION_CLONE_DETECTED
        default: self = .unknown(code: code)
        }
    }

    /// A human readable description of the failure, as documented by Cryptlex.
    public var message: String {
        switch self {
        case .LA_FAIL: return "Failure code."
        case .LA_E_FILE_PATH: return "Invalid file path."
        case .LA_E_PRODUCT_FILE: return "Invalid or corrupted product file."
        case .LA_E_PRODUCT_DATA: return "Invalid product data."
        case .LA_E_PRODUCT_ID: return "The product id is incorrect."
        case .LA_E_SYSTEM_PERMISSION: return "Insufficient system permissions. Occurs when LA_SYSTEM flag is used but application is not run with admin privileges."
        case .LA_E_FILE_PERMISSION: return "No permission to write to file."
        case .LA_E_WMIC: return "Fingerprint couldn't be generated because Windows Management Instrumentation (WMI) service has been disabled. This error is specific to Windows only."
        case .LA_E_TIME: return "The difference between the network time and the system time is more than allowed clock offset."
        case .LA_E_INET: return "Failed to connect to the server due to network error."
        case .LA_E_NET_PROXY: return "Invalid network proxy."
        case .LA_E_HOST_URL: return "Invalid Cryptlex host url."
        case .LA_E_BUFFER_SIZE: return "The buffer size was smaller than required."
        case .LA_E_APP_VERSION_LENGTH: return "App version length is more than 256 characters."
        case .LA_E_REVOKED: return "The license has been revoked."
        case .LA_E_LICENSE_KEY: return "Invalid license key."
        case .LA_E_LICENSE_TYPE: return "Invalid license type. Make sure floating license is not being used."
        case .LA_E_OFFLINE_RESPONSE_FILE: return "Invalid offline activation response file."
        case .LA_E_OFFLINE_RESPONSE_FILE_EXPIRED: return "The offline activation response has expired."
        case .LA_E_ACTIVATION_LIMIT: return "The license has reached it's allowed activations limit."
        case .LA_E_ACTIVATION_NOT_FOUND: return "The license activation was deleted on the server."
        case .LA_E_DEACTIVATION_LIMIT: return "The license has reached it's allowed deactivations limit."
        case .LA_E_TRIAL_NOT_ALLOWED: return "Trial not allowed for the product."
        case .LA_E_TRIAL_ACTIVATION_LIMIT: return "Your account has reached it's trial activations limit."
        case .LA_E_MACHINE_FINGERPRINT: return "Machine fingerprint has changed since activation."
        case .LA_E_METADATA_KEY_LENGTH: return "Metadata key length is more than 256 characters."
        case .LA_E_METADATA_VALUE_LENGTH: return "Metadata value length is more than 4096 characters."
        case .LA_E_ACTIVATION_METADATA_LIMIT: return "The license has reached it's metadata fields limit."
        case .LA_E_TRIAL_ACTIVATION_METADATA_LIMIT: return "The trial has reached it's metadata fields limit."
        case .LA_E_METADATA_KEY_NOT_FOUND: return "The metadata key does not exist."
        case .LA_E_TIME_MODIFIED: return "The system time has been tampered (backdated)."
        case .LA_E_RELEASE_VERSION_FORMAT: return "Invalid version format."
        case .LA_E_AUTHENTICATION_FAILED: return "Incorrect email or password."
        case .LA_E_METER_ATTRIBUTE_NOT_FOUND: return "The meter attribute does not exist."
        case .LA_E_METER_ATTRIBUTE_USES_LIMIT_REACHED: return "The meter attribute has reached it's usage limit."
        case .LA_E_CUSTOM_FINGERPRINT_LENGTH: return "Custom device fingerprint length is less than 64 characters or more than 256 characters."
        case .LA_E_PRODUCT_VERSION_NOT_LINKED: return "No product version is linked with the license."
        case .LA_E_FEATURE_FLAG_NOT_FOUND: return "The product version feature flag does not exist."
        case .LA_E_RELEASE_VERSION_NOT_ALLOWED: return "The release version is not allowed."
        case .LA_E_RELEASE_PLATFORM_LENGTH: return "Release platform length is more than 256 characters."
        case .LA_E_RELEASE_CHANNEL_LENGTH: return "Release channel length is more than 256 characters."
        case .LA_E_VM: return "Application is being run inside a virtual machine / hypervisor, and activation has been disallowed in the VM."
        case .LA_E_COUNTRY: return "Country is not allowed."
        case .LA_E_IP: return "IP address is not allowed."
        case .LA_E_CONTAINER: return "Application is being run inside a container and activation has been disallowed in the container."
        case .LA_E_RELEASE_VERSION: return "Invalid release version. Make sure the release version uses the following formats: x.x, x.x.x, x.x.x.x (where x is a number)."
        case .LA_E_RELEASE_PLATFORM: return "Release platform not set."
        case .LA_E_RELEASE_CHANNEL: return "Release channel not set."
        case .LA_E_USER_NOT_AUTHENTICATED: return "The user is not authenticated."
        case .LA_E_TWO_FACTOR_AUTHENTICATION_CODE_MISSING: return "The two-factor authentication code for the user authentication is missing."
        case .LA_E_TWO_FACTOR_AUTHENTICATION_CODE_INVALID: return "The two-factor authentication code provided by the user is invalid."
        case .LA_E_RATE_LIMIT: return "Rate limit for API has reached, try again later."
        case .LA_E_SERVER: return "Server error."
        case .LA_E_CLIENT: return "Client error."
        case .LA_E_ACCOUNT_ID: return "Invalid account ID."
        case .LA_E_LOGIN_TEMPORARILY_LOCKED: return "The user account has been temporarily locked for 5 mins due to 5 failed attempts."
        case .LA_E_AUTHENTICATION_ID_TOKEN_INVALID: return "Invalid authentication ID token."
        case .LA_E_OIDC_SSO_NOT_ENABLED: return "OIDC SSO is not enabled."
        case .LA_E_USERS_LIMIT_REACHED: return "The allowed users for this account has reached its limit."
        case .LA_E_OS_USER: return "OS user has changed since activation and the license is user-locked."
        case .LA_E_INVALID_PERMISSION_FLAG: return "Invalid permission flag."
        case .LA_E_FREE_PLAN_ACTIVATION_LIMIT_REACHED: return "The free plan has reached it's activation limit."
        case .LA_E_FEATURE_ENTITLEMENTS_INVALID: return "Invalid feature entitlements."
        case .LA_E_FEATURE_ENTITLEMENT_NOT_FOUND: return "The feature entitlement does not exist."
        case .LA_E_ENTITLEMENT_SET_NOT_LINKED: return "No entitlement set is linked to the license."
        case .LA_E_LICENSE_NOT_EFFECTIVE: return "The license cannot be activated before its effective date."
        case .LA_E_DEVICE_NOT_FOUND: return "Device not found."
        case .LA_E_DEVICE_VALIDATION_FAILED: return "Device validation failed."
        case .LA_E_FINGERPRINT_VALIDATION_GRACE_PERIOD_OVER: return "Fingerprint validation grace period is over. Please connect to internet and restart the application."
        case .LA_E_ACTIVATION_CLONE_DETECTED: return "Activation clone detected."
        case .unknown(let code): return "Unknown LexActivator status code: \(code)."
        }
    }
}

extension LexActivatorError: LocalizedError, CustomStringConvertible {
    public var errorDescription: String? { message }
    public var description: String { "LexActivatorError(\(code)): \(message)" }
}
