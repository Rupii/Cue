import LocalAuthentication
import Observation

@Observable
final class AuthManager {
    private(set) var isUnlocked = false
    var showPasscodeFallback = false

    func authenticate() {
        let context = LAContext()
        var error: NSError?
        let policy: LAPolicy = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics, error: &error)
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication

        context.evaluatePolicy(policy,
            localizedReason: "Unlock your vault") { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isUnlocked = success
            }
        }
    }

    func authenticateWithPasscode() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication,
            localizedReason: "Unlock your vault") { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isUnlocked = success
            }
        }
    }

    func lockForBackground() {
        isUnlocked = false
    }

    // Testable setter — avoids calling the real LAContext in unit tests
    func setUnlocked(_ value: Bool) {
        isUnlocked = value
    }
}
