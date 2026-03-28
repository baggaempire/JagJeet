import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.accentGold)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(GoldPressButtonStyle())
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        PrimaryButton(title: "Open Today's Reflection", action: {})
            .padding()
    }
}
