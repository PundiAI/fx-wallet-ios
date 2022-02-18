//
//  DrampViewController.swift
//  fxWallet
//
//  Created by Pundix54 on 2020/12/17.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit
import WebKit

extension RampWebController {
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let userAddress = context["userAddress"] as? String,
            let swapAsset =  context["swapAsset"] as? String,
            let swapAmount =  context["swapAmount"] as? String else {
            return nil
        }
        return RampWebController(wallet: nil, userAddress: userAddress, swapAsset: swapAsset, swapAmount: swapAmount)
    }
}

class RampWebController: FxWebViewController {
    override var interactivePopIsEnabled: Bool { false }
    let wallet: WKWallet?
    let request:RampApi
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet?, userAddress:String, swapAsset:String, swapAmount:String) {
        self.wallet = wallet
        self.request = RampApi(userAddress: userAddress, swapAsset: swapAsset, swapAmount: swapAmount)
        super.init(nibName: nil, bundle: nil) 
    }
    
    override func navigationItems(_ navigationBar: WKNavigationBar) {
        super.navigationItems(navigationBar)
        navigationBar.action(.title, title: TR("Dapp.Ramp.Title"))
    }
    
    override var userAgent: String? { return "fxwallet" }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressView.progressTintColor = HDA(0x2D90FF)
        view.bringSubviewToFront(webView)
        view.bringSubviewToFront(navigationBar) 
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
    
    override func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.hud?.text(m: message)
        }
        completionHandler()
    }

    override func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.hud?.text(m: message)
        }
        completionHandler(true)
    }
    
    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
}
