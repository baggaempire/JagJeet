import Foundation

struct ReflectionRepository: ReflectionRepositoryProtocol {
    func fetchAllReflections(fileName: String) throws -> [ReflectionEntry] {
        let resourceName = fileName.isEmpty ? "reflections" : fileName
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            throw NSError(
                domain: "ReflectionRepository",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Missing \(resourceName).json"]
            )
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([ReflectionEntry].self, from: data)
    }
}
