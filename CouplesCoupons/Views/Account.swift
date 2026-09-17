import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var confirmingLeave = false

    var body: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            Form {
                Section("Account") {
                    LabeledContent("Name", value: authManager.currentUser?.displayName ?? "—")
                    LabeledContent("Email", value: authManager.currentUser?.email ?? "—")
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
