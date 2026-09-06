//
//  ContentView.swift
//  CouplesCoupons
//
//  Created by Eyan Ingles on 31/8/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                HomeView()
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}

// Placeholder for shared resources or state if you need them later.
//class ContentViewData: ObservableObject {} //TODO

#Preview {
    ContentView()
}
