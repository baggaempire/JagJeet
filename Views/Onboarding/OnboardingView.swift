import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var isSaving = false
    private let notificationOptions = [1, 2, 3, 4]

    private var language: AppLanguage {
        viewModel.selectedLanguage
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(spacing: 16) {
                        Text(language.text(.onboardingTitle))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(language.text(.onboardingMessage))
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.top, 56)

                    VStack(spacing: 14) {
                        Text(language.text(.chooseYourLanguage))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Picker("Language", selection: $viewModel.selectedLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(AppTheme.accentGold)

                        Text(language.text(.howOftenNotified))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Picker("Notifications per day", selection: $viewModel.notificationsPerDay) {
                            ForEach(notificationOptions, id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(AppTheme.accentGold)
                        .onChange(of: viewModel.notificationsPerDay) { _, newValue in
                            viewModel.setNotificationCount(newValue)
                        }

                        Toggle(language.text(.useRandomTimes), isOn: $viewModel.useRandomTimes)
                            .tint(AppTheme.accentGold)

                        if !viewModel.useRandomTimes {
                            ForEach(0..<viewModel.notificationsPerDay, id: \.self) { index in
                                DatePicker(
                                    "\(language.text(.reminder)) \(index + 1)",
                                    selection: bindingForNotificationTime(at: index),
                                    displayedComponents: .hourAndMinute
                                )
                                .tint(AppTheme.accentGold)
                            }
                        }

                        Text(language.text(.canChangeInSettings))
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .background(AppTheme.cardBackground.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.cardSecondary, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)

                    PrimaryButton(title: isSaving ? language.text(.settingUp) : language.text(.getStarted)) {
                        Task {
                            isSaving = true
                            let defaultTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
                            await appViewModel.completeOnboarding(
                                selectedSources: SourceType.allCases,
                                notificationDate: viewModel.notificationTimes.first ?? defaultTime,
                                notificationsEnabled: true,
                                preferredLanguage: viewModel.selectedLanguage,
                                notificationTimesPerDay: viewModel.notificationsPerDay,
                                useRandomTimes: viewModel.useRandomTimes,
                                fixedMinutesOfDay: viewModel.useRandomTimes ? [] : viewModel.notificationMinutesOfDay()
                            )
                            isSaving = false
                        }
                    }
                    .disabled(!viewModel.canContinue || isSaving)
                    .opacity((!viewModel.canContinue || isSaving) ? 0.55 : 1)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func bindingForNotificationTime(at index: Int) -> Binding<Date> {
        Binding(
            get: {
                guard viewModel.notificationTimes.indices.contains(index) else {
                    return viewModel.notificationTime
                }
                return viewModel.notificationTimes[index]
            },
            set: { newValue in
                guard viewModel.notificationTimes.indices.contains(index) else { return }
                viewModel.notificationTimes[index] = newValue
                if index == 0 {
                    viewModel.notificationTime = newValue
                }
            }
        )
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
}
