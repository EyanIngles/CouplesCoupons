//
//  MockData.swift
//  CouplesCoupons
//
//  Created by Eyan Ingles on 6/9/2026.
//

import Foundation

enum MockData {
    static let coupons: [Coupon] = [
        Coupon(
            id: 1,
            title: "Free Massage",
            description: "A full 60-minute massage, no questions asked.",
            value: "60 min",
            redeemableCoupons: 3,
            type: .Massage,
            upgradeStatus: UpgradeCoupon(
                id: 1,
                standardCouponsAvailable: 3,
                upgradeRequestsCurrent: 0,
                upgradeCouponAvailable: 1,
                currentUpgraded: false,
                usedUpgraded: 0,
                usedStandard: 1
            ),
            couponStatus: .active,
            createdBy: "Partner",
            redeemedBy: nil,
            createdAt: Date().addingTimeInterval(-86400 * 5),
            expiresAt: Date().addingTimeInterval(86400 * 30),
            upgradable: true
        ),
        Coupon(
            id: 2,
            title: "Date Night",
            description: "You pick the plan. Dinner, a walk, or staying in.",
            value: "1 evening",
            redeemableCoupons: 2,
            type: .Date,
            upgradeStatus: UpgradeCoupon(
                id: 2,
                standardCouponsAvailable: 2,
                upgradeRequestsCurrent: 0,
                upgradeCouponAvailable: 1,
                currentUpgraded: false,
                usedUpgraded: 0,
                usedStandard: 0
            ),
            couponStatus: .active,
            createdBy: "Partner",
            redeemedBy: nil,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            expiresAt: Date().addingTimeInterval(86400 * 45),
            upgradable: true
        ),
        Coupon(
            id: 3,
            title: "Dinner for Two",
            description: "Your favourite meal, cooked at home.",
            value: "1 dinner",
            redeemableCoupons: 2,
            type: .Food,
            upgradeStatus: UpgradeCoupon(
                id: 3,
                standardCouponsAvailable: 2,
                upgradeRequestsCurrent: 0,
                upgradeCouponAvailable: 0,
                currentUpgraded: false,
                usedUpgraded: 0,
                usedStandard: 2
            ),
            couponStatus: .redeemed,
            createdBy: "Partner",
            redeemedBy: "eyan",
            createdAt: Date().addingTimeInterval(-86400 * 20),
            expiresAt: nil,
            upgradable: false
        ),
        Coupon(
            id: 4,
            title: "Spa Morning",
            description: "Slow morning, face mask, and a hot drink in bed.",
            value: "Beauty treat",
            redeemableCoupons: 1,
            type: .Beauty,
            upgradeStatus: UpgradeCoupon(
                id: 4,
                standardCouponsAvailable: 1,
                upgradeRequestsCurrent: 0,
                upgradeCouponAvailable: 1,
                currentUpgraded: true,
                usedUpgraded: 0,
                usedStandard: 0
            ),
            couponStatus: .upgraded,
            createdBy: "Partner",
            redeemedBy: nil,
            createdAt: Date().addingTimeInterval(-86400 * 8),
            expiresAt: Date().addingTimeInterval(86400 * 14),
            upgradable: true
        ),
        Coupon(
            id: 5,
            title: "Movie Night Choice",
            description: "You choose the film. Snacks included.",
            value: "1 movie night",
            redeemableCoupons: 4,
            type: .Date,
            upgradeStatus: UpgradeCoupon(
                id: 5,
                standardCouponsAvailable: 4,
                upgradeRequestsCurrent: 0,
                upgradeCouponAvailable: 0,
                currentUpgraded: false,
                usedUpgraded: 0,
                usedStandard: 1
            ),
            couponStatus: .active,
            createdBy: "Partner",
            redeemedBy: nil,
            createdAt: Date().addingTimeInterval(-86400 * 1),
            expiresAt: Date().addingTimeInterval(86400 * 60),
            upgradable: false
        ),
        Coupon(
            id: 6,
            title: "Breakfast in Bed",
            description: "Coffee, something warm, and no alarm.",
            value: "1 breakfast",
            redeemableCoupons: 2,
            type: .Food,
            upgradeStatus: UpgradeCoupon(
                id: 6,
                standardCouponsAvailable: 2,
                upgradeRequestsCurrent: 0,
                upgradeCouponAvailable: 0,
                currentUpgraded: false,
                usedUpgraded: 0,
                usedStandard: 0
            ),
            couponStatus: .expired,
            createdBy: "Partner",
            redeemedBy: nil,
            createdAt: Date().addingTimeInterval(-86400 * 40),
            expiresAt: Date().addingTimeInterval(-86400 * 2),
            upgradable: false
        )
    ]
}
