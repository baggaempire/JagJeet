import Foundation

struct ReflectionPage: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

@MainActor
final class ReflectionViewModel: ObservableObject {
    @Published var selectedPageIndex: Int = 0
    let pages: [ReflectionPage]

    init(entry: ReflectionEntry) {
        self.pages = [
            ReflectionPage(title: "Gurmukhi Verse", content: entry.gurmukhiText),
            ReflectionPage(title: "English Meaning", content: entry.englishMeaning),
            ReflectionPage(title: "Simple Explanation", content: entry.simpleExplanation),
            ReflectionPage(title: "Reflection For Today", content: entry.lifeReflection)
        ]
    }
}
