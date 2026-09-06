//
//  Coupon.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

// Models/Coupon.swift
import Foundation

struct Coupon: Identifiable, Codable, Equatable {
    let id: Int
    var title: String
    var description: String
    var value: String                 // e.g. "Free coffee", "$10 off", "1 free movie night"
    let redeemableCoupons: Int       // how many coupons this person can redeem.
    var type: CouponType
    var upgradeStatus: UpgradeCoupon
    let couponStatus: CouponStatus
    let createdBy: String             // userId or name.
    var redeemedBy: String?           //optional name
    let createdAt: Date
    var expiresAt: Date?
    let upgradable: Bool

    enum CouponType: String, Codable, CaseIterable {
        case Massage, Date, Food, Beauty
    }

    enum CouponStatus: String, Codable {
        case active, redeemed, expired, cancelled, upgraded
    }
}

struct UpgradeCoupon: Identifiable, Codable, Equatable {
    let id: Int
    let standardCouponsAvailable: Int
    let upgradeRequestsCurrent: Int
    let upgradeCouponAvailable: Int
    let currentUpgraded: Bool
    let usedUpgraded: Int
    let usedStandard: Int
}

struct Negiotate: Identifiable, Codable, Equatable {
    let id: Int
    let description: String
    let negotiatedAccepted: Bool
}

struct BuyablePoints: Identifiable, Codable, Equatable {
    let id: Int
    let description: String
    
}
