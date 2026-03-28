import SwiftUI

struct DailyReflectionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    let entry: ReflectionEntry

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var deck: [ReflectionEntry] = []
    @State private var sharePayload: SharePayload?
    @State private var transitionOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1
    @State private var isCompleting = false
    @State private var completeGlow = false
    @State private var showCompleteCheckmark = false
    @State private var showCompletedMessage = false

    private var entries: [ReflectionEntry] {
        deck.isEmpty ? [entry] : deck
    }

    private var currentEntry: ReflectionEntry {
        let safeIndex = min(max(currentIndex, 0), max(entries.count - 1, 0))
        return entries[safeIndex]
    }

    private var language: AppLanguage {
        appViewModel.preferences.preferredLanguage
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 12) {
                VStack(spacing: 6) {
                    Text(sourcePathLabel(for: currentEntry))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.accentGold)

                    Text(language.text(.swipeRightToNext))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.accentGold)
                }

                CompletionStatusOverlay(visible: showCompletedMessage, text: language.text(.completed))

                UnifiedReflectionCard(
                    entry: currentEntry,
                    meaningTitle: reflectionMeaningLabel(for: language),
                    language: language
                )
                    .calmReveal(trigger: currentEntry.id)
                    .offset(x: dragOffset + transitionOffset)
                    .opacity(cardOpacity)
                    .rotationEffect(.degrees(Double(dragOffset / 30)))
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                // Only apply swipe offset for mostly-horizontal gestures,
                                // so vertical drags can scroll card content.
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

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            actionBar
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppTheme.background.opacity(0.92))
        }
        .onAppear {
            deck = appViewModel.shuffledLearningDeck(startingWith: entry)
            currentIndex = 0
        }
        .sheet(item: $sharePayload) { payload in
            ActivityShareSheet(items: payload.items)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                appViewModel.bookmarkToggle(currentEntry)
            } label: {
                Image(systemName: appViewModel.isBookmarked(currentEntry) ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.cardSecondary)
                    .clipShape(Circle())
            }
            .buttonStyle(GoldPressButtonStyle())

            Button {
                shareCard(for: currentEntry)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.cardSecondary)
                    .clipShape(Circle())
            }
            .buttonStyle(GoldPressButtonStyle())

            Spacer()

            Button {
                Task {
                    await runCompletionMomentAndAdvance()
                }
            } label: {
                HStack(spacing: 6) {
                    if showCompleteCheckmark {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text(showCompleteCheckmark ? language.text(.completed) : language.text(.completeNext))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppTheme.accentGold)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(
                        color: AppTheme.accentGold.opacity(completeGlow ? 0.45 : 0.18),
                        radius: completeGlow ? 14 : 4,
                        x: 0,
                        y: completeGlow ? 4 : 2
                    )
            }
            .buttonStyle(GoldPressButtonStyle())
            .disabled(isCompleting)
        }
    }

    private func handleSwipe(translationWidth: CGFloat, translationHeight: CGFloat) {
        // Ignore mostly-vertical gestures; they're intended for scrolling.
        guard abs(translationWidth) > abs(translationHeight) else {
            dragOffset = 0
            return
        }

        if translationWidth > 120 {
            markCompleteAndMoveNext()
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
        }
    }

    private func markCompleteAndMoveNext() {
        markCurrentEntryCompleted()

        guard currentIndex < entries.count - 1 else {
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex += 1
        }
    }

    private func markCurrentEntryCompleted() {
        if currentEntry.sourceType == .chaupaiSahib {
            appViewModel.markChaupaiCompleted(currentEntry)
            if let chaupaiIndex = appViewModel.chaupaiEntries.firstIndex(where: { $0.id == currentEntry.id }) {
                appViewModel.updateChaupaiCurrentIndex(chaupaiIndex + 1)
            }
        }
    }

    private func runCompletionMomentAndAdvance() async {
        guard !isCompleting else { return }
        isCompleting = true

        withAnimation(.easeOut(duration: 0.15)) {
            completeGlow = true
            showCompleteCheckmark = true
            showCompletedMessage = true
        }

        markCurrentEntryCompleted()

        if currentIndex < entries.count - 1 {
            withAnimation(.easeOut(duration: 0.24)) {
                transitionOffset = -24
                cardOpacity = 0
            }
            try? await Task.sleep(nanoseconds: 240_000_000)

            currentIndex += 1
            transitionOffset = 28
            cardOpacity = 0

            withAnimation(.easeOut(duration: 0.32)) {
                transitionOffset = 0
                cardOpacity = 1
            }
        }

        try? await Task.sleep(nanoseconds: 160_000_000)
        withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
            completeGlow = false
        }

        try? await Task.sleep(nanoseconds: 620_000_000)
        withAnimation(.easeOut(duration: 0.2)) {
            showCompleteCheckmark = false
            showCompletedMessage = false
        }

        isCompleting = false
    }

    private func shareCard(for entry: ReflectionEntry) {
        if let image = ReflectionShareCardRenderer.image(for: entry, language: language) {
            sharePayload = SharePayload(items: [image])
        } else {
            sharePayload = SharePayload(items: [shareText(for: entry)])
        }
    }

    private func shareText(for entry: ReflectionEntry) -> String {
        """
        \(entry.title)

        \(language.text(.gurbaniVerse)):
        \(entry.gurmukhiText)

        \(reflectionMeaningLabel(for: language)):
        \(entry.englishMeaning)

        \(language.text(.simpleExplanation)):
        \(entry.simpleExplanation)

        \(language.text(.reflectionForToday)):
        \(entry.lifeReflection)
        """
    }

    private func sourcePathLabel(for entry: ReflectionEntry) -> String {
        if entry.id.hasPrefix("japji-") {
            return "Japji Sahib"
        }
        return entry.sourceType.displayName
    }
}

private struct UnifiedReflectionCard: View {
    let entry: ReflectionEntry
    let meaningTitle: String
    let language: AppLanguage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ReflectionSection(title: language.text(.gurmukhiVerse), content: entry.gurmukhiText, isGurmukhi: true)
                ReflectionSection(title: meaningTitle, content: entry.englishMeaning)
                ReflectionSection(title: language.text(.simpleExplanation), content: entry.simpleExplanation)
                ReflectionSection(title: language.text(.reflectionForToday), content: entry.lifeReflection)
            }
            .padding(24)
        }
        .frame(maxHeight: 560)
        .frame(maxWidth: .infinity)
        .premiumCardContainer(cornerRadius: 24)
    }
}

private struct ReflectionSection: View {
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
                .font(isGurmukhi ? AppTheme.gurmukhiFont : AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(8)
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
        DailyReflectionView(entry: ReflectionEntry(
            id: "sample",
            sourceType: .jaapSahib,
            title: "Sample",
            dayIndex: 1,
            date: nil,
            gurmukhiText: "ੴ ਸਤਿ ਨਾਮੁ ਕਰਤਾ ਪੁਰਖੁ",
            englishMeaning: "One universal Creator, whose Name is Truth.",
            simpleExplanation: "Start the day by remembering there is one source behind everything.",
            lifeReflection: "Before your first meeting today, pause and breathe one grateful breath.",
            isFeatured: true,
            audioFileName: nil,
            tags: ["gratitude"]
        ))
        .environmentObject(AppViewModel())
    }
}
