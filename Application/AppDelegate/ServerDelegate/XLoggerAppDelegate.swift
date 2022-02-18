//
//  LoggerApplicationService.swift
//  XWallet Pro
//
//  Created by Andy.Chan on 2019/10/25.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import Foundation
import WKKit
import PluggableApplicationDelegate
import TrustWalletCore

final class XLoggerAppDelegate: XApplicationService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        WKLog.Config(level:.debug, debug: ServerENV.current != .release) 
        return true
    } 
}

