//
//  AppDelegate.swift
//  Pundix
//
//  Created by Andy.Chan on 2019/10/25.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import UIKit
import Foundation
import PluggableApplicationDelegate
import WKKit

public class XApplicationService : NSObject, ApplicationService {
    public var window: UIWindow?
    init(nativeWindow:UIWindow) {
        super.init()
        window = nativeWindow
        window?.backgroundColor = HDA(0x080A32)
        WKRouter.mainWindowBlock = {
            return nativeWindow
        }
    }
}

@UIApplicationMain
class AppDelegate: PluggableApplicationDelegate {
    override var services: [ApplicationService] {
        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        return [
            XLoggerAppDelegate(nativeWindow: window),
            XConfigAppDelegate(nativeWindow: window),
            XWalletAppDelegate(nativeWindow: window),
            XSecurityAppDelegate(nativeWindow: window),
            XRemoteAppDelegate(nativeWindow: window),
            XCallbackAppDelegate(nativeWindow: window),     
        ]
    }
}
