//
//  CouponList.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

import SwiftUI

struct CouponList: View {

    // Same colours as Login
    private let pink = Color(red: 0.89, green: 0.27, blue: 0.45)
    private let softPink = Color(red: 0.96, green: 0.75, blue: 0.80)
    private let cream = Color(red: 0.98, green: 0.95, blue: 0.90)

    private let coupons = MockData.coupons

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            cream.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Our Coupons")
                            .font(.largeTitle.bold())
                            .foregroundStyle(pink)

                        Text("Little treats just for us")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(coupons) { coupon in
                            NavigationLink(destination: CouponDetail(coupon: coupon)) {
                                CouponCard(
                                    title: coupon.title,
                                    value: coupon.value,
                                    type: coupon.type.rawValue,
                                    status: coupon.couponStatus.rawValue,
                                    pink: pink,
                                    softPink: softPink
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Coupons")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // future: create new coupon
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(pink)
                }
            }
        }
    }
}

struct CouponCard: View {
    let title: String
    let value: String
    let type: String
    let status: String
    let pink: Color
    let softPink: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: pink.opacity(0.08), radius: 12, y: 6)
                .frame(height: 160)

            VStack(spacing: 10) {
                Image(systemName: type == "Massage" ? "hands.sparkles.fill" : type == "Date" ? "heart.fill" : type == "Food" ? "fork.knife" : "sparkles")
                    .font(.title3)
                    .foregroundStyle(pink)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(status.capitalized)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(pink.opacity(0.8))
            }
            .padding(16)
        }
    }
}

#Preview {
    NavigationStack {
        CouponList()
    }
}
