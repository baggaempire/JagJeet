import SwiftUI
import UIKit

struct CalmRevealModifier: ViewModifier {
    let trigger: AnyHashable

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .onAppear {
                reveal()
            }
            .onChange(of: trigger) { _, _ in
                isVisible = false
                reveal()
            }
    }

    private func reveal() {
        withAnimation(.easeOut(duration: 0.35)) {
            isVisible = true
        }
    }
}

struct GoldPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .shadow(
                color: AppTheme.accentGold.opacity(configuration.isPressed ? 0.18 : 0.32),
                radius: configuration.isPressed ? 4 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 6
            )
            .animation(.spring(response: 0.18, dampingFraction: 0.68), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue && !oldValue {
                    AppHaptics.impact(.light)
                }
            }
    }
}

struct PremiumCardContainerModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppTheme.cardBackground.opacity(0.96))

                    // Subtle inner gradient: top slightly lighter than bottom.
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.045),
                                    Color.clear,
                                    Color.black.opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.cardSecondary.opacity(0.95), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.12),
                radius: 30,
                x: 0,
                y: 8
            )
    }
}

enum AppHaptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct CompletionStatusOverlay: View {
    let visible: Bool
    let text: String

    var body: some View {
        Group {
            if visible {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                    Text(text)
                        .foregroundStyle(AppTheme.textPrimary)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.cardSecondary.opacity(0.96))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(AppTheme.cardSecondary, lineWidth: 1)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeOut(duration: 0.2), value: visible)
    }
}

extension View {
    func calmReveal(trigger: AnyHashable) -> some View {
        modifier(CalmRevealModifier(trigger: trigger))
    }

    func premiumCardContainer(cornerRadius: CGFloat = 24) -> some View {
        modifier(PremiumCardContainerModifier(cornerRadius: cornerRadius))
    }
}
