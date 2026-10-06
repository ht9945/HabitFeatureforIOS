//
//  AddHabitViewModel.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
//

import Foundation
import Observation

@MainActor @Observable
public final class AddHabitViewModel {
    public var draft = HabitDraft()
    public private(set) var isSaving = false
    public var errorMessage: String?

    private let provider: HabitProviding
    private let onSaved: (HabitItem) -> Void

    public init(provider: HabitProviding, onSaved: @escaping (HabitItem) -> Void = { _ in }) {
        self.provider = provider
        self.onSaved = onSaved
    }

    /// Başarılıysa true döner.
    public func save() async -> Bool {
        guard draft.isValid, !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }
        do {
            let item = try await provider.add(draft)
            onSaved(item)
            return true
        } catch {
            errorMessage = "Alışkanlık kaydedilemedi."
            return false
        }
    }
}
