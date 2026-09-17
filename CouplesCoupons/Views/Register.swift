import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var validationMessage: String?

    var body: some View {
        ZStack {
            WarmBackground()
            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(WarmPalette.pink)
                    VStack(spacing: 6) {
                        Text("Create your account")
                            .font(.title2.bold())
                            .foregroundStyle(WarmPalette.pink)
                        Text("Start something lovely together")
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 16) {
                        TextField("Display name", text: $displayName)
                            .textContentType(.name)
                            .warmField()
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .warmField()
                        SecureField("Password (8+ characters)", text: $password)
                            .textContentType(.newPassword)
                            .warmField()

                        if let message = validationMessage ?? authManager.errorMessage {
                            Label(message, systemImage: "exclamationmark.triangle.fill")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(WarmPalette.pink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(WarmPalette.pink.opacity(0.1))
                                )
                        }

                        Button {
                            submit()
                        } label: {
                            if authManager.isWorking {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create Account")
                            }
                        }
                        .buttonStyle(WarmPrimaryButtonStyle())
                        .disabled(authManager.isWorking)
                    }
                }
                .padding(32)
            }
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .tint(WarmPalette.pink)
        .onAppear { authManager.clearError() }
    }

    private func submit() {
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !name.isEmpty, !normalizedEmail.isEmpty else {
            validationMessage = "Enter your display name and email."
            return
        }
        guard password.count >= 8 else {
            validationMessage = "Password must be at least 8 characters."
            return
        }
        validationMessage = nil
        Task {
            await authManager.register(email: normalizedEmail, password: password, displayName: name)
        }
    }
}

#Preview {
    NavigationStack { RegisterView() }
        .environmentObject(AuthManager())
}
