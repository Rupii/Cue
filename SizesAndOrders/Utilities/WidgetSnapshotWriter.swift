import Foundation

/// Lightweight snapshot written to App Group UserDefaults for the widget to read.
/// This file has NO SwiftData import — it is shared with the widget extension target.
/// The main app converts Person → WidgetPersonSnapshot at the call site (in RootView).
struct WidgetPersonSnapshot: Codable {
    let name: String
    let emoji: String
    let relation: String
    let colorHex: String
    let topFields: [String]    // Up to 3 fields for the small widget
    let hasAllergy: Bool
}

enum WidgetSnapshotWriter {
    static let appGroupID = "group.com.yourapp.sizesandorders"
    static let snapshotKey = "widgetSnapshot"

    /// Writes snapshots to the shared App Group UserDefaults.
    /// Call on every foreground → background transition.
    static func write(snapshots: [WidgetPersonSnapshot]) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(snapshots) else { return }
        defaults.set(data, forKey: snapshotKey)
    }

    /// Called by the widget extension to read the latest snapshot.
    static func read() -> [WidgetPersonSnapshot] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: snapshotKey),
              let snapshots = try? JSONDecoder().decode([WidgetPersonSnapshot].self, from: data)
        else { return [] }
        return snapshots
    }
}
