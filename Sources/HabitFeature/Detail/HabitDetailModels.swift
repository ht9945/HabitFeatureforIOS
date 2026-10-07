//
//  HabitDetailModels.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 7.10.2026.
//

import Foundation

public struct WeekDayStatus: Equatable, Sendable {
    public let label: String
    public let isDone: Bool

    public init(label: String, isDone: Bool) {
        self.label = label
        self.isDone = isDone
    }
}

public struct HabitDetail: Equatable, Sendable {
    public let bestStreak: Int
    public let totalDays: Int
    public let week: [WeekDayStatus]

    public init(bestStreak: Int, totalDays: Int, week: [WeekDayStatus]) {
        self.bestStreak = bestStreak
        self.totalDays = totalDays
        self.week = week
    }
}
