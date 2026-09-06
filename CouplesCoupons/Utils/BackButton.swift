//
//  BackButton.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//
import SwiftUI

struct PinkBackButton: View {
    let action: () -> Void
    
    private let pink = Color(red: 0.89, green: 0.27, blue: 0.45)
    private let softPink = Color(red: 0.96, green: 0.75, blue: 0.80)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                
                Text("Back")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(pink)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.white)
                    .shadow(color: pink.opacity(0.12), radius: 8, y: 3)
            )
            .overlay(
                Capsule()
                    .stroke(softPink.opacity(0.7), lineWidth: 1)
            )
        }
    }
}
