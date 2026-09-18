import SwiftUI

struct FeelingsCard: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var feelings: [Feeling] = []
    @State private var note = ""
    @State private var errorMessage: String?
    @State private var isWorking = false

    private var myToday: Feeling? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let c = calendar.dateComponents([.year, .month, .day], from: Date())
        let today = String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
        return feelings.first { $0.authorId == authManager.currentUser?.id && $0.day == today }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How are you today?")
                .font(.headline)
                .foregroundStyle(WarmPalette.pink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FeelingPreset.allCases) { preset in
                        Button {
                            Task { await send(preset) }
                        } label: {
                            Text(preset.label)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(myToday?.preset == preset.rawValue ? WarmPalette.pink : .white)
                                )
                                .foregroundStyle(myToday?.preset == preset.rawValue ? .white : WarmPalette.pink)
                                .overlay(Capsule().stroke(WarmPalette.softPink, lineWidth: 1))
                        }
                        .disabled(isWorking)
                    }
                }
            }

            TextField("Optional note", text: $note)
                .warmField()

            if let errorMessage {
                Text(errorMessage).font(.caption).foregroundStyle(WarmPalette.pink)
            }

            ForEach(feelings.prefix(6)) { feeling in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(feeling.authorName) · \(FeelingPreset(rawValue: feeling.preset)?.label ?? feeling.preset)")
                        .font(.subheadline.weight(.medium))
                    if !feeling.note.isEmpty {
                        Text(feeling.note).font(.caption)
                    }
                    Text(feeling.day).font(.caption2).opacity(0.7)
                }
                .foregroundStyle(WarmPalette.pink)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 22).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(WarmPalette.softPink.opacity(0.6), lineWidth: 1))
        .padding(.horizontal, 20)
        .task { await load() }
    }

    @MainActor
    private func load() async {
        do {
            feelings = try await APIClient.shared.listFeelings()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func send(_ preset: FeelingPreset) async {
        isWorking = true
        defer { isWorking = false }
        do {
            _ = try await APIClient.shared.upsertFeeling(
                preset: preset.rawValue,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
