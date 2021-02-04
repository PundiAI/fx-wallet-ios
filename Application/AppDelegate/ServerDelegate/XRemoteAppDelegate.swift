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
        Router.dispatch(notification: notif)
    }
}
