import Foundation

struct ChaupaiPacketProgress: Codable {
    var completedIds: Set<String>
    var currentIndex: Int

    static let `default` = ChaupaiPacketProgress(completedIds: [], currentIndex: 0)
}
