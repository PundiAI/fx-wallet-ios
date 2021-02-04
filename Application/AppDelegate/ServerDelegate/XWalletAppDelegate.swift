//
//  AppDelegate.swift
//  Pundi
//
//  Created by Chen Andy on 2017/4/28.
//  Copyright © 2017年 Chen Andy. All rights reserved.
//

import UIKit
import WKKit 
class XWalletAppDelegate: XApplicationService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loadServers(application, launchOptions)
        WKNavigationBar.leftButtonFont = XWallet.Font(ofSize: 18)
        WKNavigationBar.titleViewFont = XWallet.Font(ofSize: 18)
        WKNavigationBar.rightButtonFont = XWallet.Font(ofSize: 18)
        Router.resetRootController(wallet: XWallet.sharedKeyStore.currentWallet)
        WKEvent.Language.on(event: .LanguageDidChange, object: self, action: #selector(self.onLanguageDidChange(params:)))
        return true
    }
      
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier
                        extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) ->Bool {
        return false
    }
    
    @objc func onLanguageDidChange(params: Any) {
        Router.setRootController(wallet: XWallet.sharedKeyStore.currentWallet,
                                 viewControllers: [ Router.settingsController() ])
    }
}

//MARK: Utils
extension XWalletAppDelegate { 
    private func loadServers(_ application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        WKServer.addServer(aClass: NetworkServer.self, params: nil)
        WKServer.addServer(aClass: AccountServer.self, params: nil) 
    }
}
