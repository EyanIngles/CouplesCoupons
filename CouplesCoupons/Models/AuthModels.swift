import Foundation

nonisolated struct User: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let email: String
    let displayName: String
}

nonisolated struct RegisterRequest: Encodable, Sendable {
    let email: String
    let password: String
    let displayName: String
}

nonisolated struct LoginRequest: Encodable, Sendable {
    let email: String
    let password: String
}

nonisolated struct AuthResponse: Decodable, Sendable {
    let token: String
    let user: User
}

nonisolated enum CoupleStatus: String, Codable, Sendable {
    case pending
    case active
}

nonisolated struct CoupleMember: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let displayName: String
    let email: String
}

nonisolated struct CoupleEntitlements: Codable, Equatable, Sendable {
    let canNegotiate: Bool
    let templatePack: String
    let weeklySendLimit: Int
    let weeklyUseLimit: Int
    let maxActiveBank: Int
}

nonisolated struct Couple: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let status: CoupleStatus
    let inviteCode: String
    let members: [CoupleMember]
    let entitlements: CoupleEntitlements
}

nonisolated struct JoinCoupleRequest: Encodable, Sendable {
    let inviteCode: String
}

nonisolated struct LeaveCoupleResponse: Decodable, Sendable {
    let status: String
}

nonisolated struct APIErrorResponse: Decodable, Sendable {
    let error: String
}
