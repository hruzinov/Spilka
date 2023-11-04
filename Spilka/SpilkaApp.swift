//
//  Created by Evhen Gruzinov on 10.09.2023.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _:
                     [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\(#function)")
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }

    func application(_: UIApplication, didReceiveRemoteNotification notification: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(#function)")
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }

    func application(_: UIApplication, open url: URL,
                     options _: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        print("\(#function)")
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
//    func application(_ app: UIApplication,
//                     open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
}

@main
struct SpilkaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
//            TestingView()
        }
    }
}
