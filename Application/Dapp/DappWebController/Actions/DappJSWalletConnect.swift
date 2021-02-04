//
//  DappJSWalletConnect.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/22.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import WebKit
import XWebView
import FunctionX
import SwiftyJSON

public class DappJSWalletConnect: DappJSAction {
    
    override public func support() -> [String] {
        return ["connect"]
    }
    
    @objc func connect(_ params: [String: Any], _ callback: XWVScriptObject) {
        let json = JSON(params)
        guard let url = json["url"].string else { return }
        
        DispatchQueue.main.async {
            
            let currentNavigator = Router.currentNavigator
            let viewControllers = self.webViewController != nil ? [ self.webViewController! ] : []
            Router.showFxWalletConnect(url: url, wallet: XWallet.currentWallet!.wk, completion: { _ in  })
        }
    }
    
}
