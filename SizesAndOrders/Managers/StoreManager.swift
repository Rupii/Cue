import StoreKit
import Observation

enum EntitlementStatus: Equatable {
    case free(profileCount: Int)
    case pro
}

@Observable
final class StoreManager {
    private(set) var status: EntitlementStatus = .free(profileCount: 0)
    private(set) var isLoadingPurchase = false
    var purchaseError: String?
    private var transactionListener: Task<Void, Never>?

    static let unlockProductID = "com.yourapp.sizesandorders.pro.unlock"
    static let freeProfileLimit = 4

    var isAtFreeLimit: Bool {
        guard case .free(let count) = status else { return false }
        return count >= Self.freeProfileLimit
    }

    var canAddProfile: Bool {
        switch status {
        case .pro: return true
        case .free(let count): return count < Self.freeProfileLimit
        }
    }

    // MARK: - Entitlement check (call at app launch)

    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.productID == Self.unlockProductID {
                status = .pro
                return
            }
        }
        // If we were Pro and no entitlement found, revert to free
        // Preserve existing profile count if reverting
        if case .pro = status {
            status = .free(profileCount: 0)
        }
    }

    // MARK: - Transaction listener (start at app launch, keep alive)

    func listenForTransactions() -> Task<Void, Never> {
        let task = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let tx) = result,
                   tx.productID == Self.unlockProductID {
                    await MainActor.run { self?.status = .pro }
                    await tx.finish()
                }
            }
        }
        // Store task to keep it alive
        transactionListener = task
        return task
    }

    // MARK: - Purchase

    func purchase() async {
        isLoadingPurchase = true
        purchaseError = nil
        defer { isLoadingPurchase = false }

        do {
            let products = try await Product.products(for: [Self.unlockProductID])
            guard let product = products.first else {
                purchaseError = "Product not available. Try again later."
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let tx) = verification {
                    status = .pro
                    await tx.finish()
                }
            case .pending:
                purchaseError = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkEntitlement()
        } catch {
            purchaseError = "Nothing to restore. Contact App Store support if you believe this is an error."
        }
    }

    // MARK: - Profile count sync (call after any add/delete)

    func updateFreeProfileCount(_ count: Int) {
        guard case .free = status else { return }
        // Validate count is within reasonable bounds
        let validCount = max(0, min(count, Self.freeProfileLimit + 1))
        status = .free(profileCount: validCount)
    }

    // MARK: - Test helpers

    func setProForTesting() { status = .pro }
}
