import SwiftUI
import SwiftData
import WidgetKit

/// Root view that:
/// - Owns the scene phase handler (background → lock + widget snapshot)
/// - Holds the @Query needed to write the widget snapshot on background
/// - Applies dark/light mode preference globally
struct RootView: View {
    var authManager: AuthManager  // @Observable — no property wrapper needed
    @Environment(StoreManager.self) private var storeManager
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Person.sortOrder) private var persons: [Person]
    @State private var showObscured = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        ZStack {
            if !authManager.isUnlocked {
                LockScreenView(authManager: authManager)
            } else {
                HomeView(isDarkMode: $isDarkMode)
            }
            if showObscured {
                Color.black.ignoresSafeArea()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                showObscured = true
                authManager.lockForBackground()
                // Write widget snapshot — converts Person → WidgetPersonSnapshot here
                // so WidgetSnapshotWriter.swift stays SwiftData-free (shared with widget target)
                let snapshots = persons.prefix(3).map { person -> WidgetPersonSnapshot in
                    let allergyFields = person.notes
                        .filter { $0.isAllergy }
                        .map { "⚠️ \($0.value)" }
                    let sizeFields = person.sizes
                        .sorted(by: { $0.createdAt > $1.createdAt })
                        .prefix(2).map { "\($0.label): \($0.value)" }
                    let orderFields = person.orders
                        .sorted(by: { $0.createdAt > $1.createdAt })
                        .prefix(2).map { "\($0.type): \($0.freetext)" }
                    let topFields = (allergyFields + sizeFields + orderFields).prefix(3)
                    return WidgetPersonSnapshot(
                        name: person.name,
                        emoji: person.emoji,
                        relation: person.relation,
                        colorHex: person.colorHex,
                        topFields: Array(topFields),
                        hasAllergy: person.notes.contains { $0.isAllergy }
                    )
                }
                WidgetSnapshotWriter.write(snapshots: Array(snapshots))
                WidgetCenter.shared.reloadTimelines(ofKind: "VaultWidget")
            } else if newPhase == .active {
                showObscured = false
                // Auth is triggered by LockScreenView.onAppear —
                // do NOT call authenticate() here, it causes an infinite loop
                // when the auth dialog itself cycles scenePhase inactive→active.
            }
        }
    }
}
