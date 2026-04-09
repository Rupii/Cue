import SwiftUI
import Foundation

enum ColorPalette {
    // 5-color free palette, cycles by sortOrder
    static let hexValues = ["#C084FC", "#60A5FA", "#34D399", "#F97316", "#F472B6"]

    static func color(for sortOrder: Int) -> String {
        hexValues[sortOrder % hexValues.count]
    }

    static func gradient(for sortOrder: Int) -> LinearGradient {
        let hex = color(for: sortOrder)
        let base = Color(hex: hex)
        return LinearGradient(
            colors: [base.opacity(0.9), base.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

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
