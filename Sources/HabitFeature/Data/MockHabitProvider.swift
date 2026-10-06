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
