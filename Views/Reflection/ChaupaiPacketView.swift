import SwiftUI

struct ChaupaiPacketView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ChaupaiPacketViewModel()

    @State private var currentIndex: Int = 0
    @State private var sharePayload: SharePayload?
    @State private var transitionOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1
    @State private var isCompleting = false
    @State private var completeGlow = false
    @State private var showCompleteCheckmark = false
    @State private var showCompletedMessage = false
    @State private var showRestartPrompt = false

    private var entries: [ReflectionEntry] { appViewModel.chaupaiEntries }
    private var currentEntry: ReflectionEntry? {
        guard entries.indices.contains(currentIndex) else { return nil }
        return entries[currentIndex]
    }
    private var unfinishedIndices: [Int] {
        entries.indices.filter { !appViewModel.isChaupaiCompleted(entries[$0]) }
    }
    private var allCompleted: Bool {
        !entries.isEmpty && unfinishedIndices.isEmpty
    }
    private var canMovePrevious: Bool {
        previousUnfinishedIndex(before: currentIndex) != nil
    }

    private var language: AppLanguage {
        appViewModel.preferences.preferredLanguage
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 14) {
                header

                if let entry = currentEntry {
                    packetCard(entry: entry)
                        .calmReveal(trigger: entry.id)
                } else {
                    Text(language.text(.noChaupaiAvailable))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding()
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .navigationTitle("Chaupai Sahib \(language.text(.pathLabel))")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            controls
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppTheme.background.opacity(0.92))
        }
        .onAppear {
            prepareStartingIndex()
        }
        .sheet(item: $sharePayload) { payload in
            ActivityShareSheet(items: payload.items)
        }
        .alert(language.text(.pathComplete), isPresented: $showRestartPrompt) {
            Button(language.text(.startAgain)) {
                restartPacket()
            }
            Button(language.text(.notNow), role: .cancel) {}
        } message: {
            Text(language.text(.chaupaiRestartMessage))
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("\(appViewModel.chaupaiCompletedCount) / \(appViewModel.chaupaiTotalCount) \(language.text(.ofCompleted))")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)

            Text(language.text(.swipeRightToNext))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.accentGold)
        }
        .padding(.top, 8)
    }

    private func packetCard(entry: ReflectionEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("\(language.text(.verse)) \(currentIndex + 1)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.accentGold)

                    Spacer()

                    if appViewModel.isChaupaiCompleted(entry) {
                        Label(language.text(.completed), systemImage: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.green)
                    }
                }

                CompletionStatusOverlay(visible: showCompletedMessage, text: language.text(.completed))

                PacketReflectionSection(title: language.text(.gurmukhiVerse), content: entry.gurmukhiText, isGurmukhi: true)
                PacketReflectionSection(title: reflectionMeaningLabel(for: language), content: entry.englishMeaning)
                PacketReflectionSection(title: language.text(.simpleExplanation), content: entry.simpleExplanation)
                PacketReflectionSection(title: language.text(.reflectionForToday), content: entry.lifeReflection)
            }
            .padding(24)
        }
        .frame(maxHeight: 560)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCardContainer(cornerRadius: 24)
        .offset(x: viewModel.dragOffset + transitionOffset)
        .opacity(cardOpacity)
        .rotationEffect(.degrees(Double(viewModel.dragOffset / 25)))
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    if abs(value.translation.width) > abs(value.translation.height) {
                        viewModel.dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    handleSwipe(
                        translationWidth: value.translation.width,
                        translationHeight: value.translation.height
                    )
                }
        )
        .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.9), value: viewModel.dragOffset)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                if let entry = currentEntry {
                    Button {
                        appViewModel.bookmarkToggle(entry)
                    } label: {
                        Label(
                            appViewModel.isBookmarked(entry) ? language.text(.saved) : language.text(.save),
                            systemImage: appViewModel.isBookmarked(entry) ? "bookmark.fill" : "bookmark"
                        )
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.cardSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(GoldPressButtonStyle())

                    Button {
                        shareCard(for: entry)
                    } label: {
                        Label(language.text(.share), systemImage: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.cardSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(GoldPressButtonStyle())
                }
            }

            HStack(spacing: 12) {
                Button {
                    movePrevious()
                } label: {
                    Label(language.text(.previous), systemImage: "arrow.left")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.cardSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!canMovePrevious)
                .opacity(canMovePrevious ? 1 : 0.45)
                .buttonStyle(GoldPressButtonStyle())

                Button {
                    Task {
                        await runCompletionMomentAndAdvance()
                    }
                } label: {
                    Label(showCompleteCheckmark ? language.text(.completed) : language.text(.completeNext), systemImage: showCompleteCheckmark ? "checkmark.circle.fill" : "arrow.right")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
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
    }
    
    private func shareText(for entry: ReflectionEntry) -> String {
        """
        \(entry.title)

        \(language.text(.gurmukhiVerse)):
        \(entry.gurmukhiText)

        \(reflectionMeaningLabel(for: language)):
        \(entry.englishMeaning)

        \(language.text(.simpleExplanation)):
        \(entry.simpleExplanation)

        \(language.text(.reflectionForToday)):
        \(entry.lifeReflection)
        """
    }

    private func shareCard(for entry: ReflectionEntry) {
        if let image = ReflectionShareCardRenderer.image(for: entry, language: language) {
            sharePayload = SharePayload(items: [image])
        } else {
            sharePayload = SharePayload(items: [shareText(for: entry)])
        }
    }

    private func handleSwipe(translationWidth: CGFloat, translationHeight: CGFloat) {
        guard abs(translationWidth) > abs(translationHeight) else {
            viewModel.dragOffset = 0
            return
        }

        if translationWidth > viewModel.swipeThreshold {
            markCompleteAndAdvance()
        } else if translationWidth < -viewModel.swipeThreshold {
            movePrevious()
        }
        viewModel.dragOffset = 0
    }

    private func markCompleteAndAdvance() {
        guard let entry = currentEntry else { return }
        appViewModel.markChaupaiCompleted(entry)
        moveToNextUnfinished()
    }

    private func runCompletionMomentAndAdvance() async {
        guard !isCompleting else { return }
        isCompleting = true

        withAnimation(.easeOut(duration: 0.15)) {
            completeGlow = true
            showCompleteCheckmark = true
            showCompletedMessage = true
        }

        guard let entry = currentEntry else {
            isCompleting = false
            return
        }

        appViewModel.markChaupaiCompleted(entry)

        if let nextIndex = nextUnfinishedIndex(after: currentIndex) ?? unfinishedIndices.first {
            withAnimation(.easeOut(duration: 0.24)) {
                transitionOffset = -24
                cardOpacity = 0
            }
            try? await Task.sleep(nanoseconds: 240_000_000)

            currentIndex = nextIndex
            appViewModel.updateChaupaiCurrentIndex(currentIndex)
            transitionOffset = 28
            cardOpacity = 0

            withAnimation(.easeOut(duration: 0.32)) {
                transitionOffset = 0
                cardOpacity = 1
            }
        } else {
            appViewModel.updateChaupaiCurrentIndex(currentIndex)
            showRestartPrompt = allCompleted
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

    private func movePrevious() {
        guard let previousIndex = previousUnfinishedIndex(before: currentIndex) else { return }
        currentIndex = previousIndex
        appViewModel.updateChaupaiCurrentIndex(currentIndex)
    }

    private func prepareStartingIndex() {
        guard !entries.isEmpty else {
            currentIndex = 0
            return
        }

        let savedIndex = min(appViewModel.chaupaiPacketProgress.currentIndex, max(entries.count - 1, 0))
        if entries.indices.contains(savedIndex), !appViewModel.isChaupaiCompleted(entries[savedIndex]) {
            currentIndex = savedIndex
        } else if let firstUnfinished = unfinishedIndices.first {
            currentIndex = firstUnfinished
        } else {
            currentIndex = savedIndex
            showRestartPrompt = true
        }

        appViewModel.updateChaupaiCurrentIndex(currentIndex)
    }

    private func nextUnfinishedIndex(after index: Int) -> Int? {
        guard !entries.isEmpty else { return nil }
        let start = min(max(index + 1, 0), entries.count)
        if start < entries.count {
            for candidate in start..<entries.count where !appViewModel.isChaupaiCompleted(entries[candidate]) {
                return candidate
            }
        }
        for candidate in 0..<min(index + 1, entries.count) where !appViewModel.isChaupaiCompleted(entries[candidate]) {
            return candidate
        }
        return nil
    }

    private func previousUnfinishedIndex(before index: Int) -> Int? {
        guard !entries.isEmpty, index > 0 else { return nil }
        var candidate = index - 1
        while candidate >= 0 {
            if !appViewModel.isChaupaiCompleted(entries[candidate]) {
                return candidate
            }
            candidate -= 1
        }
        return nil
    }

    private func moveToNextUnfinished() {
        if let nextIndex = nextUnfinishedIndex(after: currentIndex) {
            currentIndex = nextIndex
        }
        appViewModel.updateChaupaiCurrentIndex(currentIndex)
        if allCompleted {
            showRestartPrompt = true
        }
    }

    private func restartPacket() {
        appViewModel.resetChaupaiProgress()
        currentIndex = 0
        appViewModel.updateChaupaiCurrentIndex(currentIndex)
    }
}

private struct PacketReflectionSection: View {
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
        ChaupaiPacketView()
            .environmentObject(AppViewModel())
    }
}
