import Foundation
import SwiftUI

// MARK: - Shared data model (no SwiftData import)
// This file is compiled ONLY in the widget extension target.
// The main app has its own copy of WidgetPersonSnapshot in WidgetSnapshotWriter.swift.

struct WidgetPersonSnapshot: Codable {
    let name: String
    let emoji: String
    let relation: String
    let colorHex: String
    let topFields: [String]
    let hasAllergy: Bool
}

// MARK: - App Group reader

enum WidgetDataReader {
    static let appGroupID = "group.com.yourapp.sizesandorders"
    static let snapshotKey = "widgetSnapshot"

    static func read() -> [WidgetPersonSnapshot] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: snapshotKey),
              let snapshots = try? JSONDecoder().decode([WidgetPersonSnapshot].self, from: data)
        else { return [] }
        return snapshots
    }
}

// MARK: - Color(hex:) extension for widget (mirrors ColorPalette.swift in main app)

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
