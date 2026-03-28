import Foundation

protocol ReflectionRepositoryProtocol {
    func fetchAllReflections(fileName: String) throws -> [ReflectionEntry]
}
