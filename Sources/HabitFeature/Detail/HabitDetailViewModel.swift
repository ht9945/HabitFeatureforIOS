//
//  HabitDetailViewModel.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 7.10.2026.
//

import Foundation
import Observation

@MainActor @Observable
public final class HabitDetailViewModel {
    public private(set) var habit: HabitItem
    public private(set) var detail: HabitDetail?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let provider: any HabitProviding & HabitDetailProviding
    private let onCompleted: (HabitItem.ID) -> Void

    public init(habit: HabitItem,
                provider: any HabitProviding & HabitDetailProviding,
                onCompleted: @escaping (HabitItem.ID) -> Void = { _ in }) {
        self.habit = habit
        self.provider = provider
        self.onCompleted = onCompleted
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            detail = try await provider.loadDetail(for: habit.id)
        } catch {
            errorMessage = "Detaylar yüklenemedi."
        }
    }

    public func completeToday() async {
        guard !habit.isDone else { return }
        habit.isDone = true                 // önce ekranda göster
        habit.streak += 1
        do {
            try await provider.setDone(true, for: habit.id)
            onCompleted(habit.id)
            await load()                    // hafta şeridini tazele
        } catch {
            habit.isDone = false
            habit.streak -= 1
            errorMessage = "Değişiklik kaydedilemedi."
        }
    }
}
