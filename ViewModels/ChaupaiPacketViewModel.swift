import Foundation

@MainActor
final class ChaupaiPacketViewModel: ObservableObject {
    @Published var dragOffset: CGFloat = 0

    let swipeThreshold: CGFloat = 120
}
