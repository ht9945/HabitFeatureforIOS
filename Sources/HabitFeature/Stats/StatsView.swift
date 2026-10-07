//
//  StatsView.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
//

import SwiftUI
import Charts
import DesignKitForIOS

public struct StatsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var viewModel: StatsViewModel

    public init(viewModel: StatsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var vm = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("İstatistik")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.textPrimary)

                Picker("Dönem", selection: $vm.range) {
                    ForEach(StatsRange.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 360)

                if let snapshot = vm.snapshot {
                    tiles(snapshot)
                    if sizeClass == .regular {
                        HStack(alignment: .top, spacing: 12) {
                            chartCard(snapshot, range: vm.range)
                            habitsCard(snapshot)
                        }
                    } else {
                        chartCard(snapshot, range: vm.range)
                        habitsCard(snapshot)
                    }
                } else if vm.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 60)
                }
            }
            .padding(20)
        }
        .background(theme.background.ignoresSafeArea())
        .task(id: vm.range) { await vm.load() }
        .alert("Hata", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Parçalar

    private func tiles(_ s: StatsSnapshot) -> some View {
        HStack(spacing: 12) {
            StatCard(value: "%\(Int((s.completionRate * 100).rounded()))", label: "tamamlama")
            StatCard(value: "\(s.bestStreak)", label: "en iyi seri")
            StatCard(value: "\(s.perfectDays)", label: "tam gün")
        }
    }

    private func chartCard(_ s: StatsSnapshot, range: StatsRange) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Günlük tamamlama")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(theme.textPrimary)

            Chart(s.points) { point in
                BarMark(
                    x: .value("Tarih", point.date, unit: range.unit),
                    y: .value("Tamamlama", point.ratio)
                )
                .foregroundStyle(point.ratio >= 1 ? theme.accent : theme.accent.opacity(0.5))
                .cornerRadius(6)
            }
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(values: [0, 0.5, 1]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let d = value.as(Double.self) {
                            Text("%\(Int(d * 100))")
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: range.unit, count: range.axisStride)) { _ in
                    AxisValueLabel(format: range.axisFormat)
                }
            }
            .frame(height: 170)
            .accessibilityLabel("Günlük tamamlama grafiği")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .card()
    }

    private func habitsCard(_ s: StatsSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Alışkanlıklara göre")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(theme.textPrimary)

            ForEach(s.habits) { habit in
                HStack(spacing: 12) {
                    Text(habit.title)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(theme.textPrimary)
                        .frame(width: 96, alignment: .leading)
                        .lineLimit(1)

                    Capsule()
                        .fill(theme.track)
                        .frame(height: 10)
                        .overlay(alignment: .leading) {
                            GeometryReader { proxy in
                                Capsule()
                                    .fill(habit.color.color)
                                    .frame(width: proxy.size.width * habit.ratio)
                            }
                        }

                    Text("%\(Int((habit.ratio * 100).rounded()))")
                        .font(.system(.subheadline, design: .rounded).weight(.heavy))
                        .monospacedDigit()
                        .foregroundStyle(theme.textPrimary)
                        .frame(width: 44, alignment: .trailing)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .card()
    }
}

#Preview {
    StatsView(viewModel: StatsViewModel(provider: MockHabitProvider()))
}
