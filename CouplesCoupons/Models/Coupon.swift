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

nonisolated struct NegotiationOffer: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let couponId: UUID
    let couponTitle: String
    let proposedBy: UUID
    let proposedByName: String
    let whenText: String
    let rewardText: String
    let notes: String
    let status: String
    let createdAt: String
}

nonisolated struct OfferRequest: Encodable, Sendable {
    let whenText: String
    let rewardText: String
    let notes: String
}
