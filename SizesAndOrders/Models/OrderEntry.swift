import SwiftData
import Foundation

@Model
final class OrderEntry {
    var type: String
    var freetext: String
    var createdAt: Date
    var person: Person?

    init(type: String, freetext: String, person: Person? = nil) {
        self.type = type
        self.freetext = freetext
        self.createdAt = Date()
        self.person = person
    }
}
