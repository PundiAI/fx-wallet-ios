//
//  DappJSNavigation.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/22.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import WebKit
import XWebView
import SwiftyJSON

public class DappJSNavigation: DappJSAction {
    
    private var navigationController: UINavigationController? {
        return webViewController?.navigationController
    }
    
    override public func support() -> [String] {
        return ["router", "close"]
    }
    
    @objc func router(_ params: [String: Any], _ callback: XWVScriptObject) {
        
        guard let scene = string(forKey: "scene", in: params) else {
            callback.error(code: .unrecognizedParams)
            return
        }
        
        let parameter = params["params"] as? [String: Any]
        switch scene {
        case "DappWebView":
            if let url = parameter?["url"] as? String {
                DispatchQueue.main.async {
                    Router.showFxExplorer(url: url)
                }
            }
            
        default: break
        }
        
    }
    
    @objc func close(_ callback: XWVScriptObject) {
        webViewController?.close()
    }
}
