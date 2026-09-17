//
//  Ingles_appApp.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

import SwiftUI

@main
struct CouplesCoupons: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
