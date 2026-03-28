import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel: SettingsViewModel
    @State private var saveButtonTitle = "Save Settings"
    @State private var showSavedMessage = false
    @State private var showFeedbackMessage = false
    
    private let feedbackFormURL = URL(string: "https://forms.office.com/r/9g6QfCYMZU")!

    private var language: AppLanguage {
        viewModel.selectedLanguage
    }

    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(preferences: .default))
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(spacing: 18) {
                    SectionCard(title: language.text(.languageSection)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(language.text(.chooseAppLanguage))
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)

                            Picker(language.text(.languageSection), selection: $viewModel.selectedLanguage) {
                                ForEach(AppLanguage.allCases) { language in
                                    Text(language.displayName).tag(language)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(AppTheme.accentGold)
                        }
                        .foregroundStyle(AppTheme.textPrimary)
                    }

                    SectionCard(title: language.text(.notificationsSection)) {
                        VStack(alignment: .leading, spacing: 14) {
                            Toggle(language.text(.enableReminders), isOn: $viewModel.notificationsEnabled)
                                .tint(AppTheme.accentGold)

                            Stepper(value: $viewModel.notificationsPerDay, in: 1...5) {
                                Text("\(language.text(.timesPerDay)): \(viewModel.notificationsPerDay)")
                            }
                            .onChange(of: viewModel.notificationsPerDay) { _, newValue in
                                viewModel.setNotificationCount(newValue)
                            }

                            Toggle(language.text(.useRandomTimes), isOn: $viewModel.useRandomTimes)
                                .tint(AppTheme.accentGold)

                            if !viewModel.useRandomTimes {
                                ForEach(0..<viewModel.notificationsPerDay, id: \.self) { index in
                                    DatePicker(
                                        "\(language.text(.enableReminders)) \(index + 1)",
                                        selection: bindingForNotificationTime(at: index),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .tint(AppTheme.accentGold)
                                }
                            }
                        }
                        .foregroundStyle(AppTheme.textPrimary)
                    }

                    PrimaryButton(title: saveButtonTitle) {
                        Task {
                            await saveSettingsWithFeedback()
                        }
                    }

                    CompletionStatusOverlay(visible: showSavedMessage, text: language.text(.settingsSaved))
                    CompletionStatusOverlay(visible: showFeedbackMessage, text: language.text(.openingFeedbackForm))
                    
                    SectionCard(title: language.text(.supportSection)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(language.text(.supportDescription))
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                            
                            Button {
                                showFeedbackMessage = true
                                openURL(feedbackFormURL)
                                Task {
                                    try? await Task.sleep(nanoseconds: 900_000_000)
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        showFeedbackMessage = false
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                    Text(language.text(.feedbackRequest))
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .foregroundStyle(.black)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.accentGold)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(GoldPressButtonStyle())

                            Button {
                                appViewModel.showOnboardingAgain()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                    Text(language.text(.showWelcomeAgain))
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Spacer()
                                }
                                .foregroundStyle(AppTheme.textPrimary)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.cardSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(GoldPressButtonStyle())
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(language.text(.settingsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load(from: appViewModel.preferences)
            saveButtonTitle = appViewModel.preferences.preferredLanguage.text(.saveSettings)
        }
        .onChange(of: viewModel.selectedLanguage) { _, newLanguage in
            if !showSavedMessage {
                saveButtonTitle = newLanguage.text(.saveSettings)
            }
        }
    }

    private func saveSettings() {
        appViewModel.updatePreferredLanguage(viewModel.selectedLanguage)
        appViewModel.updateNotificationFrequency(
            timesPerDay: viewModel.notificationsPerDay,
            useRandomTimes: viewModel.useRandomTimes
        )
        appViewModel.updateNotificationTimes(viewModel.notificationMinutesOfDay())
        appViewModel.setNotificationsEnabled(viewModel.notificationsEnabled)
        if !viewModel.useRandomTimes {
            appViewModel.updateNotificationTime(viewModel.notificationTime)
        }
    }

    private func saveSettingsWithFeedback() async {
        saveSettings()
        withAnimation(.easeOut(duration: 0.2)) {
            saveButtonTitle = language.text(.saved)
            showSavedMessage = true
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        withAnimation(.easeOut(duration: 0.2)) {
            saveButtonTitle = language.text(.saveSettings)
            showSavedMessage = false
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
    NavigationStack {
        SettingsView()
            .environmentObject(AppViewModel())
    }
}
