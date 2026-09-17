//
//  constants.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//
import Foundation

nonisolated enum Constants {
    /// Always-on Pi over Tailscale. Both TestFlight phones must be on the same tailnet.
    static let apiBaseURL = URL(string: "http://pi.tailcb4684.ts.net:3001")!
}
