//
//  XRemoteAppDelegate.swift
//  XWallet
//
//  Created by Andy.Chan on 2019/9/9.
//  Copyright © 2019 Chen Andy. All rights reserved.
//

import UIKit
import WKKit
import RxSwift
import SwiftyJSON
import PluggableApplicationDelegate
 
class XRemoteAppDelegate: XApplicationService , WKRemoteDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return  WKServer.application(application: app, open: url, sourceApplication: nil, annotation: nil)
    }
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.applicationIconBadgeNumber = 0
        WKServer.addServer(aClass: WKRemoteServer.self, params: self) 
        WKServer.addServer(aClass: FxNotificationServer.self)
        WKServer.addServer(aClass: FxNotificationTransactionServer.self)
        if let lanuchParams = launchOptions, let _ = lanuchParams[UIApplication.LaunchOptionsKey(rawValue: "aps")] {
            WKRemoteServer.application(application: application, didReceiveRemoteNotification: lanuchParams as [NSObject : AnyObject],
                                       fetchCompletionHandler: { result in })
        }
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

    // iOS <9
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        WKRemoteServer.application(application: application, didReceiveRemoteNotification: userInfo as [NSObject : AnyObject],
                                   fetchCompletionHandler: completionHandler)
    }

    func remoteWillPushNotification(url: String, userInfo: [String : Any], isActive: Bool) -> Bool {
        return true
    }

    func remoteNotification(url: String, userInfo: [String : Any], isActive: Bool) { 
        let notif = FxNotification(JSON(userInfo))
        notif.isActive = isActive
        if isActive == false {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                Router.dispatch(notification: notif)
            }
        }else {
            Router.dispatch(notification: notif)
        }
    }
}
