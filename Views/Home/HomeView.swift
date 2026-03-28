import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = HomeViewModel()

    let openTodayAction: () -> Void
    private let largeCardHeight = max(260, min(360, UIScreen.main.bounds.height * 0.34))

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    todayWisdomSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(homeTitle)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(2)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .allowsTightening(true)

            Text(homeIntroLine)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.accentGold.opacity(0.95))

            Text(viewModel.subtitle(for: appViewModel.todayReflection))
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.horizontal, 2)
    }

    private var homeTitle: String {
        switch appViewModel.preferences.preferredLanguage {
        case .english:
            return "Today's Wisdom"
        case .hindi:
            return "आज का ज्ञान"
        case .punjabi:
            return "ਅੱਜ ਦਾ ਗਿਆਨ"
        }
    }

    private var homeIntroLine: String {
        switch appViewModel.preferences.preferredLanguage {
        case .english:
            return "Take a moment."
        case .hindi:
            return "एक पल रुकिए."
        case .punjabi:
            return "ਇੱਕ ਪਲ ਰੁਕੋ."
        }
    }

    private var todayWisdomSection: some View {
        SectionCard(title: "") {
            VStack(alignment: .leading, spacing: 18) {
                if let entry = appViewModel.todayReflection {
                    Text(appViewModel.preferences.preferredLanguage.text(.featuredVerse))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.accentGold)
                        .textCase(.uppercase)

                    Button {
                        openTodayAction()
                    } label: {
                        ReflectionPreviewCard(entry: entry, height: largeCardHeight)
                    }
                    .buttonStyle(GoldPressButtonStyle())

                    PrimaryButton(title: appViewModel.preferences.preferredLanguage.text(.openTodaysReflection)) {
                        openTodayAction()
                    }
                } else {
                    Text(appViewModel.preferences.preferredLanguage.text(.noReflectionAvailable))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
}

private struct ReflectionPreviewCard: View {
    let entry: ReflectionEntry
    let height: CGFloat

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(entry.gurmukhiText)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.65)
                    .allowsTightening(true)
                    .fixedSize(horizontal: false, vertical: true)

                Text(entry.englishMeaning)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        HomeView(openTodayAction: {})
            .environmentObject(AppViewModel())
    }
}
