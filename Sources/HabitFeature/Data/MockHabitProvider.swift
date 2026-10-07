//
//  MockHabitProvider.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
// önizleme ve ilk denemeler için

import Foundation

public struct MockHabitProvider: HabitProviding {
    private let habits: [HabitItem]

    public init(habits: [HabitItem] = MockHabitProvider.samples) {
        self.habits = habits
    }

    public func loadToday() async throws -> [HabitItem] { habits }
    public func setDone(_ isDone: Bool, for id: HabitItem.ID) async throws {}
    
    public func add(_ draft: HabitDraft) async throws -> HabitItem {
        HabitItem(
            title: draft.name.trimmingCharacters(in: .whitespaces),
            subtitle: "\(draft.goal) \(draft.goalUnit)".trimmingCharacters(in: .whitespaces),
            color: draft.color
        )
    }

    public static let samples: [HabitItem] = [
        HabitItem(title: "Su iç", subtitle: "8 bardak", color: .green, streak: 12, isDone: true),
        HabitItem(title: "Kitap oku", subtitle: "20 sayfa", color: .orange, streak: 12, isDone: true),
        HabitItem(title: "Yürüyüş", subtitle: "30 dakika", color: .blue, streak: 5),
        HabitItem(title: "Meditasyon", subtitle: "10 dakika", color: .purple, streak: 5)
    ]

}


extension MockHabitProvider: StatsProviding {
    public func loadStats(for range: StatsRange) async throws -> StatsSnapshot {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let weekPattern: [Double] = [1, 0.75, 1, 0.5, 1, 0.75, 0.5]
        let yearPattern: [Double] = [0.55, 0.62, 0.7, 0.66, 0.8, 0.74]
        
        let points: [CompletionPoint]
        switch range {
        case .week, .month:
            let count = range == .week ? 7 : 30
            points = (0..<count).reversed().map { offset in
                let date = cal.date(byAdding: .day, value: -offset, to: today) ?? today
                return CompletionPoint(date: date,
                                       ratio: weekPattern[(count - 1 - offset) % weekPattern.count])
            }
        case .year:
            let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: today)) ?? today
            points = (0..<12).reversed().map { offset in
                let date = cal.date(byAdding: .month, value: -offset, to: monthStart) ?? monthStart
                return CompletionPoint(date: date,
                                       ratio: yearPattern[(11 - offset) % yearPattern.count])
            }
        }
        
        let ratios: [Double] = [0.92, 0.78, 0.54, 0.41]
        let perHabit = habits.enumerated().map { index, habit in
            HabitCompletion(id: habit.id, title: habit.title, color: habit.color,
                            ratio: ratios[index % ratios.count])
        }
        
        return StatsSnapshot(
            completionRate: points.map(\.ratio).reduce(0, +) / Double(points.count),
            bestStreak: 12,
            perfectDays: points.filter { $0.ratio >= 1 }.count,
            points: points,
            habits: perHabit
        )
    }
}
