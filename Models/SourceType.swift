import Foundation

enum SourceType: String, Codable, CaseIterable, Identifiable {
    case jaapSahib = "jaap_sahib"
    case rehrasSahib = "rehras_sahib"
    case chaupaiSahib = "chaupai_sahib"
    case sukhmaniSahib = "sukhmani_sahib"
    case hukamnama = "hukamnama"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .jaapSahib: return "Jaap Sahib"
        case .rehrasSahib: return "Rehras Sahib"
        case .chaupaiSahib: return "Chaupai Sahib"
        case .sukhmaniSahib: return "Sukhmani Sahib"
        case .hukamnama: return "Daily Hukamnama"
        }
    }
}
