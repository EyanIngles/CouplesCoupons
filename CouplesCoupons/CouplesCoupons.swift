import SwiftUI

@main
struct CouplesCoupons: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var authManager = AuthManager()
    @StateObject private var notificationRouter = NotificationRouter.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(notificationRouter)
        }
    }
}
