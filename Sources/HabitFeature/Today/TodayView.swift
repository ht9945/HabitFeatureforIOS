import SwiftUI
import DesignKitForIOS

public struct TodayView: View {
    @Environment(\.theme) private var theme
    @State private var viewModel: TodayViewModel
    private let onAdd: () -> Void

    public init(viewModel: TodayViewModel, onAdd: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: viewModel)
        self.onAdd = onAdd
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if viewModel.habits.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    summaryCard
                    VStack(spacing: 10) {
                        ForEach(viewModel.habits) { habit in
                            HabitRow(
                                title: habit.title,
                                subtitle: habit.subtitle,
                                color: habit.color.color,
                                trailingText: habit.streak > 0 ? "\(habit.streak) gün" : nil,
                                isDone: Binding(
                                    get: { habit.isDone },
                                    set: { _ in Task { await viewModel.toggle(habit.id) } }
                                )
                            )
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(theme.background.ignoresSafeArea())
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

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date.now.formatted(.dateTime.day().month(.wide).weekday(.wide)))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(theme.textSecondary)
                Text("Bugün")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
            }
            Spacer()
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(theme.accent, in: Circle())
            }
            .accessibilityLabel("Alışkanlık ekle")
        }
    }
    

    private var summaryCard: some View {
        HStack(spacing: 18) {
            ProgressRing(progress: viewModel.progress, lineWidth: 10,
                         foreground: .white, track: .white.opacity(0.28))
                .frame(width: 84, height: 84)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.completedCount) / \(viewModel.habits.count)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                Text("alışkanlık tamamlandı")
                    .font(.callout.weight(.medium))
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(20)
        .background(theme.accent, in: RoundedRectangle(cornerRadius: 28))
        .accessibilityElement(children: .combine)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Henüz alışkanlığın yok", systemImage: "leaf")
        } description: {
            Text("İlk alışkanlığını ekle ve her gün küçük bir adım at.")
        } actions: {
            Button("Alışkanlık ekle", action: onAdd)
                .buttonStyle(.primary)
        }
        .padding(.top, 40)
    }
}

#Preview("Dolu") {
    TodayView(viewModel: TodayViewModel(provider: MockHabitProvider()))
}

#Preview("Boş") {
    TodayView(viewModel: TodayViewModel(provider: MockHabitProvider(habits: [])))
}
