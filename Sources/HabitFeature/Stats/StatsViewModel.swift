//
//  StatsViewModel.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
//

import Foundation
import Observation

@MainActor @Observable
public final class StatsViewModel {
    public var range: StatsRange = .week
    public private(set) var snapshot: StatsSnapshot?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let provider: StatsProviding

    public init(provider: StatsProviding) {
        self.provider = provider
    }

    public func load() async {
        let requested = range
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await provider.loadStats(for: requested)
            // Kullanıcı bu arada başka döneme geçtiyse eski cevabı yok say
            guard requested == range else { return }
            snapshot = result
        } catch {
            errorMessage = "İstatistikler yüklenemedi."
        }
    }
}
