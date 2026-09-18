import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.scenePhase) private var scenePhase
    @State private var forceUpdate = false
    @State private var whatsNew: [ChangelogEntry] = []
    @State private var showWhatsNew = false

    var body: some View {
        Group {
            if forceUpdate {
                updateRequiredView
            } else {
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
        }
        .preferredColorScheme(.light)
        .task {
            await authManager.restoreSession()
            await checkVersion()
        }
        .onChange(of: scenePhase) { newPhase in
            guard newPhase == .active else { return }
            Task {
                await authManager.reconcileCouple()
                await checkVersion()
            }
        }
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewView(entries: whatsNew) {
                AppVersion.lastSeen = AppVersion.current
                showWhatsNew = false
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

    private var updateRequiredView: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "arrow.down.app")
                    .font(.system(size: 44))
                    .foregroundStyle(WarmPalette.pink)
                Text("Update required")
                    .font(.title2.bold())
                    .foregroundStyle(WarmPalette.pink)
                Text("This TestFlight is too old for the server. Open TestFlight and install the latest Couples Coupons.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(WarmPalette.pink.opacity(0.8))
                Text("App \(AppVersion.current)")
                    .font(.caption)
                    .foregroundStyle(WarmPalette.pink.opacity(0.7))
            }
            .padding(32)
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

    @MainActor
    private func checkVersion() async {
        do {
            let remote = try await APIClient.shared.fetchVersion()
            forceUpdate = AppVersion.isOlder(AppVersion.current, than: remote.minApp)
            guard !forceUpdate else { return }
            let notes = Changelog.notes(after: AppVersion.lastSeen, upTo: AppVersion.current)
            if !notes.isEmpty {
                whatsNew = notes
                showWhatsNew = true
            }
        } catch {
            forceUpdate = false
        }
    }
}

struct WhatsNewView: View {
    let entries: [ChangelogEntry]
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    Section(entry.version) {
                        ForEach(entry.notes, id: \.self) { note in
                            Text(note)
                        }
                    }
                }
            }
            .navigationTitle("What’s new")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDismiss)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
