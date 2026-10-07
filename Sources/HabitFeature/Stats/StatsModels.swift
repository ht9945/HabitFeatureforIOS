//
//  StatsModels.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
//

import Foundation

public enum StatsRange: String, CaseIterable, Identifiable, Sendable {
    case week, month, year

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .week: "Hafta"
        case .month: "Ay"
        case .year: "Yıl"
        }
    }

    // Grafik ekseni ayarları (modül içinde kullanılır)
    var unit: Calendar.Component {
        switch self {
        case .week, .month: .day
        case .year: .month
        }
    }

    var axisStride: Int {
        switch self {
        case .week: 1
        case .month: 7
        case .year: 1
        }
    }

    var axisFormat: Date.FormatStyle {
        switch self {
        case .week: Date.FormatStyle().weekday(.abbreviated)
        case .month: Date.FormatStyle().day()
        case .year: Date.FormatStyle().month(.narrow)
        }
    }
}

public struct CompletionPoint: Identifiable, Equatable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let ratio: Double          // 0...1

    public init(date: Date, ratio: Double) {
        self.date = date
        self.ratio = ratio
    }
}

public struct HabitCompletion: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let color: HabitColor
    public let ratio: Double          // 0...1

    public init(id: UUID, title: String, color: HabitColor, ratio: Double) {
        self.id = id
        self.title = title
        self.color = color
        self.ratio = ratio
    }
}

public struct StatsSnapshot: Equatable, Sendable {
    public let completionRate: Double
    public let bestStreak: Int
    public let perfectDays: Int
    public let points: [CompletionPoint]
    public let habits: [HabitCompletion]

    public init(completionRate: Double, bestStreak: Int, perfectDays: Int,
                points: [CompletionPoint], habits: [HabitCompletion]) {
        self.completionRate = completionRate
        self.bestStreak = bestStreak
        self.perfectDays = perfectDays
        self.points = points
        self.habits = habits
    }
}
