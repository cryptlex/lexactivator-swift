import SwiftUI

/// The sample screen: checks the license on appear, activates if this device
/// is not activated yet, and shows what happened.
///
/// Add `LicenseActivationKit` to an iOS or macOS app target and present this
/// view to try the package without writing any UI of your own.
@available(iOS 14.0, macOS 11.0, *)
public struct LicenseView: View {
    @StateObject private var model = LicenseModel()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                if !model.expiry.isEmpty { expiryRow }
                logPanel
                if model.isActivated { deactivateButton }
            }
            .padding(24)
            .frame(maxWidth: 520, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear { model.checkLicense() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("License")
                .font(.largeTitle.bold())
            HStack(spacing: 8) {
                Text(model.summary)
                    .font(.title3)
                    .foregroundColor(model.isActivated ? .green : .secondary)
                if model.isBusy { ProgressView() }
            }
        }
    }

    private var expiryRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Expires")
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(model.expiry)
        }
        .font(.callout)
    }

    private var logPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(model.log.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(10)
    }

    private var deactivateButton: some View {
        Button(action: model.deactivate) {
            Text("Release this activation")
                .font(.callout.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(model.isBusy ? 0.05 : 0.12))
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(model.isBusy)
    }
}
