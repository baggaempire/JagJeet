import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var homePath: [AppRoute] = []
    @State private var selectedTab: RootTab = .home

    var body: some View {
        Group {
            if appViewModel.preferences.hasCompletedOnboarding {
                TabView(selection: $selectedTab) {
                    NavigationStack(path: $homePath) {
                        HomeView(openTodayAction: openTodayReflection)
                            .navigationDestination(for: AppRoute.self) { route in
                                switch route {
                                case .todayReflection:
                                    if let entry = appViewModel.todayReflection {
                                        DailyReflectionView(entry: entry)
                                    } else {
                                        Text(appViewModel.preferences.preferredLanguage.text(.noReflectionYet))
                                            .foregroundStyle(AppTheme.textSecondary)
                                            .padding()
                                            .background(AppTheme.background)
                                    }
                                case .reflection(let id):
                                    if let entry = appViewModel.reflections.first(where: { $0.id == id }) {
                                        DailyReflectionView(entry: entry)
                                    } else if let entry = appViewModel.todayReflection {
                                        DailyReflectionView(entry: entry)
                                    } else {
                                        Text(appViewModel.preferences.preferredLanguage.text(.noReflectionYet))
                                            .foregroundStyle(AppTheme.textSecondary)
                                            .padding()
                                            .background(AppTheme.background)
                                    }
                                }
                            }
                    }
                    .tabItem {
                        Label(appViewModel.preferences.preferredLanguage.text(.homeTab), systemImage: "house.fill")
                    }
                    .tag(RootTab.home)

                    NavigationStack {
                        PacketsView()
                    }
                    .tabItem {
                        Label(appViewModel.preferences.preferredLanguage.text(.learnTab), systemImage: "square.stack.3d.up.fill")
                    }
                    .tag(RootTab.packets)

                    NavigationStack {
                        SavedDeckView()
                    }
                    .tabItem {
                        Label(appViewModel.preferences.preferredLanguage.text(.savedTab), systemImage: "bookmark.fill")
                    }
                    .tag(RootTab.saved)

                    NavigationStack {
                        SettingsView()
                    }
                    .tabItem {
                        Label(appViewModel.preferences.preferredLanguage.text(.settingsTab), systemImage: "gearshape.fill")
                    }
                    .tag(RootTab.settings)
                }
                .onChange(of: appViewModel.currentRoute) { _, newRoute in
                    guard let newRoute else { return }
                    selectedTab = .home
                    homePath = [newRoute]
                    appViewModel.clearRoute()
                }
            } else {
                OnboardingView()
            }
        }
    }

    private func openTodayReflection() {
        selectedTab = .home
        homePath.append(.todayReflection)
    }
}

private enum RootTab: Hashable {
    case home
    case packets
    case saved
    case settings
}

#Preview {
    RootView()
        .environmentObject(AppViewModel())
}
