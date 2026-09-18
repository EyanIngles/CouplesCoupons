import Foundation

enum AppVersion {
    static var current: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    static let lastSeenKey = "lastSeenAppVersion"

    static var lastSeen: String {
        get { UserDefaults.standard.string(forKey: lastSeenKey) ?? "0.0.0" }
        set { UserDefaults.standard.set(newValue, forKey: lastSeenKey) }
    }

    /// true if `lhs` is strictly older than `rhs` (major.minor.patch).
    static func isOlder(_ lhs: String, than rhs: String) -> Bool {
        parts(lhs).lexicographicallyPrecedes(parts(rhs))
    }

    static func parts(_ version: String) -> [Int] {
        let nums = version.split(separator: ".").prefix(3).map { Int($0) ?? 0 }
        return nums + Array(repeating: 0, count: max(0, 3 - nums.count))
    }
}

nonisolated struct VersionResponse: Decodable, Sendable {
    let api: String
    let minApp: String
}

struct ChangelogEntry: Identifiable {
    let version: String
    let notes: [String]
    var id: String { version }
}

enum Changelog {
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
    ]

    static func notes(after lastSeen: String, upTo current: String) -> [ChangelogEntry] {
        entries.filter { entry in
            AppVersion.isOlder(lastSeen, than: entry.version)
                && !AppVersion.isOlder(current, than: entry.version)
        }
    }
}
