//
//  Login.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let id: Int
    let token: String
    let expiry: Int
    
}
