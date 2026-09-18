import SwiftUI

struct OfferInboxView: View {
    @State private var offers: [NegotiationOffer] = []
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            if offers.isEmpty {
                Text("No open offers waiting for you.")
                    .foregroundStyle(WarmPalette.pink)
                    .padding()
            } else {
                List(offers) { offer in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(offer.couponTitle).font(.headline)
                        Text("From \(offer.proposedByName)")
                        Text("When: \(offer.whenText)")
                        Text("Reward: \(offer.rewardText)")
                    }
                    .foregroundStyle(WarmPalette.pink)
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Offers")
        .task { await load() }
        .overlay {
            if let errorMessage {
                Text(errorMessage).foregroundStyle(WarmPalette.pink)
            }
        }
    }

    @MainActor
    private func load() async {
        do {
            offers = try await APIClient.shared.offerInbox()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
