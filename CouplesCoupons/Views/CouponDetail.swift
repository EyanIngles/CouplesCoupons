import SwiftUI

struct CouponDetail: View {
    @EnvironmentObject private var authManager: AuthManager
    @State var coupon: Coupon
    var onChange: () async -> Void = {}
    @State private var offers: [NegotiationOffer] = []
    @State private var whenText = ""
    @State private var rewardText = ""
    @State private var notes = ""
    @State private var isWorking = false
    @State private var errorMessage: String?
    @State private var showingCounter = false

    private var me: UUID? { authManager.currentUser?.id }
    private var openOffer: NegotiationOffer? { offers.last { $0.status == "open" } }
    private var isHolder: Bool { me == coupon.assignedTo }

    var body: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
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

                    if let openOffer {
                        offerCard(openOffer)
                    } else if isHolder, coupon.status == "active", coupon.usesRemaining > 0 {
                        proposeForm
                    }

                    if !offers.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("History")
                                .font(.headline)
                                .foregroundStyle(WarmPalette.pink)
                            ForEach(offers) { offer in
                                Text("\(offer.proposedByName) · \(offer.status): \(offer.whenText) / \(offer.rewardText)")
                                    .font(.caption)
                                    .foregroundStyle(WarmPalette.pink.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(28)
            }
        }
        .navigationTitle(coupon.categoryLabel)
        .navigationBarTitleDisplayMode(.inline)
        .task { await refresh() }
        .sheet(isPresented: $showingCounter) {
            NavigationStack {
                counterForm
            }
        }
    }

    @ViewBuilder
    private func offerCard(_ offer: NegotiationOffer) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Open offer from \(offer.proposedByName)")
                .font(.headline)
                .foregroundStyle(WarmPalette.pink)
            Text("When: \(offer.whenText)")
            Text("Reward: \(offer.rewardText)")
            if !offer.notes.isEmpty { Text("Note: \(offer.notes)") }
            if offer.proposedBy == me {
                Text("Waiting for your partner…")
                    .font(.subheadline)
                    .foregroundStyle(WarmPalette.pink.opacity(0.7))
            } else {
                HStack {
                    Button("Accept") { Task { await act { try await APIClient.shared.acceptOffer(id: offer.id) } } }
                    Button("Decline", role: .destructive) { Task { await act { try await APIClient.shared.declineOffer(id: offer.id) } } }
                    Button("Counter") { showingCounter = true }
                }
                .buttonStyle(WarmPrimaryButtonStyle())
                .disabled(isWorking)
            }
        }
        .foregroundStyle(WarmPalette.pink)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
    }

    private var proposeForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Propose a use")
                .font(.headline)
                .foregroundStyle(WarmPalette.pink)
            TextField("When (e.g. Saturday night)", text: $whenText).warmField()
            TextField("Reward for them", text: $rewardText).warmField()
            TextField("Note (optional)", text: $notes).warmField()
            Button {
                Task { await propose() }
            } label: {
                if isWorking { ProgressView().tint(.white) } else { Text("Send offer") }
            }
            .buttonStyle(WarmPrimaryButtonStyle())
            .disabled(isWorking)
        }
    }

    private var counterForm: some View {
        Form {
            TextField("When", text: $whenText)
            TextField("Reward", text: $rewardText)
            TextField("Note", text: $notes)
            Button("Send counter") {
                Task { await counter() }
            }
            .disabled(isWorking)
        }
        .navigationTitle("Counter")
        .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { showingCounter = false } } }
    }

    @MainActor
    private func refresh() async {
        do {
            offers = try await APIClient.shared.listOffers(couponId: coupon.id)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func propose() async {
        let when = whenText.trimmingCharacters(in: .whitespacesAndNewlines)
        let reward = rewardText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !when.isEmpty, !reward.isEmpty else {
            errorMessage = "Say when, and what you’ll give them."
            return
        }
        await act {
            _ = try await APIClient.shared.createOffer(
                couponId: coupon.id,
                whenText: when,
                rewardText: reward,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }

    @MainActor
    private func counter() async {
        guard let openOffer else { return }
        let when = whenText.trimmingCharacters(in: .whitespacesAndNewlines)
        let reward = rewardText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !when.isEmpty, !reward.isEmpty else { return }
        await act {
            _ = try await APIClient.shared.counterOffer(
                id: openOffer.id,
                whenText: when,
                rewardText: reward,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            showingCounter = false
        }
    }

    @MainActor
    private func act(_ work: () async throws -> Void) async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            try await work()
            await refresh()
            await onChange()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
