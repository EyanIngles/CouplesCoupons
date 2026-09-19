//
//  Home.swift
//  Ingles_app
//
//  Created by Eyan Ingles on 28/8/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var notificationRouter: NotificationRouter
    @State private var navigationPath = NavigationPath()
    
    // MARK: - Colours
    private let pink = Color(red: 0.89, green: 0.27, blue: 0.45)
    private let softPink = Color(red: 0.96, green: 0.75, blue: 0.80)
    private let cream = Color(red: 0.98, green: 0.95, blue: 0.90)
    private let gold = Color(red: 0.85, green: 0.70, blue: 0.35)
    
    // MARK: - Dummy data
    @State private var loveLevel: Double = 0.88
    @State private var userPoints: Int = 140
    
    private let questionOfTheDay = "What’s my favourite way to spend a rainy Sunday with you?"
    private let correctAnswerHint = "Hint: involves blankets + something warm"
    
    private let pointCoupons: [PointCoupon] = [
        PointCoupon(id: 1, title: "Breakfast in Bed", pointsCost: 50, emoji: "🥐"),
        PointCoupon(id: 2, title: "Movie Night Choice", pointsCost: 30, emoji: "🍿"),
        PointCoupon(id: 3, title: "30-min Massage", pointsCost: 80, emoji: "💆‍♀️"),
        PointCoupon(id: 4, title: "Cook Your Favourite", pointsCost: 60, emoji: "🍝")
    ]
    
    private let newsItems: [NewsItem] = [
        NewsItem(id: 1, title: "New coupons just dropped", subtitle: "Check the offers section", date: "Today"),
        NewsItem(id: 2, title: "Love meter is glowing", subtitle: "You’re both doing amazing", date: "Yesterday")
    ]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                cream.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // MARK: - Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Good morning")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(pink)
                                Text("You have \(userPoints) points")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            
                            NavigationLink(destination: AccountView()) {
                                Circle()
                                    .fill(softPink.opacity(0.4))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "person.crop.circle.fill")
                                            .foregroundStyle(pink)
                                    )
                            }
                            .accessibilityLabel("Account")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        // MARK: - My Coupons
                        NavigationLink(destination: CouponList()) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(softPink.opacity(0.45))
                                        .frame(width: 52, height: 52)
                                    
                                    Image(systemName: "ticket.fill")
                                        .font(.title3)
                                        .foregroundStyle(pink)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("My Coupons")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    Text("View & redeem your current coupons")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(pink.opacity(0.7))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(softPink.opacity(0.6), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)

                        NavigationLink(destination: OfferInboxView()) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(softPink.opacity(0.45))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .font(.title3)
                                        .foregroundStyle(pink)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Pending offers")
                                        .font(.headline)
                                        .foregroundStyle(pink)
                                    Text("Accept, decline, or counter")
                                        .font(.caption)
                                        .foregroundStyle(pink.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(pink.opacity(0.7))
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 20).fill(.white))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(softPink.opacity(0.6), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)

                        FeelingsCard()
                        
                        // MARK: - Question of the Day
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Question of the Day", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundStyle(pink)
                            
                            Text(questionOfTheDay)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                            
                            Text(correctAnswerHint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Button {
                                // later: open answer sheet + AI check
                            } label: {
                                Text("Answer & Earn Points")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(pink))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(softPink.opacity(0.6), lineWidth: 1))
                        .padding(.horizontal, 20)
                        
                        // MARK: - Point Coupons
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Spend Your Points")
                                    .font(.headline)
                                    .foregroundStyle(pink)
                                Spacer()
                                Text("\(userPoints) pts")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                ForEach(pointCoupons) { coupon in
                                    PointCouponCard(coupon: coupon, pink: pink, softPink: softPink, userPoints: userPoints)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - News & Updates
                        VStack(alignment: .leading, spacing: 12) {
                            Text("News & Updates")
                                .font(.headline)
                                .foregroundStyle(pink)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 10) {
                                ForEach(newsItems) { item in
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(softPink.opacity(0.5))
                                            .frame(width: 10, height: 10)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.title)
                                                .font(.subheadline.weight(.medium))
                                            Text(item.subtitle)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(item.date)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white))
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Love Meter
                        VStack(spacing: 12) {
                            Text("Love Meter")
                                .font(.headline)
                                .foregroundStyle(pink)
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(softPink.opacity(0.35))
                                    .frame(height: 22)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [pink, gold],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: UIScreen.main.bounds.width * 0.7 * loveLevel, height: 22)
                                
                                HStack {
                                    Spacer()
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white)
                                        .padding(6)
                                        .background(Circle().fill(pink))
                                        .offset(x: 4)
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.7 * loveLevel)
                            }
                            .padding(.horizontal, 8)
                            
                            Text(loveLevelText)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(pink.opacity(0.9))
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.white)
                                .shadow(color: pink.opacity(0.08), radius: 12, y: 5)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: NotificationDestination.self) { destination in
                switch destination {
                case .couponBank:
                    CouponList()
                case .offerInbox:
                    OfferInboxView()
                case .feelings:
                    EmptyView()
                }
            }
        }
        .onAppear(perform: openPendingDestination)
        .onChange(of: notificationRouter.pendingDestination) {
            openPendingDestination()
        }
    }

    private func openPendingDestination() {
        guard let destination = notificationRouter.takePendingDestination() else { return }

        navigationPath = NavigationPath()
        switch destination {
        case .couponBank, .offerInbox:
            navigationPath.append(destination)
        case .feelings:
            break
        }
    }
    
    private var loveLevelText: String {
        switch loveLevel {
        case 0.9...1.0: return "Overflowing with love ❤️"
        case 0.75..<0.9: return "So full of effort & care"
        case 0.5..<0.75: return "Feeling really loved"
        default: return "Building something beautiful"
        }
    }
}

// MARK: - Point Coupon Card
struct PointCouponCard: View {
    let coupon: PointCoupon
    let pink: Color
    let softPink: Color
    let userPoints: Int
    
    private var canAfford: Bool {
        userPoints >= coupon.pointsCost
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text(coupon.emoji)
                .font(.system(size: 32))
            
            Text(coupon.title)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            
            Text("\(coupon.pointsCost) pts")
                .font(.caption.weight(.medium))
                .foregroundStyle(canAfford ? pink : .secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 130)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(canAfford ? softPink : Color.gray.opacity(0.2), lineWidth: 1.2)
        )
        .opacity(canAfford ? 1.0 : 0.55)
    }
}

// MARK: - Simple models (file level)
struct PointCoupon: Identifiable {
    let id: Int
    let title: String
    let pointsCost: Int
    let emoji: String
}

struct NewsItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let date: String
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
        .environmentObject(NotificationRouter.shared)
}
