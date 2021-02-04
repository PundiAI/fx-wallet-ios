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
            XLoggerAppDelegate(nativeWindow: window),       //打印调试配置
            XConfigAppDelegate(nativeWindow: window),       //数据配置 
            XWalletAppDelegate(nativeWindow: window),       //Wallet入口 设置Windows rootViewController 
            XSecurityAppDelegate(nativeWindow: window),     //锁屏入口
            XRemoteAppDelegate(nativeWindow: window),       //推送通知配置
        ]
    }
}
