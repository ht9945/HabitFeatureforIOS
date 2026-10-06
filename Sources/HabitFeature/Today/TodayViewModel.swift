//
//  TodayViewModel.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
//
import Foundation
import Observation

@MainActor @Observable
public final class TodayViewModel {
    public private(set) var habits: [HabitItem] = []
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let provider: HabitProviding

    public init(provider: HabitProviding) {
        self.provider = provider
    }

    public var completedCount: Int { habits.filter(\.isDone).count }
    public var progress: Double {
        habits.isEmpty ? 0 : Double(completedCount) / Double(habits.count)
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            habits = try await provider.loadToday()
        } catch {
            errorMessage = "Alışkanlıklar yüklenemedi."
        }
    }

    public func toggle(_ id: HabitItem.ID) async {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        let newValue = !habits[index].isDone
        habits[index].isDone = newValue          // önce ekranda göster

        do {
            try await provider.setDone(newValue, for: id)
        } catch {
            // Kayıt başarısızsa geri al (indeks değişmiş olabilir, yeniden bul)
            if let i = habits.firstIndex(where: { $0.id == id }) {
                habits[i].isDone = !newValue
            }
            errorMessage = "Değişiklik kaydedilemedi."
        }
    }
}
