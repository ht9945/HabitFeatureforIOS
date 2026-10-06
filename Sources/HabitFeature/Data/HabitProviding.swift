import Foundation

public protocol HabitProviding: Sendable {
    func loadToday() async throws -> [HabitItem]
    func setDone(_ isDone: Bool, for id: HabitItem.ID) async throws
}
