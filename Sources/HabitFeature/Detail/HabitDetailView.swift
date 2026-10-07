//
//  Untitled.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 7.10.2026.
//

import SwiftUI
import DesignKitForIOS

public struct HabitDetailView: View {
    @Environment(\.theme) private var theme
    @State private var viewModel: HabitDetailViewModel

    public init(viewModel: HabitDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        let habit = viewModel.habit

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                    Text(habit.subtitle)
                        .font(.body)
                        .foregroundStyle(theme.textSecondary)
                }

                streakCard(habit)

                if let detail = viewModel.detail {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Bu hafta")
                            .font(.system(.headline, design: .rounded).weight(.heavy))
                            .foregroundStyle(theme.textPrimary)
                        WeekStrip(days: detail.week.map {
                            WeekStrip.Day(label: $0.label, isDone: $0.isDone)
                        })
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .card()

                    HStack(spacing: 12) {
                        StatCard(value: "\(detail.bestStreak)", label: "en uzun seri")
                        StatCard(value: "\(detail.totalDays)", label: "toplam gün")
                    }
                } else if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 24)
                }
            }
            .padding(20)
        }
        .background(theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Button(habit.isDone ? "Bugün tamamlandı" : "Bugünü tamamla") {
                Task { await viewModel.completeToday() }
            }
            .buttonStyle(.primary)
            .disabled(habit.isDone)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(theme.background)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .alert("Hata", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func streakCard(_ habit: HabitItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(habit.streak)")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .monospacedDigit()
            Text("günlük seri")
                .font(.headline)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(habit.color.color, in: RoundedRectangle(cornerRadius: 28))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(viewModel: HabitDetailViewModel(
            habit: MockHabitProvider.samples[2],
            provider: MockHabitProvider()
        ))
    }
}
