import SwiftUI
import SwiftData

struct CardView: View {
    let person: Person
    let namespace: Namespace.ID
    let isExpanded: Bool
    let onTap: () -> Void
    @State private var didTap = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorPalette.gradient(for: person.sortOrder))
                .matchedGeometryEffect(
                    id: person.persistentModelID,
                    in: namespace
                )
                .frame(height: 120)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(person.emoji)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(person.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(person.relation)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                }

                // Allergy pills (red), date pills (blue), then recent size/order pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        let pills = person.compactPills
                        ForEach(pills.allergies, id: \.persistentModelID) { note in
                            PillView(label: note.value, style: .allergy)
                        }
                        ForEach(person.datePills, id: \.self) { label in
                            PillView(label: label, style: .date)
                        }
                        ForEach(Array(pills.recent.enumerated()), id: \.offset) { _, item in
                            PillView(label: item.pillLabel, style: .standard)
                        }
                    }
                }
            }
            .padding(16)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: didTap)
        .onTapGesture {
            didTap.toggle()
            onTap()
        }
    }
}

struct PillView: View {
    enum Style { case allergy, date, standard }
    let label: String
    let style: Style

    var body: some View {
        Text(label)
            .font(.caption2)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(pillColor)
            )
            .foregroundStyle(.white)
    }

    private var pillColor: Color {
        switch style {
        case .allergy:  return Color.red.opacity(0.85)
        case .date:     return Color.white.opacity(0.35)
        case .standard: return Color.white.opacity(0.2)
        }
    }
}
