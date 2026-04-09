import SwiftUI
import SwiftData

@main
struct SizesAndOrdersApp: App {
    @State private var authManager = AuthManager()
    @State private var storeManager = StoreManager()

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Person.self,
            SizeEntry.self,
            OrderEntry.self,
            NoteEntry.self
        ])
        // iCloud sync note: ModelContainer always uses cloudKitDatabase: .automatic.
        // For free users, CloudKit is a no-op until iCloud access is granted after Pro purchase.
        // After Pro purchase, the system prompts for iCloud access on next launch.
        // Do NOT reinit the container at runtime — reinit risks data loss.
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // CloudKit may not be available in simulator — fall back to local only
            let localConfig = ModelConfiguration(schema: schema)
            do {
                modelContainer = try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("Failed to initialize ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(authManager: authManager)
                .environment(storeManager)
                .task {
                    // Transaction listener runs for the app's lifetime
                    let _ = storeManager.listenForTransactions()
                    await storeManager.checkEntitlement()
                }
        }
        .modelContainer(modelContainer)
    }
}
