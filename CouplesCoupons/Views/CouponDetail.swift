//
//  CouponDetail.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

import SwiftUI

struct CouponDetail: View {
    
    // MARK: - Coupon (passed in)
    let coupon: Coupon

    private var totalAvailable: Int {
        coupon.upgradeStatus.standardCouponsAvailable
    }

    private var usedCount: Int {
        coupon.upgradeStatus.usedStandard
    }

    private var isUpgraded: Bool {
        coupon.upgradeStatus.currentUpgraded
    }
    
    // Negotiation
    @State private var showingNegotiate = false
    @State private var proposalText = ""
    @State private var existingProposal: Negiotate? = nil
    
    // Upgrade Proposal
    @State private var showingUpgradeProposal = false
    @State private var upgradeProposalText = ""
    @State private var existingUpgradeProposal: Negiotate? = nil
    
    // Colours
    private let pink = Color(red: 0.89, green: 0.27, blue: 0.45)
    private let softPink = Color(red: 0.96, green: 0.75, blue: 0.80)
    private let cream = Color(red: 0.98, green: 0.95, blue: 0.90)
    private let gold = Color(red: 0.85, green: 0.70, blue: 0.35)
    
    var body: some View {
        ZStack {
            cream.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    
                    // MARK: - Hero Card
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(softPink.opacity(0.4))
                                .frame(width: 90, height: 90)
                            
                            Image(systemName: iconName(for: coupon.type))
                                .font(.system(size: 36))
                                .foregroundStyle(pink)
                        }
                        
                        Text(coupon.title)
                            .font(.title.bold())
                            .foregroundStyle(pink)
                        
                        Text(coupon.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Text(coupon.value)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 10) {
                            StatusPill(status: coupon.couponStatus, pink: pink)
                            
                            if isUpgraded {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.heart.fill")
                                    Text("Upgraded")
                                }
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(gold.opacity(0.2)))
                                .foregroundStyle(gold)
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.white)
                            .shadow(color: pink.opacity(0.1), radius: 20, y: 8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(softPink.opacity(0.6), lineWidth: 1.5)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // MARK: - Availability Circles
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Availability")
                            .font(.headline)
                            .foregroundStyle(pink)
                        
                        HStack(spacing: 14) {
                            ForEach(0..<totalAvailable, id: \.self) { index in
                                Circle()
                                    .fill(index < usedCount ? pink : Color.clear)
                                    .frame(width: 28, height: 28)
                                    .overlay(Circle().stroke(pink, lineWidth: 2.5))
                                    .overlay {
                                        if index < usedCount {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            
                            Spacer()
                            
                            Text("\(totalAvailable - usedCount) left")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white))
                    .padding(.horizontal, 20)
                    
                    // MARK: - Upgrade Perks
                    if isUpgraded {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Upgraded Perks", systemImage: "star.fill")
                                .font(.headline)
                                .foregroundStyle(gold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                PerkRow(text: "Extra 15 minutes")
                                PerkRow(text: "Choice of essential oils")
                                PerkRow(text: "Hot towel finish")
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(gold.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(gold.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Upgrade Proposal
                    if coupon.upgradable && !isUpgraded {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Upgrade")
                                .font(.headline)
                                .foregroundStyle(gold)
                            
                            if let proposal = existingUpgradeProposal {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your upgrade request")
                                        .font(.subheadline.weight(.medium))
                                    
                                    Text(proposal.description)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                    
                                    HStack {
                                        Image(systemName: proposal.negotiatedAccepted ? "checkmark.circle.fill" : "clock.fill")
                                        Text(proposal.negotiatedAccepted ? "Accepted" : "Waiting for response")
                                            .font(.subheadline.weight(.medium))
                                    }
                                    .foregroundStyle(proposal.negotiatedAccepted ? .green : .orange)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(gold.opacity(0.12)))
                            } else {
                                Text("Want more perks? Send an upgrade proposal.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Button {
                                    showingUpgradeProposal = true
                                } label: {
                                    Label("Request Upgrade", systemImage: "arrow.up.heart.fill")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(gold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white))
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Negotiate Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Negotiate")
                            .font(.headline)
                            .foregroundStyle(pink)
                        
                        if let proposal = existingProposal {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your proposal")
                                    .font(.subheadline.weight(.medium))
                                
                                Text(proposal.description)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    Image(systemName: proposal.negotiatedAccepted ? "checkmark.circle.fill" : "clock.fill")
                                    Text(proposal.negotiatedAccepted ? "Accepted" : "Waiting for response")
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(proposal.negotiatedAccepted ? .green : .orange)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(softPink.opacity(0.25)))
                        } else {
                            Text("Want to tweak this coupon? Send a proposal.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Button {
                                showingNegotiate = true
                            } label: {
                                Label("Make a Proposal", systemImage: "bubble.left.and.bubble.right.fill")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(pink))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white))
                    .padding(.horizontal, 20)
                    
                    // MARK: - Redeem Button
                    Button {
                        // redeem action later
                    } label: {
                        Text(coupon.couponStatus == .active ? "Redeem Coupon" : "Already Redeemed")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(coupon.couponStatus == .active ? pink : Color.gray.opacity(0.4))
                            )
                            .foregroundStyle(.white)
                            .shadow(color: pink.opacity(coupon.couponStatus == .active ? 0.3 : 0), radius: 12, y: 6)
                    }
                    .disabled(coupon.couponStatus != .active)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Coupon")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNegotiate) {
            NegotiateSheet(
                proposalText: $proposalText,
                accentColor: pink,
                cream: cream,
                title: "Negotiate",
                placeholder: "What would you like to propose?"
            ) { text in
                existingProposal = Negiotate(
                    id: 1,
                    description: text,
                    negotiatedAccepted: false
                )
                showingNegotiate = false
            }
        }
        .sheet(isPresented: $showingUpgradeProposal) {
            NegotiateSheet(
                proposalText: $upgradeProposalText,
                accentColor: gold,
                cream: cream,
                title: "Upgrade Request",
                placeholder: "Why should this coupon be upgraded?"
            ) { text in
                existingUpgradeProposal = Negiotate(
                    id: 2,
                    description: text,
                    negotiatedAccepted: false
                )
                showingUpgradeProposal = false
            }
        }
    }
    
    private func iconName(for type: Coupon.CouponType) -> String {
        switch type {
        case .Massage: return "hands.sparkles.fill"
        case .Date: return "heart.fill"
        case .Food: return "fork.knife"
        case .Beauty: return "sparkles"
        }
    }
}

// MARK: - Helper Views

struct StatusPill: View {
    let status: Coupon.CouponStatus
    let pink: Color
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.15)))
            .foregroundStyle(color)
    }
    
    private var color: Color {
        switch status {
        case .active: return .green
        case .redeemed: return .blue
        case .expired, .cancelled: return .gray
        case .upgraded: return pink
        }
    }
}

struct PerkRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct NegotiateSheet: View {
    @Binding var proposalText: String
    let accentColor: Color
    let cream: Color
    let title: String
    let placeholder: String
    var onSubmit: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                cream.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text(placeholder)
                        .font(.headline)
                        .foregroundStyle(accentColor)
                    
                    TextEditor(text: $proposalText)
                        .frame(minHeight: 140)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(accentColor.opacity(0.3), lineWidth: 1))
                    
                    Text("Keep it short and sweet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        guard !proposalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        onSubmit(proposalText)
                    }
                    .fontWeight(.semibold)
                    .disabled(proposalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CouponDetail(coupon: Coupon(
            id: 101,
            title: "Free Massage",
            description: "60 min session",
            value: "60 min",
            redeemableCoupons: 5,
            type: .Massage,
            upgradeStatus: UpgradeCoupon(
                id: 1,
                standardCouponsAvailable: 5,
                upgradeRequestsCurrent: 0,
                upgradeCouponAvailable: 2,
                currentUpgraded: false,
                usedUpgraded: 0,
                usedStandard: 0
            ),
            couponStatus: .active,
            createdBy: "User1",
            redeemedBy: nil,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 30),
            upgradable: true
        ))
    }
}
