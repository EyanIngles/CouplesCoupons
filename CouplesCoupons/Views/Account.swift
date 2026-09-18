import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var confirmingLeave = false

    private var partner: CoupleMember? {
        guard let me = authManager.currentUser?.id else { return nil }
        return authManager.currentCouple?.members.first { $0.id != me }
    }

    var body: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            Form {
                Section("You") {
                    LabeledContent("Name", value: authManager.currentUser?.displayName ?? "—")
                    LabeledContent("Email", value: authManager.currentUser?.email ?? "—")
                }

                Section("Partner") {
                    if let partner {
                        LabeledContent("Name", value: partner.displayName)
                        LabeledContent("Email", value: partner.email)
                    } else {
                        Text("Not linked yet. They need to join with your invite code — creating their own couple will not connect you.")
                            .foregroundStyle(WarmPalette.pink)
                    }
                }

                if let error = authManager.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Leave Couple", role: .destructive) {
                        confirmingLeave = true
                    }
                    .disabled(authManager.isWorking)
                    Button("Log Out") {
                        Task { await authManager.logout() }
                    }
                    .disabled(authManager.isWorking)
                } footer: {
                    Text("Leaving dissolves the couple for both members.")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Account")
        .tint(WarmPalette.pink)
        .onAppear { authManager.clearError() }
        .confirmationDialog("Leave this couple?", isPresented: $confirmingLeave, titleVisibility: .visible) {
            Button("Leave Couple", role: .destructive) {
                Task { await authManager.leaveCouple() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This dissolves the couple for both people and cannot be undone. If coupons exist, both coupon banks will be cleared. Points stay on each account.")
        }
    }
}

#Preview {
    NavigationStack { AccountView() }
        .environmentObject(AuthManager())
}
