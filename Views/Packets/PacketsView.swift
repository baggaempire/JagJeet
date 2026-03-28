import SwiftUI

struct PacketsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(spacing: 18) {
                    packetCard(
                        title: "Chaupai Sahib \(language.text(.pathLabel))",
                        subtitle: language.text(.chaupaiPathSubtitle),
                        progress: "\(appViewModel.chaupaiCompletedCount) / \(appViewModel.chaupaiTotalCount)",
                        actionTitle: chaupaiActionTitle
                    ) {
                        ChaupaiPacketView()
                    }

                    packetCard(
                        title: "Japji Sahib \(language.text(.pathLabel))",
                        subtitle: language.text(.japjiPathSubtitle),
                        progress: "\(appViewModel.japjiCompletedCount) / \(appViewModel.japjiTotalCount)",
                        actionTitle: japjiActionTitle
                    ) {
                        JapjiPacketView()
                    }
                }
                .padding(20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var language: AppLanguage {
        appViewModel.preferences.preferredLanguage
    }

    private func packetCard<Destination: View>(
        title: String,
        subtitle: String,
        progress: String,
        actionTitle: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        SectionCard(title: title) {
            VStack(alignment: .leading, spacing: 12) {
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                Text("\(language.text(.progress)): \(progress)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                NavigationLink(destination: destination) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.accentGold)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(GoldPressButtonStyle())
            }
        }
    }

    private var chaupaiActionTitle: String {
        if appViewModel.chaupaiTotalCount > 0, appViewModel.chaupaiCompletedCount >= appViewModel.chaupaiTotalCount {
            return language.text(.beginChaupaiAgain)
        }
        return appViewModel.chaupaiCompletedCount == 0 ? language.text(.startChaupaiPath) : language.text(.resumeChaupaiPath)
    }

    private var japjiActionTitle: String {
        if appViewModel.japjiTotalCount > 0, appViewModel.japjiCompletedCount >= appViewModel.japjiTotalCount {
            return language.text(.beginJapjiAgain)
        }
        return appViewModel.japjiCompletedCount == 0 ? language.text(.startJapjiPath) : language.text(.resumeJapjiPath)
    }
}

#Preview {
    NavigationStack {
        PacketsView()
            .environmentObject(AppViewModel())
    }
}
