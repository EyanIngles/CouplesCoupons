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


nonisolated struct VersionResponse: Decodable, Sendable {
    let api: String
    let minApp: String
}

nonisolated struct ChangelogEntry: Identifiable, Sendable, Equatable {
    let version: String
    let notes: [String]
    var id: String { version }
}

nonisolated enum AppVersion {
    static var current: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    static let lastSeenKey = "lastSeenAppVersion"

    static var lastSeen: String {
        get { UserDefaults.standard.string(forKey: lastSeenKey) ?? "0.0.0" }
        set { UserDefaults.standard.set(newValue, forKey: lastSeenKey) }
    }

    static func isOlder(_ lhs: String, than rhs: String) -> Bool {
        parts(lhs).lexicographicallyPrecedes(parts(rhs))
    }

    static func parts(_ version: String) -> [Int] {
        let nums = version.split(separator: ".").prefix(3).map { Int($0) ?? 0 }
        return nums + Array(repeating: 0, count: max(0, 3 - nums.count))
    }
}

nonisolated struct Feeling: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let authorId: UUID
    let authorName: String
    let preset: String
    let note: String
    let day: String
    let createdAt: String
}

nonisolated struct FeelingRequest: Encodable, Sendable {
    let preset: String
    let note: String
}

enum FeelingPreset: String, CaseIterable, Identifiable {
    case grateful, missing_you, low_energy, sad, loved, thinking_of_you
    var id: String { rawValue }
    var label: String {
        switch self {
        case .grateful: "Grateful"
        case .missing_you: "Missing you"
        case .low_energy: "Low energy"
        case .sad: "Sad"
        case .loved: "Loved"
        case .thinking_of_you: "Thinking of you"
        }
    }
}

nonisolated enum Changelog {
    static let entries: [ChangelogEntry] = [
        ChangelogEntry(version: "0.0.1", notes: [
            "Email login and invite-code pairing",
        ]),
        ChangelogEntry(version: "0.0.2", notes: [
            "Send coupons into your partner’s bank",
            "Use tracking and weekly caps",
            "Light theme so dark mode is readable",
        ]),
        ChangelogEntry(version: "0.0.3", notes: [
            "Negotiate a coupon use (offer, counter, accept)",
            "Partner name and email on Account",
            "App and server version on Account",
        ]),
        ChangelogEntry(version: "0.0.4", notes: [
            "Daily feelings: tell your partner how you are today",
        ]),
        ChangelogEntry(version: "0.0.5", notes: [
            "Ask for notifications so your partner’s coupons and feelings can ping you",
        ]),
    ]

    static func notes(after lastSeen: String, upTo current: String) -> [ChangelogEntry] {
        entries.filter { entry in
            AppVersion.isOlder(lastSeen, than: entry.version)
                && !AppVersion.isOlder(current, than: entry.version)
        }
    }
}
