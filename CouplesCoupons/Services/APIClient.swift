//
//  APIClient.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

// Services/APIClient.swift
import Foundation

actor APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?

    init(baseURL: URL = Constants.apiBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func setToken(_ token: String?) {
        authToken = token
    }

    func register(email: String, password: String, displayName: String) async throws -> AuthResponse {
        let body = RegisterRequest(email: email, password: password, displayName: displayName)
        return try await request(path: "auth/register", method: "POST", body: encode(body), authorized: false)
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        return try await request(path: "auth/login", method: "POST", body: encode(body), authorized: false)
    }

    func me() async throws -> User {
        try await request(path: "auth/me", method: "GET")
    }

    func createCouple() async throws -> Couple {
        try await request(path: "couples", method: "POST")
    }

    func joinCouple(inviteCode: String) async throws -> Couple {
        let body = JoinCoupleRequest(inviteCode: inviteCode)
        return try await request(path: "couples/join", method: "POST", body: encode(body))
    }

    func currentCouple() async throws -> Couple {
        try await request(path: "couples/me", method: "GET")
    }

    func leaveCouple() async throws -> LeaveCoupleResponse {
        try await request(path: "couples/leave", method: "POST")
    }

    private func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            return try encoder.encode(value)
        } catch {
            throw APIError.encoding(error.localizedDescription)
        }
    }

    private func request<T: Decodable & Sendable>(
        path: String,
        method: String,
        body: Data? = nil,
        authorized: Bool = true
    ) async throws -> T {
        precondition(!path.hasPrefix("/"), "API paths must not begin with a slash")
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if authorized, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard 200..<300 ~= http.statusCode else {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let message = (try? decoder.decode(APIErrorResponse.self, from: data).error)
                ?? HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            throw APIError.http(statusCode: http.statusCode, message: message)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }
}

nonisolated enum APIError: Error, LocalizedError, Sendable {
    case http(statusCode: Int, message: String)
    case invalidResponse
    case transport(String)
    case encoding(String)
    case decoding(String)

    var statusCode: Int? {
        guard case .http(let statusCode, _) = self else { return nil }
        return statusCode
    }

    var errorDescription: String? {
        switch self {
        case .http(_, let message): message
        case .invalidResponse: "The server returned an invalid response."
        case .transport: "Couldn’t reach the server. Make sure it is running on this Mac."
        case .encoding: "The request could not be prepared."
        case .decoding: "The server returned data the app could not read."
        }
    }
}
