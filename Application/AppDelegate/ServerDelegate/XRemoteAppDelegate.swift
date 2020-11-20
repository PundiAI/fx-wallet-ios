import PluggableApplicationDelegate
import RxSwift
import SwiftyJSON
import UIKit
import WKKit
class XRemoteAppDelegate: XApplicationService, WKRemoteDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        return WKServer.application(application: app, open: url, sourceApplication: nil, annotation: nil)
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WKServer.addServer(aClass: WKRemoteServer.self, params: self)
        return true
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        WKRemoteServer.application(application: application,
                                   didFailToRegisterForRemoteNotificationsWithError: error as NSError)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        WKRemoteServer.application(application: application,
                                   didRegisterForRemoteNotificationsWithDeviceToken: deviceToken as NSData)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        WKRemoteServer.application(application: application, didReceiveRemoteNotification: userInfo as [NSObject: AnyObject],
                                   fetchCompletionHandler: completionHandler)
    }

    func remoteWillPushNotification(url _: String, userInfo _: [String: Any], isActive _: Bool) -> Bool {
        return true
    }

    func remoteNotification(url _: String, userInfo: [String: Any], isActive _: Bool) { let notif = FxNotification(JSON(userInfo))
        Router.dispatch(notification: notif)
    }
}
