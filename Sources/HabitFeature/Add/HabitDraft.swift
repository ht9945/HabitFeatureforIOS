//
//  HabitDraft.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
//

import Foundation

public struct HabitDraft: Equatable, Sendable {
    public enum Recurrence: String, CaseIterable, Hashable, Sendable {
        case daily, selectedDays

        public var title: String {
            switch self {
            case .daily: "Her gün"
            case .selectedDays: "Seçili günler"
            }
        }
    }

    public var name = ""
    public var color: HabitColor = .green
    public var recurrence: Recurrence = .daily
    public var days: Set<Int> = [0, 1, 2, 3, 4]      // 0 = Pazartesi
    public var goal = 20
    public var goalUnit = "sayfa"
    public var reminderEnabled = false
    public var reminderTime = Calendar.current.date(
        bySettingHour: 21, minute: 0, second: 0, of: .now
    ) ?? .now

    public init() {}

    public var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && (recurrence == .daily || !days.isEmpty)
    }
}
