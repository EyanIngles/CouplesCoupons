import SwiftUI

struct WaitingPairingView: View {
    @EnvironmentObject private var authManager: AuthManager
    let couple: Couple
    @State private var confirmingLeave = false

    var body: some View {
        ZStack {
            WarmBackground()
            VStack(spacing: 24) {
                Image(systemName: "heart.circle")
                    .font(.system(size: 64))
                    .foregroundStyle(WarmPalette.pink)
                Text("Waiting for your partner")
                    .font(.title2.bold())
                    .foregroundStyle(WarmPalette.pink)
                Text("Ask them to enter this invite code")
                    .foregroundStyle(.secondary)
                Text(couple.inviteCode)
                    .font(.system(size: 38, weight: .bold, design: .monospaced))
                    .tracking(5)
                    .foregroundStyle(WarmPalette.pink)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.white))
                    .textSelection(.enabled)

                ProgressView("Checking for your partner…")
                    .tint(WarmPalette.pink)

                if let error = authManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(WarmPalette.pink)
                        .multilineTextAlignment(.center)
                }

                Button("Refresh Now") {
                    Task { await authManager.refreshCouple() }
                }
                .buttonStyle(WarmPrimaryButtonStyle())

                HStack(spacing: 24) {
                    Button("Leave Couple", role: .destructive) {
                        confirmingLeave = true
                    }
                    Button("Log Out") {
                        Task { await authManager.logout() }
                    }
                    .foregroundStyle(WarmPalette.pink)
                }
            }
            .padding(32)
        }
        .onAppear { authManager.startPendingPolling() }
        .onDisappear { authManager.stopPendingPolling() }
        .confirmationDialog("Leave this couple?", isPresented: $confirmingLeave, titleVisibility: .visible) {
            Button("Leave Couple", role: .destructive) {
                Task { await authManager.leaveCouple() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The invite will stop working and this couple will be dissolved.")
        }
    }
}

#Preview {
    WaitingPairingView(
        couple: Couple(
            id: UUID(),
            status: .pending,
            inviteCode: "ABC234",
            members: [],
            entitlements: CoupleEntitlements(
                canNegotiate: false,
                templatePack: "basic",
                weeklySendLimit: 5,
                weeklyUseLimit: 3,
                maxActiveBank: 5
            )
        )
    )
    .environmentObject(AuthManager())
}
