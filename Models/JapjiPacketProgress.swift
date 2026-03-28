import Foundation

struct JapjiPacketProgress: Codable {
    var completedIds: Set<String>
    var currentIndex: Int

    static let `default` = JapjiPacketProgress(completedIds: [], currentIndex: 0)
}
