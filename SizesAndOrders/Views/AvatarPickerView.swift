import SwiftUI

struct AvatarOption: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
}

enum AvatarPickerView {
    static let sections: [(title: String, options: [AvatarOption])] = [
        ("Family", [
            AvatarOption(emoji: "👩", label: "Partner"),
            AvatarOption(emoji: "👨", label: "Dad"),
            AvatarOption(emoji: "👩‍🦳", label: "Mom"),
            AvatarOption(emoji: "👴", label: "Grandpa"),
            AvatarOption(emoji: "👵", label: "Grandma"),
            AvatarOption(emoji: "👧", label: "Daughter"),
            AvatarOption(emoji: "👦", label: "Son"),
            AvatarOption(emoji: "👶", label: "Baby"),
            AvatarOption(emoji: "🧑", label: "Sibling"),
            AvatarOption(emoji: "👨‍👩‍👧", label: "Family"),
        ]),
        ("Friends", [
            AvatarOption(emoji: "🧑‍🤝‍🧑", label: "Best friend"),
            AvatarOption(emoji: "👱", label: "Buddy"),
            AvatarOption(emoji: "🧔", label: "Mate"),
            AvatarOption(emoji: "👩‍🦱", label: "Bestie"),
            AvatarOption(emoji: "🧑‍💼", label: "Colleague"),
            AvatarOption(emoji: "🏃", label: "Gym pal"),
            AvatarOption(emoji: "🧑‍🎓", label: "Classmate"),
            AvatarOption(emoji: "🧑‍🍳", label: "Foodie"),
        ]),
        ("Other", [
            AvatarOption(emoji: "⭐️", label: "VIP"),
            AvatarOption(emoji: "🐶", label: "Dog"),
            AvatarOption(emoji: "🐱", label: "Cat"),
            AvatarOption(emoji: "🐾", label: "Pet"),
            AvatarOption(emoji: "👤", label: "Other"),
        ]),
    ]
}

struct AvatarPickerSheet: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss

    private var circleGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#C084FC").opacity(0.85), Color(hex: "#818CF8").opacity(0.7)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(AvatarPickerView.sections, id: \.title) { section in
                        sectionView(section)
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func sectionView(_ section: (title: String, options: [AvatarOption])) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5),
                spacing: 14
            ) {
                ForEach(section.options) { option in
                    avatarCell(option)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func avatarCell(_ option: AvatarOption) -> some View {
        let isSelected = selectedEmoji == option.emoji
        return Button {
            selectedEmoji = option.emoji
            dismiss()
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(circleGradient)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle().strokeBorder(
                                isSelected ? Color.white : Color.clear,
                                lineWidth: 2.5
                            )
                        )
                        .shadow(color: isSelected ? Color.white.opacity(0.4) : Color.clear, radius: 6)
                    Text(option.emoji)
                        .font(.title3)
                }
                Text(option.label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.2), value: selectedEmoji)
    }
}
