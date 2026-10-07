import SwiftUI

public enum HabitColor: String, Codable, CaseIterable, Sendable {
    case green, orange, blue, purple, red

    public var color: Color {
        switch self {
        case .green:  Color(red: 0.031, green: 0.498, blue: 0.357)
        case .orange: Color(red: 0.761, green: 0.255, blue: 0.047)
        case .blue:   Color(red: 0.114, green: 0.373, blue: 0.820)
        case .purple: Color(red: 0.486, green: 0.227, blue: 0.929)
        case .red:    Color(red: 0.784, green: 0.118, blue: 0.302)
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
