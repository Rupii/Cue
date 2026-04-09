import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let person: Person
    let namespace: Namespace.ID

    @State private var showEditPerson = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerCard
                        .padding(.bottom, 16)

                    if !person.notes.filter({ $0.isAllergy }).isEmpty {
                        allergySection
                    }

                    if person.date1 != nil || person.date2 != nil {
                        datesSection
                    }

                    if !person.sizes.isEmpty {
                        sectionBlock(title: "Sizes", systemImage: "ruler") {
                            ForEach(person.sizes.sorted(by: { $0.createdAt < $1.createdAt }),
                                    id: \.persistentModelID) { size in
                                rowItem(label: size.label, value: size.value)
                            }
                        }
                    }

                    if !person.orders.isEmpty {
                        sectionBlock(title: "Orders", systemImage: "cup.and.saucer") {
                            ForEach(person.orders.sorted(by: { $0.createdAt < $1.createdAt }),
                                    id: \.persistentModelID) { order in
                                rowItem(label: order.type, value: order.freetext)
                            }
                        }
                    }

                    let nonAllergyNotes = person.notes.filter { !$0.isAllergy }
                    if !nonAllergyNotes.isEmpty {
                        sectionBlock(title: "Notes", systemImage: "note.text") {
                            ForEach(nonAllergyNotes.sorted(by: { $0.createdAt < $1.createdAt }),
                                    id: \.persistentModelID) { note in
                                rowItem(label: note.key, value: note.value)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { showEditPerson = true }
                }
            }
            .sheet(isPresented: $showEditPerson) {
                AddEditPersonView(person: person)
            }
        }
    }

    private var headerCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorPalette.gradient(for: person.sortOrder))
                .matchedGeometryEffect(id: person.persistentModelID, in: namespace)
                .frame(height: 140)
            HStack {
                Text(person.emoji)
                    .font(.largeTitle)
                VStack(alignment: .leading, spacing: 4) {
                    Text(person.name)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(person.relation)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(20)
        }
    }

    private var allergySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Allergies", systemImage: "exclamationmark.triangle.fill")
                .font(.footnote.bold())
                .foregroundStyle(.red)
                .padding(.horizontal, 16)

            ForEach(person.notes.filter { $0.isAllergy }
                .sorted(by: { $0.createdAt < $1.createdAt }),
                    id: \.persistentModelID) { note in
                HStack {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                    Text(note.value).font(.subheadline)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.bottom, 12)
    }

    private var datesSection: some View {
        sectionBlock(title: "Dates", systemImage: "calendar") {
            if let d = person.date1, !person.date1Label.isEmpty {
                rowItem(label: person.date1Label,
                        value: d.formatted(.dateTime.month(.wide).day().year()))
            }
            if let d = person.date2, !person.date2Label.isEmpty {
                rowItem(label: person.date2Label,
                        value: d.formatted(.dateTime.month(.wide).day().year()))
            }
        }
    }

    private func sectionBlock<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Label(title, systemImage: systemImage)
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.bottom, 16)
    }

    private func rowItem(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 16)
        }
    }
}
