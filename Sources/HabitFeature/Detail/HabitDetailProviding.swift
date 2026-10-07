//
//  HabitDetailProviding.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 7.10.2026.
//

import Foundation

public protocol HabitDetailProviding: Sendable {
    func loadDetail(for id: HabitItem.ID) async throws -> HabitDetail
}
