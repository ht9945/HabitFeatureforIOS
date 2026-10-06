//
//  AddHabitView.swift
//  HabitFeature
//
//  Created by Hasan Tüven on 6.10.2026.
//

import SwiftUI
import DesignKitForIOS

public struct AddHabitView: View {
    @Environment(\.theme) private var theme
    @State private var viewModel: AddHabitViewModel
    private let onClose: () -> Void

    public init(viewModel: AddHabitViewModel, onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onClose = onClose
    }

    public var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section("Ad") {
                        TextField("Örn. Kitap oku", text: $vm.draft.name)
                            .font(.system(.headline, design: .rounded))
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(theme.card, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(theme.textSecondary.opacity(0.3), lineWidth: 1.5)
                            )
                    }

                    section("Renk") {
                        ColorSwatchPicker(
                            swatches: HabitColor.allCases.map {
                                Swatch(id: $0.rawValue, name: $0.title, color: $0.color)
                            },
                            selection: Binding(
                                get: { vm.draft.color.rawValue },
                                set: { vm.draft.color = HabitColor(rawValue: $0) ?? .green }
                            )
                        )
                    }

                    section("Tekrar") {
                        Picker("Tekrar", selection: $vm.draft.recurrence) {
                            ForEach(HabitDraft.Recurrence.allCases, id: \.self) {
                                Text($0.title).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)

                        if vm.draft.recurrence == .selectedDays {
                            DaySelector(selection: $vm.draft.days)
                                .padding(.top, 4)
                        }
                    }

                    section("Hedef") {
                        CounterStepper(title: "Günlük hedef", unit: vm.draft.goalUnit,
                                       value: $vm.draft.goal)
                        TextField("Birim (örn. sayfa)", text: $vm.draft.goalUnit)
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .background(theme.card, in: RoundedRectangle(cornerRadius: 14))
                    }

                    VStack(spacing: 12) {
                        Toggle("Hatırlatıcı", isOn: $vm.draft.reminderEnabled)
                            .font(.system(.headline, design: .rounded))
                            .tint(theme.accent)
                        if vm.draft.reminderEnabled {
                            DatePicker("Saat", selection: $vm.draft.reminderTime,
                                       displayedComponents: .hourAndMinute)
                        }
                    }
                    .padding(16)
                    .card()
                }
                .padding(20)
            }

            Button(vm.isSaving ? "Kaydediliyor…" : "Kaydet") {
                Task { if await vm.save() { onClose() } }
            }
            .buttonStyle(.primary)
            .disabled(!vm.draft.isValid || vm.isSaving)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(theme.background.ignoresSafeArea())
        .alert("Hata", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(theme.card, in: Circle())
            }
            .accessibilityLabel("Kapat")
            Spacer()
            Text("Yeni alışkanlık")
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func section<Content: View>(
        _ title: String, @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(theme.textSecondary)
            content()
        }
    }
}

#Preview {
    AddHabitView(viewModel: AddHabitViewModel(provider: MockHabitProvider()), onClose: {})
}
