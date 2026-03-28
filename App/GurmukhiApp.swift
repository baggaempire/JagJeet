import SwiftUI

@main
struct GurmukhiApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    appViewModel.handleIncomingDeepLink(url)
                }
        }
    }
}
