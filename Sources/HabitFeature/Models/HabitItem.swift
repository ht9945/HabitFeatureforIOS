import SwiftUI
import UIKit

public enum HabitColor: String, Codable, CaseIterable, Sendable {
    case green, orange, blue, purple, red

    public var color: Color {
        switch self {
        case .green:  Color(lightHex: 0x087F5B, darkHex: 0x0E9F6E)
        case .orange: Color(lightHex: 0xC2410C, darkHex: 0xEA580C)
        case .blue:   Color(lightHex: 0x1D5FD1, darkHex: 0x3B82F6)
        case .purple: Color(lightHex: 0x7C3AED, darkHex: 0x8B5CF6)
        case .red:    Color(lightHex: 0xC81E4D, darkHex: 0xE11D48)
        }
    }

    public var title: String {
        switch self {
        case .green: "Yeşil"
        case .orange: "Turuncu"
        case .blue: "Mavi"
        case .purple: "Mor"
        case .red: "Kırmızı"
        }
    }
}

extension Color {
    /// Açık ve koyu temada farklı görünen renk.
    init(lightHex: UInt32, darkHex: UInt32) {
        self.init(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? darkHex : lightHex)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

public struct HabitItem: Identifiable, Equatable, Hashable, Codable, Sendable {
    public let id: UUID
    public var title: String
    public var subtitle: String
    public var color: HabitColor
    public var streak: Int
    public var isDone: Bool

    public init(id: UUID = UUID(), title: String, subtitle: String,
                color: HabitColor, streak: Int = 0, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.streak = streak
        self.isDone = isDone
    }
}
