import SwiftUI

// A normal iOS app target. This is how you would ship LexActivator in your own
// application: add the package, then call it from your code.
//
// The shared sample UI (LicenseView / LicenseModel) is compiled into this
// target directly from ../LicenseActivationApp/Sources/LicenseActivationKit,
// so there is only one copy of it in the repository.
@main
struct LexActivatorSampleApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 14.0, *) {
                LicenseView()
            } else {
                Text("This sample requires iOS 14 or later.")
            }
        }
    }
}
