import SwiftData
import Foundation

@Model
final class Person {
    var name: String
    var emoji: String
    var relation: String
    var colorHex: String
    var sortOrder: Int
    @Relationship(deleteRule: .cascade) var sizes: [SizeEntry] = []
    @Relationship(deleteRule: .cascade) var orders: [OrderEntry] = []
    @Relationship(deleteRule: .cascade) var notes: [NoteEntry] = []

    // TODO: add VersionedSchema before v2

    init(name: String, emoji: String, relation: String,
         colorHex: String, sortOrder: Int) {
        self.name = name
        self.emoji = emoji
        self.relation = relation
        self.colorHex = colorHex
        self.sortOrder = sortOrder
    }

    /// Chip pills for compact card: allergy notes first (red), then 4 most recent
    /// size/order entries combined, sorted by createdAt descending.
    var compactPills: (allergies: [NoteEntry], recent: [SizeEntry_or_OrderEntry]) {
        let allergies = notes.filter { $0.isAllergy }
        // Combine sizes and orders, sort by createdAt descending, take top 4
        let sizeItems = sizes.map { SizeEntry_or_OrderEntry.size($0) }
        let orderItems = orders.map { SizeEntry_or_OrderEntry.order($0) }
        let combined = (sizeItems + orderItems).sorted {
            $0.createdAt > $1.createdAt
        }.prefix(4)
        return (allergies, Array(combined))
    }

    static func insertSeedData(into context: ModelContext) {
        let partner = Person(name: "Sarah", emoji: "👩", relation: "Partner",
                             colorHex: "#C084FC", sortOrder: 0)
        let mom = Person(name: "Mom", emoji: "👩‍🦳", relation: "Mom",
                         colorHex: "#60A5FA", sortOrder: 1)
        let friend = Person(name: "Jake", emoji: "🧑", relation: "Friend",
                            colorHex: "#34D399", sortOrder: 2)
        let dad = Person(name: "Dad", emoji: "👨", relation: "Dad",
                         colorHex: "#F97316", sortOrder: 3)

        let sarahShoe = SizeEntry(category: "Shoes", label: "Shoe size",
                                  value: "7.5 (US)", person: partner)
        let sarahRing = SizeEntry(category: "Ring", label: "Ring size",
                                  value: "6.5", person: partner)
        let sarahCoffee = OrderEntry(type: "Coffee",
                                     freetext: "Oat milk latte, extra shot, no sugar",
                                     person: partner)
        let sarahAllergy = NoteEntry(key: "Allergy", value: "Tree nuts",
                                     isAllergy: true, person: partner)

        let momShirt = SizeEntry(category: "Clothing", label: "Shirt size",
                                 value: "M (AU 12)", person: mom)
        let momCoffee = OrderEntry(type: "Coffee",
                                   freetext: "Flat white, full cream",
                                   person: mom)

        let jakeCoffee = OrderEntry(type: "Coffee",
                                    freetext: "Long black, two sugars",
                                    person: friend)
        let jakeShoe = SizeEntry(category: "Shoes", label: "Shoe size",
                                 value: "10 (US)", person: friend)

        let dadShirt = SizeEntry(category: "Clothing", label: "Shirt size",
                                 value: "XL", person: dad)

        for item in [partner, mom, friend, dad,
                     sarahShoe, sarahRing, sarahCoffee, sarahAllergy,
                     momShirt, momCoffee, jakeCoffee, jakeShoe, dadShirt] as [any PersistentModel] {
            context.insert(item)
        }
    }
}

// Helper enum to unify SizeEntry and OrderEntry for sorting
enum SizeEntry_or_OrderEntry {
    case size(SizeEntry)
    case order(OrderEntry)

    var createdAt: Date {
        switch self {
        case .size(let s): return s.createdAt
        case .order(let o): return o.createdAt
        }
    }

    var pillLabel: String {
        switch self {
        case .size(let s): return "\(s.label): \(s.value)"
        case .order(let o): return "\(o.type): \(o.freetext)"
        }
    }
}
