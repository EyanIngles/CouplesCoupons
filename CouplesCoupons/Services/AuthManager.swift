//
//  AuthManager.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

// Services/AuthManager.swift
import Combine
import Foundation

@MainActor
final class AuthManager: ObservableObject {
    enum SessionPhase: Equatable {
        case restoring
        case signedOut
        case resolvingCouple
        case unpaired
        case pending(Couple)
        case active(Couple)
        case restoreFailed(String)
    }

    @Published private(set) var phase: SessionPhase = .restoring
    @Published private(set) var currentUser: User?
    @Published private(set) var currentCouple: Couple?
    @Published private(set) var isWorking = false
    @Published var errorMessage: String?

    private let apiClient: APIClient
    private var hasAttemptedRestore = false
    private var pollingTask: Task<Void, Never>?

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func restoreSession(force: Bool = false) async {
        guard force || !hasAttemptedRestore else { return }
        hasAttemptedRestore = true
        stopPendingPolling()
        errorMessage = nil
        phase = .restoring

        guard let token = KeychainHelper.loadToken() else {
            phase = .signedOut
            return
        }

        await apiClient.setToken(token)
        do {
            currentUser = try await apiClient.currentUser()
            await resolveCouple()
        } catch let error as APIError where error.statusCode == 401 {
            await invalidateSession()
        } catch {
            phase = .restoreFailed(message(for: error))
        }
    }

    func login(email: String, password: String) async {
        await authenticate {
            try await self.apiClient.login(email: email, password: password)
        }
    }

    func register(email: String, password: String, displayName: String) async {
        await authenticate {
            try await self.apiClient.register(email: email, password: password, displayName: displayName)
        }
    }

    func createCouple() async {
        await performPairingRequest {
            try await self.apiClient.createCouple()
        }
    }

    func joinCouple(inviteCode: String) async {
        await performPairingRequest {
            try await self.apiClient.joinCouple(inviteCode: inviteCode)
        }
    }

    func refreshCouple(showErrors: Bool = true) async {
        guard currentUser != nil else { return }
        do {
            let couple = try await apiClient.currentCouple()
            apply(couple)
        } catch let error as APIError where error.statusCode == 404 {
            stopPendingPolling()
            currentCouple = nil
            phase = .unpaired
        } catch let error as APIError where error.statusCode == 401 {
            await invalidateSession()
        } catch {
            if showErrors {
                errorMessage = message(for: error)
            }
        }
    }

    func reconcileCouple() async {
        switch phase {
        case .unpaired, .pending, .active:
            await refreshCouple(showErrors: false)
        default:
            break
        }
    }

    func leaveCouple() async {
        let previousPhase = phase
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            _ = try await apiClient.leaveCouple()
            stopPendingPolling()
            currentCouple = nil
            phase = .unpaired
        } catch let error as APIError where error.statusCode == 401 {
            await invalidateSession()
        } catch {
            phase = previousPhase
            errorMessage = message(for: error)
        }
    }

    func logout() async {
        do {
            try KeychainHelper.deleteToken()
        } catch {
            errorMessage = message(for: error)
            return
        }
        stopPendingPolling()
        await apiClient.setToken(nil)
        currentUser = nil
        currentCouple = nil
        errorMessage = nil
        phase = .signedOut
    }

    func startPendingPolling() {
        guard pollingTask == nil else { return }
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(4))
                } catch {
                    break
                }
                guard let self, self.isPending else { break }
                await self.refreshCouple(showErrors: false)
            }
            self?.pollingTask = nil
        }
    }

    func stopPendingPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func clearError() {
        errorMessage = nil
    }

    private var isPending: Bool {
        if case .pending = phase { return true }
        return false
    }

    private func authenticate(operation: () async throws -> AuthResponse) async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            let response = try await operation()
            try KeychainHelper.save(token: response.token)
            await apiClient.setToken(response.token)
            currentUser = response.user
            await resolveCouple()
        } catch {
            errorMessage = message(for: error)
        }
    }

    private func resolveCouple() async {
        phase = .resolvingCouple
        currentCouple = nil
        do {
            apply(try await apiClient.currentCouple())
        } catch let error as APIError where error.statusCode == 404 {
            phase = .unpaired
        } catch let error as APIError where error.statusCode == 401 {
            await invalidateSession()
        } catch {
            phase = .restoreFailed(message(for: error))
        }
    }

    private func performPairingRequest(operation: () async throws -> Couple) async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            apply(try await operation())
        } catch let error as APIError where error.statusCode == 401 {
            await invalidateSession()
        } catch {
            errorMessage = message(for: error)
        }
    }

    private func apply(_ couple: Couple) {
        currentCouple = couple
        switch couple.status {
        case .pending:
            phase = .pending(couple)
        case .active:
            stopPendingPolling()
            phase = .active(couple)
        }
    }

    private func invalidateSession() async {
        stopPendingPolling()
        do {
            try KeychainHelper.deleteToken()
        } catch {
            errorMessage = "Your session expired. \(message(for: error))"
        }
        await apiClient.setToken(nil)
        currentUser = nil
        currentCouple = nil
        phase = .signedOut
    }

    private func message(for error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}
