import SwiftData
import Foundation

@Model
final class SizeEntry {
    var category: String
    var label: String
    var value: String
    var createdAt: Date
    var person: Person?

    init(category: String, label: String, value: String, person: Person? = nil) {
        self.category = category
        self.label = label
        self.value = value
        self.createdAt = Date()
        self.person = person
    }
}
