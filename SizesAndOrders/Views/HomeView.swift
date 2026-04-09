import SwiftUI
import SwiftData
import CoreData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreManager.self) private var storeManager
    @Query(sort: \Person.sortOrder) private var persons: [Person]
    @Namespace private var cardNamespace
    @State private var selectedPerson: Person?
    @State private var showAddPerson = false
    @State private var showPaywall = false
    @State private var isSyncing = false
    @State private var seedDataInserted = false
    @Binding var isDarkMode: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if persons.isEmpty {
                    emptyStateView
                } else {
                    cardStackView
                }
            }
            .navigationTitle("My Cue")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Dark mode toggle (leading)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .symbolEffect(.bounce, value: isDarkMode)
                    }
                }
                // iCloud sync indicator (centre)
                ToolbarItem(placement: .principal) {
                    if isSyncing {
                        HStack(spacing: 4) {
                            ProgressView().scaleEffect(0.7)
                            Text("Syncing…").font(.caption).foregroundStyle(.secondary)
                        }
                        .transition(.opacity)
                    }
                }
                // Add / Paywall button (trailing)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if storeManager.canAddProfile {
                            showAddPerson = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: storeManager.isAtFreeLimit
                                  ? "lock.circle.fill"
                                  : "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(storeManager.isAtFreeLimit ? .red : .blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddPerson) {
                AddEditPersonView(person: nil)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .fullScreenCover(item: $selectedPerson) { person in
                DetailView(person: person, namespace: cardNamespace)
            }
            .onAppear {
                if persons.isEmpty && !seedDataInserted {
                    Person.insertSeedData(into: modelContext)
                    try? modelContext.save()
                    seedDataInserted = true
                }
                storeManager.updateFreeProfileCount(persons.count)
            }
            .onChange(of: persons.count) { _, newCount in
                storeManager.updateFreeProfileCount(newCount)
            }
            // iCloud sync indicator via CloudKit notification
            .onReceive(
                NotificationCenter.default.publisher(
                    for: NSPersistentCloudKitContainer.eventChangedNotification)
            ) { notification in
                guard let event = notification.userInfo?[
                    NSPersistentCloudKitContainer.eventNotificationUserInfoKey
                ] as? NSPersistentCloudKitContainer.Event else { return }
                withAnimation { isSyncing = event.endDate == nil }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSPersistentCloudKitContainer.eventChangedNotification,
                    object: nil
                )
            }
            // Pro widget instructions banner
            .safeAreaInset(edge: .bottom) {
                if case .pro = storeManager.status {
                    widgetBanner
                }
            }
        }
    }

    // MARK: - Subviews

    private var cardStackView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(persons.enumerated()), id: \.element.persistentModelID) { index, person in
                    CardView(
                        person: person,
                        namespace: cardNamespace,
                        isExpanded: false
                    ) {
                        selectedPerson = person
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, index == 0 ? 20 : 8)
                }
            }
            .padding(.bottom, 20)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(width: 280, height: 120)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("Tap + to add your first person")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .symbolEffect(.pulse)
        }
    }

    private var widgetBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "rectangle.stack.fill")
                .foregroundStyle(.purple)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Home Screen Widget")
                    .font(.subheadline.weight(.semibold))
                Text("Long-press home screen → tap + → Sizes & Orders")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
