//
//  Login.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Matching your icon colours
    private let pink = Color(red: 0.89, green: 0.27, blue: 0.45)          // main pink
    private let softPink = Color(red: 0.96, green: 0.75, blue: 0.80)
    private let cream = Color(red: 0.98, green: 0.95, blue: 0.90)
    private let gold = Color(red: 0.85, green: 0.70, blue: 0.35)
    
    var body: some View {
        ZStack {
            cream
                .ignoresSafeArea()

            Circle()
                .fill(softPink.opacity(0.25))
                .frame(width: 280, height: 280)
                .offset(x: -140, y: -320)

            Circle()
                .fill(softPink.opacity(0.18))
                .frame(width: 200, height: 200)
                .offset(x: 160, y: 340)

            VStack(spacing: 0) {
                        Spacer()
                        
                        // Logo / Title area
                        VStack(spacing: 12) {
                            ZStack {
                                // Soft badge background
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(cream)
                                    .shadow(color: pink.opacity(0.15), radius: 20, y: 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                                            .stroke(pink.opacity(0.35), lineWidth: 3)
                                    )
                                    .frame(width: 160, height: 160)
                                
                                // Big WC
                                Text("WC")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundStyle(pink)
                                    .shadow(color: gold.opacity(0.4), radius: 0, x: 1, y: 1)
                            }
                            
                            Text("Welcome back")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(pink.opacity(0.9))
                            
                            Text("Just the two of us")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 50)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Email
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(pink.opacity(0.7))
                                    .frame(width: 20)
                                
                                TextField("Username", text: $email)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
                            )
                            
                            // Password
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(pink.opacity(0.7))
                                    .frame(width: 20)
                                
                                SecureField("Password", text: $password)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
                            )
                            
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundStyle(pink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // Login button
                            Button {
                                attemptMockLogin()
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Log In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(pink)
                                        .shadow(color: pink.opacity(0.35), radius: 12, y: 6)
                                )
                                .foregroundStyle(.white)
                            }
                            .disabled(isLoading)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                        
                        // Bottom little banner feel
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                            Text("BIRTHDAY EDITION")
                                .font(.caption.weight(.bold))
                                .tracking(1.5)
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                        }
                        .foregroundStyle(pink.opacity(0.7))
                        .padding(.bottom, 30)
            }
        }
    }

    private func attemptMockLogin() {
        let username = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        errorMessage = nil

        // Mock / test account until the server is wired up.
        if username == "eyan" {
            isAuthenticated = true
        } else {
            errorMessage = "Invalid username or password"
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
}

