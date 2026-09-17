//
//  ContentView.swift
//  CouplesCoupons
//
//  Created by Eyan Ingles on 31/8/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch authManager.phase {
            case .restoring, .resolvingCouple:
                loadingView
            case .signedOut:
                LoginView()
            case .unpaired:
                PairingView()
            case .pending(let couple):
                WaitingPairingView(couple: couple)
            case .active:
                HomeView()
            case .restoreFailed(let message):
                restoreFailureView(message: message)
            }
        }
        .task {
            await authManager.restoreSession()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
                await authManager.reconcileCouple()
            }
        }
    }

    private var loadingView: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .tint(WarmPalette.pink)
                Text(authManager.phase == .restoring ? "Restoring your session…" : "Finding your couple…")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func restoreFailureView(message: String) -> some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "heart.slash")
                    .font(.system(size: 44))
                    .foregroundStyle(WarmPalette.pink)
                Text("We couldn’t restore your session")
                    .font(.title2.bold())
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button("Try Again") {
                    Task { await authManager.restoreSession(force: true) }
                }
                .buttonStyle(WarmPrimaryButtonStyle())
                Button("Log Out") {
                    Task { await authManager.logout() }
                }
                .foregroundStyle(WarmPalette.pink)
            }
            .padding(32)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
