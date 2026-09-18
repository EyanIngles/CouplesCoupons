import SwiftUI

struct CouponDetail: View {
    @State var coupon: Coupon
    var onChange: () async -> Void = {}
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: CouponCategory(rawValue: coupon.category)?.systemImage ?? "ticket.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(WarmPalette.pink)
                    Text(coupon.title)
                        .font(.title.bold())
                        .foregroundStyle(WarmPalette.pink)
                        .multilineTextAlignment(.center)
                    if !coupon.description.isEmpty {
                        Text(coupon.description)
                            .foregroundStyle(WarmPalette.pink.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                    Text("\(coupon.usesRemaining) of \(coupon.usesTotal) uses left")
                        .font(.headline)
                        .foregroundStyle(WarmPalette.pink)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(WarmPalette.pink)
                    }

                    Button {
                        Task { await use() }
                    } label: {
                        if isWorking {
                            ProgressView().tint(.white)
                        } else {
                            Text("Use coupon")
                        }
                    }
                    .buttonStyle(WarmPrimaryButtonStyle())
                    .disabled(isWorking || coupon.usesRemaining == 0 || coupon.status != "active")
                }
                .padding(28)
            }
        }
        .navigationTitle(coupon.categoryLabel)
        .navigationBarTitleDisplayMode(.inline)
    }

    @MainActor
    private func use() async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            coupon = try await APIClient.shared.useCoupon(id: coupon.id)
            await onChange()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
