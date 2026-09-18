import Foundation

nonisolated struct Coupon: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let coupleId: UUID
    let createdBy: UUID
    let assignedTo: UUID
    let title: String
    let description: String
    let category: String
    let usesTotal: Int
    let usesRemaining: Int
    let status: String
    let createdAt: String

    var categoryLabel: String { category.capitalized }
}

nonisolated struct CreateCouponRequest: Encodable, Sendable {
    let title: String
    let description: String
    let category: String
    let usesTotal: Int
}

enum CouponCategory: String, CaseIterable, Identifiable {
    case massage, date, food, beauty, custom
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var systemImage: String {
        switch self {
        case .massage: "hands.sparkles.fill"
        case .date: "heart.fill"
        case .food: "fork.knife"
        case .beauty: "sparkles"
        case .custom: "pencil"
        }
    }
}
