//
//  UserStructs.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 29/8/2026.
//

struct User: Codable {
    let id: Int
    let name: String
    let username: String
    let availableCoupons: [Coupon]
    let availablePoints: Int
    let spentPoints: Int
}

struct LoveMeter: Codable {
    let lastUpdated: String
    let meterValue: Int
}
