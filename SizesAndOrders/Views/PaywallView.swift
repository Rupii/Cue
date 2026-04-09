import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(StoreManager.self) private var storeManager
    @Environment(\.dismiss) private var dismiss
    @State private var didUnlock = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Hero
                    VStack(spacing: 12) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.purple)

                        Text("Unlock Pro")
                            .font(.largeTitle.bold())

                        Text("4 profiles free. Unlock unlimited with Pro.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        featureRow(icon: "person.3.fill",
                                   title: "Unlimited Profiles",
                                   detail: "Add as many people as you need")
                        featureRow(icon: "paintpalette.fill",
                                   title: "Custom Card Colors",
                                   detail: "Pick any color for each person's card")
                        featureRow(icon: "icloud.fill",
                                   title: "iCloud Sync",
                                   detail: "Access your vault across all your devices")
                        featureRow(icon: "rectangle.stack.fill",
                                   title: "Home Screen Widget",
                                   detail: "Quick-glance your most important person")
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // CTA
                    VStack(spacing: 12) {
                        Button {
                            Task { await storeManager.purchase() }
                        } label: {
                            Group {
                                if storeManager.isLoadingPurchase {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Unlock Pro — $1.99")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        .disabled(storeManager.isLoadingPurchase)

                        Text("One-time purchase · No subscription")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Restore Purchases") {
                            Task { await storeManager.restorePurchases() }
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Purchase Error", isPresented: .init(
                get: { storeManager.purchaseError != nil },
                set: { if !$0 { storeManager.purchaseError = nil } }
            )) {
                Button("OK") { storeManager.purchaseError = nil }
                if storeManager.purchaseError?.contains("restore") == true {
                    Link("App Store Support",
                         destination: URL(string: "https://support.apple.com/billing")!)
                }
            } message: {
                Text(storeManager.purchaseError ?? "")
            }
            // Success haptic + auto-dismiss on Pro unlock
            .sensoryFeedback(.success, trigger: didUnlock)
            .onChange(of: storeManager.status) { _, newStatus in
                if case .pro = newStatus {
                    didUnlock = true
                    dismiss()
                }
            }
        }
    }

    private func featureRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.purple)
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
            .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
