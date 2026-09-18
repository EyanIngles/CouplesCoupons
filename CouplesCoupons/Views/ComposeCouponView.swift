import SwiftUI

struct ComposeCouponView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var category: CouponCategory = .date
    @State private var title = ""
    @State private var description = ""
    @State private var uses = 1
    @State private var errorMessage: String?
    @State private var isWorking = false

    var body: some View {
        ZStack {
            WarmPalette.cream.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Send a coupon")
                        .font(.title2.bold())
                        .foregroundStyle(WarmPalette.pink)

                    Text("It goes into your partner’s bank.")
                        .foregroundStyle(WarmPalette.pink.opacity(0.7))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(CouponCategory.allCases) { item in
                                Button {
                                    category = item
                                    if title.isEmpty || CouponCategory.allCases.contains(where: { $0.title == title }) {
                                        title = item == .custom ? "" : item.title
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: item.systemImage)
                                        Text(item.title).font(.caption)
                                    }
                                    .foregroundStyle(category == item ? .white : WarmPalette.pink)
                                    .padding(12)
                                    .frame(width: 84)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(category == item ? WarmPalette.pink : .white)
                                    )
                                }
                            }
                        }
                    }

                    TextField("Title", text: $title)
                        .warmField()
                    TextField("Note (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .warmField()

                    Stepper("Uses: \(uses)", value: $uses, in: 1...10)
                        .foregroundStyle(WarmPalette.pink)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(WarmPalette.pink)
                    }

                    Button {
                        Task { await send() }
                    } label: {
                        if isWorking {
                            ProgressView().tint(.white)
                        } else {
                            Text("Send to partner")
                        }
                    }
                    .buttonStyle(WarmPrimaryButtonStyle())
                    .disabled(isWorking)
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
                    .foregroundStyle(WarmPalette.pink)
            }
        }
        .onAppear {
            if title.isEmpty { title = category.title }
        }
    }

    @MainActor
    private func send() async {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Give this coupon a title."
            return
        }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            _ = try await APIClient.shared.createCoupon(
                title: trimmed,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category.rawValue,
                usesTotal: uses
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
