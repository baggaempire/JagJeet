import Foundation

struct ReflectionEntry: Codable, Identifiable, Hashable {
    let id: String
    let sourceType: SourceType
    let title: String
    let dayIndex: Int?
    let date: String?
    let gurmukhiText: String
    let englishMeaning: String
    let simpleExplanation: String
    let lifeReflection: String
    let isFeatured: Bool
    let audioFileName: String?
    let tags: [String]?
}
