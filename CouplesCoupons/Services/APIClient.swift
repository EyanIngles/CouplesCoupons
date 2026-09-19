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

    func loginWithApple(identityToken: String, displayName: String?) async throws -> AuthResponse {
        struct Body: Encodable {
            let identityToken: String
            let displayName: String?
        }
        return try await request(
            path: "auth/apple",
            method: "POST",
            body: encode(Body(identityToken: identityToken, displayName: displayName)),
            authorized: false
        )
    }

    func currentUser() async throws -> User {
        try await request(path: "auth/current_user", method: "GET")
    }

    func fetchVersion() async throws -> VersionResponse {
        try await request(path: "version", method: "GET", authorized: false)
    }

    func registerDevice(token: String, environment: String) async throws {
        struct Body: Encodable { let token: String; let environment: String }
        struct Ok: Decodable { let ok: Bool }
        let _: Ok = try await request(
            path: "devices",
            method: "POST",
            body: encode(Body(token: token, environment: environment))
        )
    }

    func listFeelings() async throws -> [Feeling] {
        try await request(path: "feelings", method: "GET")
    }

    func upsertFeeling(preset: String, note: String) async throws -> Feeling {
        let body = FeelingRequest(preset: preset, note: note)
        return try await request(path: "feelings", method: "POST", body: encode(body))
    }

    func createCouple() async throws -> Couple {
        try await request(path: "couples", method: "POST")
    }

    func joinCouple(inviteCode: String) async throws -> Couple {
        let body = JoinCoupleRequest(inviteCode: inviteCode)
        return try await request(path: "couples/join", method: "POST", body: encode(body))
    }

    func currentCouple() async throws -> Couple {
        try await request(path: "couples/current", method: "GET")
    }

    func leaveCouple() async throws -> LeaveCoupleResponse {
        try await request(path: "couples/leave", method: "POST")
    }

    func listCoupons() async throws -> [Coupon] {
        try await request(path: "coupons", method: "GET")
    }

    func createCoupon(title: String, description: String, category: String, usesTotal: Int) async throws -> Coupon {
        let body = CreateCouponRequest(
            title: title,
            description: description,
            category: category,
            usesTotal: usesTotal
        )
        return try await request(path: "coupons", method: "POST", body: encode(body))
    }

    func useCoupon(id: UUID) async throws -> Coupon {
        try await request(path: "coupons/\(id.uuidString.lowercased())/use", method: "POST")
    }


    func listOffers(couponId: UUID) async throws -> [NegotiationOffer] {
        try await request(path: "coupons/\(couponId.uuidString.lowercased())/offers", method: "GET")
    }

    func createOffer(couponId: UUID, whenText: String, rewardText: String, notes: String) async throws -> NegotiationOffer {
        let body = OfferRequest(whenText: whenText, rewardText: rewardText, notes: notes)
        return try await request(
            path: "coupons/\(couponId.uuidString.lowercased())/offers",
            method: "POST",
            body: encode(body)
        )
    }

    func offerInbox() async throws -> [NegotiationOffer] {
        try await request(path: "offers/inbox", method: "GET")
    }

    func acceptOffer(id: UUID) async throws -> NegotiationOffer {
        try await request(path: "offers/\(id.uuidString.lowercased())/accept", method: "POST")
    }

    func declineOffer(id: UUID) async throws -> NegotiationOffer {
        try await request(path: "offers/\(id.uuidString.lowercased())/decline", method: "POST")
    }

    func counterOffer(id: UUID, whenText: String, rewardText: String, notes: String) async throws -> NegotiationOffer {
        let body = OfferRequest(whenText: whenText, rewardText: rewardText, notes: notes)
        return try await request(
            path: "offers/\(id.uuidString.lowercased())/counter",
            method: "POST",
            body: encode(body)
        )
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

    // Defaults to sending the Keychain-backed JWT as Authorization: Bearer;
    // only register and login pass false.
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
