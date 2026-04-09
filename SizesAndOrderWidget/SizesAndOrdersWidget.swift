import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct VaultEntry: TimelineEntry {
    let date: Date
    let persons: [WidgetPersonSnapshot]
}

// MARK: - Timeline Provider

struct VaultProvider: TimelineProvider {
    func placeholder(in context: Context) -> VaultEntry {
        VaultEntry(date: Date(), persons: [
            WidgetPersonSnapshot(
                name: "Sarah", emoji: "👩", relation: "Partner",
                colorHex: "#C084FC",
                topFields: ["Shoe size: 7.5 (US)", "Ring size: 6.5"],
                hasAllergy: true)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (VaultEntry) -> Void) {
        completion(VaultEntry(date: Date(), persons: WidgetDataReader.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VaultEntry>) -> Void) {
        let entry = VaultEntry(date: Date(), persons: WidgetDataReader.read())
        // Main app calls reloadTimelines on background; 15-min fallback for safety
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}

// MARK: - Widget Definition

struct SizesAndOrdersWidget: Widget {
    let kind: String = "VaultWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaultProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Sizes & Orders")
        .description("Quick-glance your most important person.")
        .supportedFamilies([.systemSmall])
    }
}
