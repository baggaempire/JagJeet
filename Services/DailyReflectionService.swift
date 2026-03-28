import Foundation

struct DailyReflectionService {
    func reflectionForToday(from entries: [ReflectionEntry], preferredSources: [SourceType]) -> ReflectionEntry? {
        let filtered = entries.filter { preferredSources.contains($0.sourceType) }
        guard !filtered.isEmpty else { return entries.first }

        let today = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (today - 1) % filtered.count
        return filtered.sorted(by: { $0.id < $1.id })[index]
    }
}
