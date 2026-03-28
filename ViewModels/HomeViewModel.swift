import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var todayDateText: String = ""

    init() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        todayDateText = formatter.string(from: Date())
    }

    func subtitle(for _: ReflectionEntry?) -> String {
        return todayDateText
    }
}
