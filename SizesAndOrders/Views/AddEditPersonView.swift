import SwiftUI
import SwiftData

struct AddEditPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Person.sortOrder) private var persons: [Person]

    let person: Person?  // nil = add mode, non-nil = edit mode

    @State private var name: String = ""
    @State private var emoji: String = "👤"
    @State private var relation: String = ""
    @State private var showAvatarPicker = false

    // Entry fields
    @State private var sizeCategory: String = ""
    @State private var sizeLabel: String = ""
    @State private var sizeValue: String = ""
    @State private var orderType: String = ""
    @State private var orderFreetext: String = ""
    @State private var noteKey: String = ""
    @State private var noteValue: String = ""
    @State private var noteIsAllergy: Bool = false
    @State private var didSave = false

    // Date fields
    @State private var date1Label: String = ""
    @State private var date1: Date = Date()
    @State private var hasDate1: Bool = false
    @State private var date2Label: String = ""
    @State private var date2: Date = Date()
    @State private var hasDate2: Bool = false

    // Editing state for entries
    @State private var editingSize: SizeEntry? = nil
    @State private var editingOrder: OrderEntry? = nil
    @State private var editingNote: NoteEntry? = nil

    private var isEditing: Bool { person != nil }
    private var title: String { isEditing ? "Edit \(person!.name)" : "New Person" }
    private var isEditingEntry: Bool { editingSize != nil || editingOrder != nil || editingNote != nil }

    private var isFormInvalid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        return trimmedName.isEmpty
    }

    private var avatarGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#C084FC").opacity(0.85), Color(hex: "#818CF8").opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    // Avatar row
                    HStack {
                        Text("Avatar")
                            .foregroundStyle(.primary)
                        Spacer()
                        Button {
                            showAvatarPicker = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(avatarGradient)
                                    .frame(width: 40, height: 40)
                                Text(emoji)
                                    .font(.title3)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    TextField("Name", text: $name)
                    TextField("Relation (e.g. Partner, Mom)", text: $relation)
                }

                datesSection

                if isEditing, let p = person {
                    sizeSection(for: p)
                    orderSection(for: p)
                    noteSection(for: p)

                    Section {
                        Button("Delete \(p.name)", role: .destructive) {
                            modelContext.delete(p)
                            try? modelContext.save()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(isFormInvalid)
                }
            }
            .onAppear { prefill() }
            .sensoryFeedback(.success, trigger: didSave)
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerSheet(selectedEmoji: $emoji)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var datesSection: some View {
        Section("Important Dates") {
            // Date 1
            Toggle("Add a date", isOn: $hasDate1.animation())
            if hasDate1 {
                TextField("Label (e.g. Birthday)", text: $date1Label)
                DatePicker("Date", selection: $date1, displayedComponents: .date)
            }

            // Date 2 — only shown once date 1 is enabled
            if hasDate1 {
                Toggle("Add a second date", isOn: $hasDate2.animation())
                if hasDate2 {
                    TextField("Label (e.g. Anniversary)", text: $date2Label)
                    DatePicker("Date", selection: $date2, displayedComponents: .date)
                }
            }
        }
    }

    private func sizeSection(for p: Person) -> some View {
        Section("Sizes") {
            ForEach(p.sizes.sorted(by: { $0.createdAt < $1.createdAt }),
                    id: \.persistentModelID) { size in
                HStack {
                    VStack(alignment: .leading) {
                        Text(size.label).font(.subheadline)
                        Text(size.value).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        modelContext.delete(size)
                        try? modelContext.save()
                    } label: {
                        Image(systemName: "trash").foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingSize = size
                    sizeCategory = size.category
                    sizeLabel = size.label
                    sizeValue = size.value
                }
                .background(editingSize?.persistentModelID == size.persistentModelID ? Color.blue.opacity(0.1) : Color.clear)
            }
            Group {
                TextField("Category (e.g. Shoes)", text: $sizeCategory)
                TextField("Label (e.g. Shoe size)", text: $sizeLabel)
                TextField("Value (e.g. 7.5 US)", text: $sizeValue)
                Button(editingSize != nil ? "Update Size" : "Add Size") {
                    guard !sizeLabel.isEmpty, !sizeValue.isEmpty else { return }
                    if let existing = editingSize {
                        // Update existing size
                        existing.category = sizeCategory
                        existing.label = sizeLabel
                        existing.value = sizeValue
                    } else {
                        // Add new size
                        let entry = SizeEntry(category: sizeCategory, label: sizeLabel,
                                             value: sizeValue, person: p)
                        modelContext.insert(entry)
                    }
                    try? modelContext.save()
                    sizeCategory = ""; sizeLabel = ""; sizeValue = ""
                    editingSize = nil
                }
                .disabled(sizeLabel.isEmpty || sizeValue.isEmpty)

                if editingSize != nil {
                    Button("Cancel Edit") {
                        sizeCategory = ""; sizeLabel = ""; sizeValue = ""
                        editingSize = nil
                    }
                    .foregroundStyle(.orange)
                }
            }
        }
    }

    private func orderSection(for p: Person) -> some View {
        Section("Orders") {
            ForEach(p.orders.sorted(by: { $0.createdAt < $1.createdAt }),
                    id: \.persistentModelID) { order in
                HStack {
                    VStack(alignment: .leading) {
                        Text(order.type).font(.subheadline)
                        Text(order.freetext).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        modelContext.delete(order)
                        try? modelContext.save()
                    } label: {
                        Image(systemName: "trash").foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingOrder = order
                    orderType = order.type
                    orderFreetext = order.freetext
                }
                .background(editingOrder?.persistentModelID == order.persistentModelID ? Color.blue.opacity(0.1) : Color.clear)
            }
            Group {
                TextField("Type (e.g. Coffee)", text: $orderType)
                TextField("Order details", text: $orderFreetext)
                Button(editingOrder != nil ? "Update Order" : "Add Order") {
                    guard !orderType.isEmpty, !orderFreetext.isEmpty else { return }
                    if let existing = editingOrder {
                        // Update existing order
                        existing.type = orderType
                        existing.freetext = orderFreetext
                    } else {
                        // Add new order
                        let entry = OrderEntry(type: orderType, freetext: orderFreetext, person: p)
                        modelContext.insert(entry)
                    }
                    try? modelContext.save()
                    orderType = ""; orderFreetext = ""
                    editingOrder = nil
                }
                .disabled(orderType.isEmpty || orderFreetext.isEmpty)

                if editingOrder != nil {
                    Button("Cancel Edit") {
                        orderType = ""; orderFreetext = ""
                        editingOrder = nil
                    }
                    .foregroundStyle(.orange)
                }
            }
        }
    }

    private func noteSection(for p: Person) -> some View {
        Section("Notes & Allergies") {
            ForEach(p.notes.sorted(by: { $0.createdAt < $1.createdAt }),
                    id: \.persistentModelID) { note in
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            if note.isAllergy {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                            Text(note.key).font(.subheadline)
                        }
                        Text(note.value).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        modelContext.delete(note)
                        try? modelContext.save()
                    } label: {
                        Image(systemName: "trash").foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingNote = note
                    noteKey = note.key
                    noteValue = note.value
                    noteIsAllergy = note.isAllergy
                }
                .background(editingNote?.persistentModelID == note.persistentModelID ? Color.blue.opacity(0.1) : Color.clear)
            }
            Group {
                TextField("Key (e.g. Allergy, Brand note)", text: $noteKey)
                TextField("Value", text: $noteValue)
                Toggle("Mark as Allergy", isOn: $noteIsAllergy)
                Button(editingNote != nil ? "Update Note" : "Add Note") {
                    guard !noteKey.isEmpty, !noteValue.isEmpty else { return }
                    if let existing = editingNote {
                        // Update existing note
                        existing.key = noteKey
                        existing.value = noteValue
                        existing.isAllergy = noteIsAllergy
                    } else {
                        // Add new note
                        let entry = NoteEntry(key: noteKey, value: noteValue,
                                             isAllergy: noteIsAllergy, person: p)
                        modelContext.insert(entry)
                    }
                    try? modelContext.save()
                    noteKey = ""; noteValue = ""; noteIsAllergy = false
                    editingNote = nil
                }
                .disabled(noteKey.isEmpty || noteValue.isEmpty)

                if editingNote != nil {
                    Button("Cancel Edit") {
                        noteKey = ""; noteValue = ""; noteIsAllergy = false
                        editingNote = nil
                    }
                    .foregroundStyle(.orange)
                }
            }
        }
    }

    private func prefill() {
        guard let p = person else { return }
        name = p.name
        emoji = p.emoji.isEmpty ? "👤" : p.emoji
        relation = p.relation
        if let d = p.date1 {
            hasDate1 = true
            date1 = d
            date1Label = p.date1Label
        }
        if let d = p.date2 {
            hasDate2 = true
            date2 = d
            date2Label = p.date2Label
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let p = person {
            // Edit mode
            p.name = trimmedName
            p.emoji = emoji
            p.relation = relation
            p.date1 = hasDate1 ? date1 : nil
            p.date1Label = hasDate1 ? date1Label : ""
            p.date2 = (hasDate1 && hasDate2) ? date2 : nil
            p.date2Label = (hasDate1 && hasDate2) ? date2Label : ""
        } else {
            // Add mode — assign next sortOrder
            let nextOrder = (persons.map(\.sortOrder).max() ?? -1) + 1
            let colorHex = ColorPalette.color(for: nextOrder)
            let newPerson = Person(
                name: trimmedName,
                emoji: emoji,
                relation: relation,
                colorHex: colorHex,
                sortOrder: nextOrder
            )
            newPerson.date1 = hasDate1 ? date1 : nil
            newPerson.date1Label = hasDate1 ? date1Label : ""
            newPerson.date2 = (hasDate1 && hasDate2) ? date2 : nil
            newPerson.date2Label = (hasDate1 && hasDate2) ? date2Label : ""
            modelContext.insert(newPerson)
        }
        // Save before dismissing so persistentModelID is stable for matchedGeometryEffect
        try? modelContext.save()
        didSave.toggle()
        dismiss()
    }
}
