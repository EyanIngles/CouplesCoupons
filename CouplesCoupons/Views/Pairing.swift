import SwiftUI

struct PairingView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var inviteCode = ""
    @State private var validationMessage: String?

    var body: some View {
        ZStack {
            WarmBackground()
            ScrollView {
                VStack(spacing: 26) {
                    Image(systemName: "heart.2.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(WarmPalette.pink)
                    VStack(spacing: 8) {
                        Text("Pair with your person")
                            .font(.title.bold())
                            .foregroundStyle(WarmPalette.pink)
                        Text("Create a couple for a new invite code, or join with the code your partner shared.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 14) {
                        Button {
                            Task { await authManager.createCouple() }
                        } label: {
                            Label("Create a Couple", systemImage: "heart.badge.plus")
                        }
                        .buttonStyle(WarmPrimaryButtonStyle())
                        .disabled(authManager.isWorking)

                        HStack {
                            Rectangle().frame(height: 1).foregroundStyle(WarmPalette.softPink)
                            Text("OR").font(.caption.bold()).foregroundStyle(.secondary)
                            Rectangle().frame(height: 1).foregroundStyle(WarmPalette.softPink)
                        }

                        TextField("Invite code", text: $inviteCode)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .font(.title3.monospaced().weight(.semibold))
                            .warmField()
                            .onChange(of: inviteCode) { _, value in
                                inviteCode = String(value.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(8))
                            }

                        if let message = validationMessage ?? authManager.errorMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundStyle(WarmPalette.pink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button("Join Couple") {
                            join()
                        }
                        .buttonStyle(WarmPrimaryButtonStyle())
                        .disabled(authManager.isWorking)
                    }
                    .padding(22)
                    .background(RoundedRectangle(cornerRadius: 24).fill(.white.opacity(0.8)))

                    Button("Log Out") {
                        Task { await authManager.logout() }
                    }
                    .foregroundStyle(WarmPalette.pink)
                }
                .padding(28)
            }
        }
        .onAppear { authManager.clearError() }
    }

    private func join() {
        let code = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard 6...8 ~= code.count else {
            validationMessage = "Invite codes are 6–8 characters."
            return
        }
        validationMessage = nil
        Task { await authManager.joinCouple(inviteCode: code) }
    }
}

#Preview {
    PairingView()
        .environmentObject(AuthManager())
}
