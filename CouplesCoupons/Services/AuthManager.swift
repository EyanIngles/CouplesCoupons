//
//  AuthManager.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

// Services/AuthManager.swift
import Foundation

@MainActor
//final class AuthManager: ObservableObject {
//    static let shared = AuthManager()

//    @Published var isAuthenticated = false
//    @Published var currentUser: User?

    func restoreSession() async {
        // Load token from Keychain / UserDefaults and validate with server
        // For mock:
        // isAuthenticated = true
    }

    func pair(withFriendCode code: String) async throws {
//       let response = try await APIClient.shared.login(withFriendCode: code)
//        APIClient.shared.setToken(response.token)
//        currentUser = response.user
//        isAuthenticated = true
        // Persist token
//    }
}
