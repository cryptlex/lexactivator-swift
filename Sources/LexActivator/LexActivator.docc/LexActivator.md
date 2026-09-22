# ``LexActivator``

Add software licensing to an iOS or macOS application with the Cryptlex
LexActivator library.

## Overview

Configure the library once at launch, then check the license. `LexActivator` is
a namespace over a native library that holds global state, so every method is
`static`.

```swift
import LexActivator

try LexActivator.setProductData("<contents of Product.dat>")
try LexActivator.setProductId("<your product id>", flags: .LA_USER)

// Check first; only activate a device that is not activated yet.
if try LexActivator.isLicenseGenuine() == .LA_OK {
    startApplication()
} else {
    try LexActivator.setLicenseKey("XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX")
    try LexActivator.activateLicense()
}
```

### Errors and outcomes

Anything that fails throws a ``LexActivatorError``, whose cases map one-to-one
onto the `LA_E_*` codes in the Cryptlex documentation. Outcomes that are not
failures — an activated licence that has expired, for instance — come back as a
``LicenseStatus`` instead, so they cannot be mistaken for success.

### Threading

Activation, deactivation and sync perform network requests and block until they
finish; call them off the main thread. Configuration and the offline readers are
cheap and safe to call anywhere.

## Topics

### Configuring the library

- ``LexActivator/setProductData(_:)``
- ``LexActivator/setProductFile(_:)``
- ``LexActivator/setProductId(_:flags:)``
- ``LexActivator/setDataDirectory(_:)``
- ``LexActivator/setLicenseKey(_:)``
- ``LexActivator/setLicenseUserCredential(email:password:)``
- ``LexActivator/setReleaseVersion(_:)``
- ``LexActivator/setNetworkProxy(_:)``
- ``LexActivator/setCryptlexHost(_:)``
- ``PermissionFlags``

### Activating and validating

- ``LexActivator/activateLicense()``
- ``LexActivator/isLicenseGenuine()``
- ``LexActivator/isLicenseValid()``
- ``LexActivator/syncLicenseActivation()``
- ``LexActivator/deactivateLicense()``
- ``LicenseStatus``

### Reacting to server changes

- ``LexActivator/setLicenseCallback(_:)``
- ``LexActivator/removeLicenseCallback()``
- ``LicenseCallbackResult``

### Reading license information

- ``LexActivator/getLicenseKey()``
- ``LexActivator/getLicenseType()``
- ``LexActivator/getLicenseExpiryDate()``
- ``LexActivator/getLicenseAllowedActivations()``
- ``LexActivator/getLicenseTotalActivations()``
- ``LexActivator/getLicenseUserEmail()``
- ``LexActivator/getLicenseUserName()``
- ``LexActivator/getLicenseMetadata(forKey:)``
- ``LexActivator/getUserLicenses()``
- ``UserLicense``
- ``OrganizationAddress``

### Entitlements and meter attributes

- ``LexActivator/getFeatureEntitlements()``
- ``LexActivator/getFeatureEntitlement(featureName:)``
- ``LexActivator/getLicenseMeterAttribute(name:)``
- ``LexActivator/incrementActivationMeterAttributeUses(name:by:)``
- ``FeatureEntitlement``
- ``LicenseMeterAttribute``

### Trials

- ``LexActivator/activateTrial()``
- ``LexActivator/isTrialGenuine()``
- ``LexActivator/activateLocalTrial(trialLength:)``
- ``LexActivator/isLocalTrialGenuine()``
- ``TrialStatus``

### Offline activation

- ``LexActivator/generateOfflineActivationRequest(filePath:)``
- ``LexActivator/activateLicenseOffline(filePath:)``
- ``LexActivator/generateOfflineDeactivationRequest(filePath:)``

### Diagnostics

- ``LexActivator/getLibraryVersion()``
- ``LexActivator/getDataStoreInfo()``
- ``LexActivator/getLastActivationError()``
- ``LexActivatorError``
- ``DataStoreInfo``
