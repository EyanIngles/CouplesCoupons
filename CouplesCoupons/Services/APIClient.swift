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
    
    private let baseURL = URL(string: "https://your-server.com/api")!   // ← change this
    private var authToken: String?
    
    func setToken(_ token: String) {
        authToken = token
    }
    
    // MARK: - Coupons
    func fetchCoupons() {//async throws -> [Coupon] {
        //try await request(path: "/coupons", method: "GET")
    }
    
    func createCoupon(_ coupon: CreateCouponRequest) {//async throws -> Coupon {
        //try await request(path: "/coupons", method: "POST", body: coupon)
    }
    
    func redeemCoupon(id: String) {//async throws -> Coupon {
        //try await request(path: "/coupons/\(id)/redeem", method: "POST")
    }
    
    func shareCoupon(id: String, withFriendCode: String) async throws {
        struct Body: Codable { let friendCode: String }
        //try await request(path: "/coupons/\(id)/share", method: "POST", body: Body(friendCode: withFriendCode))
    }
    
    // MARK: - Auth / Pairing
    func login(withFriendCode code: String) {//async throws -> AuthResponse {
        struct Body: Codable { let friendCode: String }
        //return try await request(path: "/auth/pair", method: "POST", body: Body(friendCode: code))
    }

    // Generic helper
    private     func request<T: Decodable>(
        path: String,
        method: String,
        body: Codable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw APIError.serverError
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

struct CreateCouponRequest: Codable {
    let title: String
    let description: String
    let value: String
    let type: Coupon.CouponType
    let expiresAt: Date?
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

enum APIError: Error {
    case serverError
}
