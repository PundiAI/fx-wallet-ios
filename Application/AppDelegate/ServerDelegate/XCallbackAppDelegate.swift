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

class XCallbackAppDelegate: XApplicationService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        switch url.scheme {
        case RampConfig.finaUrlScheme:
            Ramp.sendNotificationIfUrlValid(url)
            return true
        default:
            return  false
        }
        
    }
}
