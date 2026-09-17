import SwiftUI

enum WarmPalette {
    static let pink = Color(red: 0.89, green: 0.27, blue: 0.45)
    static let softPink = Color(red: 0.96, green: 0.75, blue: 0.80)
    static let cream = Color(red: 0.98, green: 0.95, blue: 0.90)
    static let gold = Color(red: 0.85, green: 0.70, blue: 0.35)
}

struct WarmBackground: View {
    var body: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            Circle()
                .fill(WarmPalette.softPink.opacity(0.25))
                .frame(width: 280, height: 280)
                .offset(x: -140, y: -320)
            Circle()
                .fill(WarmPalette.softPink.opacity(0.18))
                .frame(width: 200, height: 200)
                .offset(x: 160, y: 340)
        }
    }
}

struct WarmPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(WarmPalette.pink.opacity(configuration.isPressed ? 0.75 : 1))
                    .shadow(color: WarmPalette.pink.opacity(0.3), radius: 10, y: 5)
            )
            .foregroundStyle(.white)
    }
}

struct WarmFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
            )
    }
}

extension View {
    func warmField() -> some View {
        modifier(WarmFieldModifier())
    }
}
