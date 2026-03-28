import SwiftUI

struct SavedDeckView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var sharePayload: SharePayload?

    private var entries: [ReflectionEntry] {
        appViewModel.bookmarkedEntries.sorted { $0.id < $1.id }
    }

    private var currentEntry: ReflectionEntry? {
        guard entries.indices.contains(currentIndex) else { return nil }
        return entries[currentIndex]
    }

    private var language: AppLanguage {
        appViewModel.preferences.preferredLanguage
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 14) {
                if let entry = currentEntry {
                    savedCard(entry: entry)
                        .calmReveal(trigger: entry.id)
                        .offset(x: dragOffset)
                        .rotationEffect(.degrees(Double(dragOffset / 30)))
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    if abs(value.translation.width) > abs(value.translation.height) {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    handleSwipe(
                                        translationWidth: value.translation.width,
                                        translationHeight: value.translation.height
                                    )
                                }
                        )
                        .frame(maxHeight: .infinity, alignment: .top)
                } else {
                    emptyState
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            if !entries.isEmpty {
                controls
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppTheme.background.opacity(0.92))
            }
        }
        .onChange(of: entries.count) { _, newCount in
            if newCount == 0 {
                currentIndex = 0
            } else if currentIndex >= newCount {
                currentIndex = newCount - 1
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityShareSheet(items: payload.items)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.cardSecondary.opacity(0.8))
                    .frame(width: 76, height: 76)

                Image(systemName: "bookmark")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppTheme.accentGold.opacity(0.95))
            }

            Text(language.text(.noSavedVerses))
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text(language.text(.tapBookmarkToSave))
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private func savedCard(entry: ReflectionEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("\(language.text(.pathLabel)): \(sourcePathLabel(for: entry))")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.accentGold)

                SavedSection(title: language.text(.gurmukhiVerse), content: entry.gurmukhiText, isGurmukhi: true)
                SavedSection(title: reflectionMeaningLabel(for: appViewModel.preferences.preferredLanguage), content: entry.englishMeaning)
                SavedSection(title: language.text(.simpleExplanation), content: entry.simpleExplanation)
                SavedSection(title: language.text(.reflectionForToday), content: entry.lifeReflection)
            }
            .padding(24)
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCardContainer(cornerRadius: 24)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            controlIconButton(
                systemImage: "arrow.left",
                disabled: entries.isEmpty || currentIndex == 0
            ) {
                movePrevious()
            }

            controlIconButton(
                systemImage: "bookmark.slash",
                disabled: entries.isEmpty
            ) {
                if let entry = currentEntry {
                    appViewModel.bookmarkToggle(entry)
                }
            }

            controlIconButton(
                systemImage: "square.and.arrow.up",
                disabled: entries.isEmpty
            ) {
                if let entry = currentEntry {
                    shareCard(for: entry)
                }
            }

            Button {
                moveNext()
            } label: {
                Label(language.text(.next), systemImage: "arrow.right")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.accentGold)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(GoldPressButtonStyle())
            .disabled(entries.isEmpty)
            .opacity(entries.isEmpty ? 0.45 : 1)
        }
    }

    private func controlIconButton(
        systemImage: String,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 44, height: 44)
                .background(AppTheme.cardSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .disabled(disabled)
        .opacity(disabled ? 0.45 : 1)
        .buttonStyle(GoldPressButtonStyle())
    }

    private func handleSwipe(translationWidth: CGFloat, translationHeight: CGFloat) {
        guard abs(translationWidth) > abs(translationHeight) else {
            dragOffset = 0
            return
        }

        if translationWidth > 120 {
            moveNext()
        } else if translationWidth < -120 {
            movePrevious()
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
        }
    }

    private func moveNext() {
        guard !entries.isEmpty else { return }
        if currentIndex < entries.count - 1 {
            currentIndex += 1
        }
    }

    private func movePrevious() {
        guard !entries.isEmpty, currentIndex > 0 else { return }
        currentIndex -= 1
    }

    private func sourcePathLabel(for entry: ReflectionEntry) -> String {
        if entry.id.hasPrefix("japji-") {
            return "Japji Sahib"
        }
        return entry.sourceType.displayName
    }

    private func shareCard(for entry: ReflectionEntry) {
        if let image = ReflectionShareCardRenderer.image(for: entry, language: appViewModel.preferences.preferredLanguage) {
            sharePayload = SharePayload(items: [image])
        } else {
            sharePayload = SharePayload(items: [shareText(for: entry)])
        }
    }

    private func shareText(for entry: ReflectionEntry) -> String {
        """
        \(entry.title)

        Gurbani Verse:
        \(entry.gurmukhiText)

        \(reflectionMeaningLabel(for: appViewModel.preferences.preferredLanguage)):
        \(entry.englishMeaning)

        Simple Explanation:
        \(entry.simpleExplanation)

        Reflection For Today:
        \(entry.lifeReflection)
        """
    }
}

private struct SavedSection: View {
    let title: String
    let content: String
    var isGurmukhi: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.accentGold)
                .textCase(.uppercase)

            Text(content)
                .font(isGurmukhi ? AppTheme.gurmukhiFont : .system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(6)
                .lineLimit(nil)
                .minimumScaleFactor(isGurmukhi ? 0.65 : 1.0)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        SavedDeckView()
            .environmentObject(AppViewModel())
    }
}
