//
//  StatsProviding.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
//

import Foundation

public protocol StatsProviding: Sendable {
    func loadStats(for range: StatsRange) async throws -> StatsSnapshot
}
