import SwiftUI
import WidgetKit

struct WidgetEntryView: View {
    var entry: VaultEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.persons.isEmpty {
            emptyState
        } else {
            personView(entry.persons[0])
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "person.badge.plus")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Open Sizes & Orders\nto add people")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func personView(_ person: WidgetPersonSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(person.emoji).font(.title3)
                VStack(alignment: .leading, spacing: 1) {
                    Text(person.name)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                    Text(person.relation)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                ForEach(person.topFields.prefix(3), id: \.self) { field in
                    Text(field)
                        .font(.caption2)
                        .foregroundStyle(field.hasPrefix("⚠️") ? .red : .white.opacity(0.9))
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .containerBackground(
            LinearGradient(
                colors: [Color(hex: person.colorHex).opacity(0.9),
                         Color(hex: person.colorHex).opacity(0.6)],
                startPoint: .topLeading, endPoint: .bottomTrailing),
            for: .widget)
    }
}
