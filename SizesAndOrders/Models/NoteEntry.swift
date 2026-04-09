import SwiftData
import Foundation

@Model
final class NoteEntry {
    var key: String
    var value: String
    var isAllergy: Bool
    var createdAt: Date
    var person: Person?

    init(key: String, value: String, isAllergy: Bool = false, person: Person? = nil) {
        self.key = key
        self.value = value
        self.isAllergy = isAllergy
        self.createdAt = Date()
        self.person = person
    }
}
