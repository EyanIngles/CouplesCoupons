import Foundation
import UIKit
import UserNotifications

enum PushRegistration {
    static func requestAfterLogin() {
        Task { @MainActor in
            let granted = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            guard granted == true else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    static func sendTokenToServer(_ deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        #if DEBUG
        let environment = "sandbox"
        #else
        let environment = "production"
        #endif
        Task {
            try? await APIClient.shared.registerDevice(token: token, environment: environment)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushRegistration.sendTokenToServer(deviceToken)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        guard let payload = PushNotificationPayload(userInfo: notification.request.content.userInfo) else {
            return [.banner, .sound, .badge]
        }

        NotificationRouter.shared.queuePrompt(for: payload)
        return [.sound, .badge]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let payload = PushNotificationPayload(userInfo: response.notification.request.content.userInfo) else {
            return
        }

        NotificationRouter.shared.queueDestination(for: payload)
    }
}
