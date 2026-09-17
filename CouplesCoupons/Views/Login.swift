//
//  Login.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                VStack(spacing: 0) {
                        Spacer()
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(WarmPalette.cream)
                                    .shadow(color: WarmPalette.pink.opacity(0.15), radius: 20, y: 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                                            .stroke(WarmPalette.pink.opacity(0.35), lineWidth: 3)
                                    )
                                    .frame(width: 160, height: 160)
                                Text("WC")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundStyle(WarmPalette.pink)
                                    .shadow(color: WarmPalette.gold.opacity(0.4), radius: 0, x: 1, y: 1)
                            }
                            Text("Welcome back")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(WarmPalette.pink.opacity(0.9))
                            Text("Just the two of us")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 38)

                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(WarmPalette.pink.opacity(0.7))
                                    .frame(width: 20)
                                TextField("Email", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                            }
                            .warmField()

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(WarmPalette.pink.opacity(0.7))
                                    .frame(width: 20)
                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                            }
                            .warmField()

                            if let message = validationMessage ?? authManager.errorMessage {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(WarmPalette.pink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button {
                                submit()
                            } label: {
                                if authManager.isWorking {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Log In")
                                }
                            }
                            .buttonStyle(WarmPrimaryButtonStyle())
                            .disabled(authManager.isWorking)

                            NavigationLink {
                                RegisterView()
                            } label: {
                                Text("New here? Create an account")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(WarmPalette.pink)
                            }
                        }
                        .padding(.horizontal, 32)

                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill").font(.caption2)
                            Text("BIRTHDAY EDITION")
                                .font(.caption.weight(.bold))
                                .tracking(1.5)
                            Image(systemName: "heart.fill").font(.caption2)
                        }
                        .foregroundStyle(WarmPalette.pink.opacity(0.7))
                        .padding(.bottom, 30)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                authManager.clearError()
            }
        }
    }

    private func submit() {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEmail.isEmpty, !password.isEmpty else {
            validationMessage = "Enter your email and password."
            return
        }
        validationMessage = nil
        Task {
            await authManager.login(email: normalizedEmail, password: password)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
