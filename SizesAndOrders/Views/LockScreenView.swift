import SwiftUI

struct LockScreenView: View {
    var authManager: AuthManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white.opacity(0.8))

                Text("Sizes & Orders")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Your vault is locked")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))

                VStack(spacing: 12) {
                    Button("Unlock") {
                        authManager.authenticate()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Use Passcode") {
                        authManager.authenticateWithPasscode()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.footnote)
                }
            }
        }
        .onAppear {
            authManager.authenticate()
        }
    }
}
