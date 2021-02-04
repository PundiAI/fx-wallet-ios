//
//  XConfigAppDelegate.swift
//  XWallet Pro
//
//  Created by Andy.Chan on 2019/10/29.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit
import Alamofire
import RxSwift
import PromiseKit
import PluggableApplicationDelegate
import CoreTelephony
import Reachability

class XConfigAppDelegate: XApplicationService { 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        loadServers(application, launchOptions)
        return true
    }
    
    private func loadServers(_ application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        WKServer.addServer(aClass: NetworkReachabilityServer.self, params: nil)
        
    }
}

 
