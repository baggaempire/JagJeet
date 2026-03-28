import SwiftUI
import UIKit

struct AppGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.11, green: 0.14, blue: 0.21),
                AppTheme.background,
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

func reflectionPathLabel(for entry: ReflectionEntry) -> String {
    if entry.id.hasPrefix("japji-") {
        return "Japji Sahib"
    }
    return entry.sourceType.displayName
}

func reflectionMeaningLabel(for language: AppLanguage) -> String {
    switch language {
    case .english:
        return "English Meaning"
    case .hindi:
        return "Hindi Meaning"
    case .punjabi:
        return "Punjabi Meaning"
    }
}

private func timeBasedGreeting(for date: Date = Date()) -> String {
    let hour = Calendar.current.component(.hour, from: date)
    switch hour {
    case 5..<12:
        return "Good Morning"
    case 12..<17:
        return "Good Afternoon"
    case 17..<21:
        return "Good Evening"
    default:
        return "Good Night"
    }
}

private func formattedTodayLine(_ date: Date = Date()) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

enum ReflectionShareCardRenderer {
    @MainActor
    static func image(for entry: ReflectionEntry, language: AppLanguage = .english) -> UIImage? {
        let card = ReflectionShareImageCard(entry: entry, language: language)
            .frame(width: 1080, height: 1350)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 2
        return renderer.uiImage
    }
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SharePayload: Identifiable {
    let id = UUID()
    let items: [Any]
}

private struct ReflectionShareImageCard: View {
    let entry: ReflectionEntry
    let language: AppLanguage

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),
                    Color(red: 0.10, green: 0.12, blue: 0.20),
                    Color(red: 0.04, green: 0.06, blue: 0.11)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.cardBackground.opacity(0.94),
                            AppTheme.cardSecondary.opacity(0.98)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 44, style: .continuous)
                        .stroke(AppTheme.accentGold.opacity(0.35), lineWidth: 2)
                )
                .padding(44)

            VStack(spacing: 18) {
                VStack(spacing: 6) {
                    Text(timeBasedGreeting())
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(formattedTodayLine())
                        .font(.system(size: 34, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("\(language.text(.pathLabel)): \(reflectionPathLabel(for: entry))")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.accentGold)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 6)

                VStack(spacing: 14) {
                    shareSection(title: language.text(.gurbaniVerse), content: entry.gurmukhiText, isGurmukhi: true)
                    shareSection(title: reflectionMeaningLabel(for: language), content: entry.englishMeaning)
                    shareSection(title: language.text(.simpleExplanation), content: entry.simpleExplanation)
                    shareSection(title: language.text(.reflectionForToday), content: entry.lifeReflection)
                }
                .frame(maxHeight: .infinity)

                Text(language.text(.shareFooter))
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                    .padding(.bottom, 2)
            }
            .padding(.horizontal, 88)
            .padding(.vertical, 78)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    @ViewBuilder
    private func shareSection(title: String, content: String, isGurmukhi: Bool = false) -> some View {
        let metrics = sectionMetrics(for: content, isGurmukhi: isGurmukhi)

        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.accentGold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(content)
                .font(
                    isGurmukhi
                    ? .system(size: metrics.fontSize, weight: .medium, design: .serif)
                    : .system(size: metrics.fontSize, weight: .regular, design: .rounded)
                )
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(5)
                .lineLimit(metrics.maxLines)
                .minimumScaleFactor(0.52)
                .allowsTightening(true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppTheme.background.opacity(0.33))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.cardSecondary.opacity(0.9), lineWidth: 1)
        )
    }

    private func sectionMetrics(for content: String, isGurmukhi: Bool) -> (fontSize: CGFloat, maxLines: Int) {
        let length = content.count

        if isGurmukhi {
            switch length {
            case ..<70:
                return (56, 3)
            case ..<110:
                return (50, 4)
            case ..<160:
                return (44, 5)
            case ..<230:
                return (40, 6)
            default:
                return (36, 7)
            }
        }

        switch length {
        case ..<90:
            return (36, 3)
        case ..<150:
            return (32, 4)
        case ..<230:
            return (28, 5)
        case ..<320:
            return (25, 6)
        default:
            return (22, 7)
        }
    }
}
