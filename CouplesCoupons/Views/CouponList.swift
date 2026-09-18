import SwiftUI

struct CouponList: View {
    @State private var coupons: [Coupon] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showingCompose = false

    var body: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            if isLoading && coupons.isEmpty {
                ProgressView().tint(WarmPalette.pink)
            } else if coupons.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "ticket")
                        .font(.system(size: 44))
                        .foregroundStyle(WarmPalette.pink)
                    Text("Your bank is empty")
                        .font(.headline)
                        .foregroundStyle(WarmPalette.pink)
                    Text("Ask your partner to send you a coupon, or send them one with +")
                        .font(.subheadline)
                        .foregroundStyle(WarmPalette.pink.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(coupons) { coupon in
                            NavigationLink(destination: CouponDetail(coupon: coupon, onChange: { await load() })) {
                                CouponCard(coupon: coupon)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("Coupons")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCompose = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(WarmPalette.pink)
                }
            }
        }
        .sheet(isPresented: $showingCompose, onDismiss: { Task { await load() } }) {
            NavigationStack { ComposeCouponView() }
        }
        .task { await load() }
        .overlay(alignment: .bottom) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding()
                    .background(WarmPalette.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
    }

    @MainActor
    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            coupons = try await APIClient.shared.listCoupons()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct CouponCard: View {
    let coupon: Coupon

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: CouponCategory(rawValue: coupon.category)?.systemImage ?? "ticket.fill")
                .font(.title2)
                .foregroundStyle(WarmPalette.pink)
            Text(coupon.title)
                .font(.headline)
                .foregroundStyle(WarmPalette.pink)
                .lineLimit(2)
            Text(coupon.categoryLabel)
                .font(.caption)
                .foregroundStyle(WarmPalette.pink.opacity(0.7))
            Text("\(coupon.usesRemaining)/\(coupon.usesTotal) uses")
                .font(.caption.weight(.medium))
                .foregroundStyle(WarmPalette.pink)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(WarmPalette.softPink, lineWidth: 1.2))
    }
}

#Preview {
    NavigationStack { CouponList() }
}
