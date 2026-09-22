import SwiftUI
import LicenseActivationKit

// Hosts the shared sample UI as an app on both platforms.
//
//   macOS:     Scripts/run-sample.sh macos
//   iOS (sim): Scripts/run-sample.sh ios
//
// Those scripts wrap this executable in a real .app bundle, which is what both
// platforms expect. In your own project you would instead create an app target
// in Xcode and present `LicenseView()` from it — see Examples/README.md.
@available(iOS 14.0, macOS 11.0, *)
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            content
        }
    }

    private var content: some View {
        #if os(macOS)
        LicenseView().frame(minWidth: 480, minHeight: 620)
        #else
        LicenseView()
        #endif
    }
}

if #available(iOS 14.0, macOS 11.0, *) {
    SampleApp.main()
} else {
    print("This sample requires iOS 14 / macOS 11 or later.")
}
