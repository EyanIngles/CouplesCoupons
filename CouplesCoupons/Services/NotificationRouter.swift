import Combine
import Foundation

enum NotificationDestination: Hashable {
    case couponBank(couponID: String?)
    case offerInbox(offerID: String?, couponID: String?)
    case feelings(feelingID: String?)
}

struct PushNotificationPayload {
    let destination: NotificationDestination

    init?(userInfo: [AnyHashable: Any]) {
        guard let kind = userInfo["kind"] as? String else { return nil }

        switch kind {
        case "coupon_bank":
            destination = .couponBank(couponID: userInfo["coupon_id"] as? String)
        case "offer_inbox":
            destination = .offerInbox(
                offerID: userInfo["offer_id"] as? String,
                couponID: userInfo["coupon_id"] as? String
            )
        case "feelings":
            destination = .feelings(feelingID: userInfo["feeling_id"] as? String)
        default:
            return nil
        }
    }
}

struct NotificationPrompt: Identifiable {
    let id = UUID()
    let destination: NotificationDestination

    var title: String {
        switch destination {
        case .couponBank:
            "New coupon"
        case .offerInbox:
            "New coupon offer"
        case .feelings:
            "Your partner shared a feeling"
        }
    }

    var message: String {
        switch destination {
        case .couponBank:
            "You have a new coupon in your bank. Want to see?"
        case .offerInbox, .feelings:
            "Want to see it?"
        }
    }
}

@MainActor
final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()

    @Published var pendingPrompt: NotificationPrompt?
    @Published private(set) var pendingDestination: NotificationDestination?

    private init() {}

    func queuePrompt(for payload: PushNotificationPayload) {
        pendingPrompt = NotificationPrompt(destination: payload.destination)
    }

    func queueDestination(for payload: PushNotificationPayload) {
        pendingDestination = payload.destination
    }

    func queueDestination(_ destination: NotificationDestination) {
        pendingDestination = destination
    }

    func takePendingDestination() -> NotificationDestination? {
        defer { pendingDestination = nil }
        return pendingDestination
    }
}
