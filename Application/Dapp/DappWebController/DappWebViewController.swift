
//
//  DappWebViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/23.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import WebKit
import XWebKit
import RxSwift
import RxCocoa
import XWebView
import FunctionX
import SwiftyJSON
import TrustWalletCore

extension DappWebViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let dapp = context["dapp"] as? Dapp else { return nil }
        
        let wallet = context["wallet"] as? WKWallet
        return DappWebViewController(dapp: dapp, wallet: wallet)
    }
}

class DappWebViewController: FxWebViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    var dapp: Dapp
    let wallet: WKWallet?
    init(dapp: Dapp, wallet: WKWallet?) {
        self.dapp = dapp
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        super.jscript = DappJSCore()
    }
    
    override func navigationItems(_ navigationBar: WKNavigationBar) {
        super.navigationItems(navigationBar)
        navigationBar.action(.title, title: dapp.name)
    }
    
    override var userAgent: String? { return "FxBridgeBrowser" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.urlString = dapp.url
        if let displayUrl = dapp.displayUrl {
            dapp.displayUrl = nil
            self.urlString = displayUrl
        }
        
        self.progressView.progressTintColor = HDA(0x2D90FF)
        view.bringSubviewToFront(webView)
        view.bringSubviewToFront(navigationBar)
            
        guard let js = self.jscript,
        let httpURL = self.urlString, let url = URL(string: httpURL) else {
            return
        }
        
        js.loadPlugin(key: "wc", plugin: DappJSWalletConnect(dapp: dapp, webViewController: self))
        js.loadPlugin(key: "store", plugin: DappJSStorage(project: dapp.url.md5()))
        js.loadPlugin(key: "system", plugin: DappJSSystem(dapp: dapp, webViewController: self))
        js.loadPlugin(key: "navigation", plugin: DappJSNavigation(dapp: dapp, webViewController: self))
        if let wallet = self.wallet {
//            js.loadPlugin(key: "del", plugin: DappJSDelegate(dapp: dapp, wallet: wallet, webViewController: self))
//            js.loadPlugin(key: "eth", plugin: DappJSEthereum(dapp: dapp, wallet: wallet, webViewController: self))
            js.loadPlugin(key: "account", plugin: DappJSAccount(dapp: dapp, wallet: wallet, webViewController: self))
            js.loadPlugin(key: "functionx", plugin: DappJSFunctionX(dapp: dapp, wallet: wallet, webViewController: self))
        }
        
        if let wallet = self.wallet {
            wallet.dappManager.addOrUpdate(dapp)
        }

        self.webView.startHttp(project: "dapp", url: url, jsCore: js)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK: WebViewDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        titleView.set(title: webView.title ?? dapp.name)
        navigationBar.action(.title, view: titleView)
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
    
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        self.setNeedsStatusBarAppearanceUpdate()
        return nil
    }
}

//MARK: JSCore
class DappJSCore: WKJSCore {
    
    @objc func setup(_ object: [String: Any], _ callback: XWVScriptObject) {
        
        if let debug = object["debug"] as? Bool {
            XWVScriptObject.dappDebug = debug
        }
        let nodeInfoJS = String(format: "pundixCommonJs.nodeInfo = %@", NodeManager.shared.currentJsonString)
        callback.evaluateExpression(nodeInfoJS) { (_, _) in }
        
        callback.success(data: ["version": "1.0.0"])
    }
}

//MARK: JSAction
public class DappJSAction: WKJSAction {
    
    let dapp: Dapp
    weak var webViewController: DappWebViewController?
    init(dapp: Dapp, webViewController: DappWebViewController? = nil) {
        self.dapp = dapp
        self.webViewController = webViewController
        super.init()
    }
}

public class TransactionDappJSAction: DappJSAction {
    
    let wallet: WKWallet
    var dappManager: DappManager { wallet.dappManager }
    
    init(dapp: Dapp, wallet: WKWallet, webViewController: DappWebViewController? = nil) {
        self.wallet = wallet
        super.init(dapp: dapp, webViewController: webViewController)
    }
    
    var fx: FunctionX?
    func fx(_ privateKey: PrivateKey) -> FunctionX {
        
        if self.fx == nil || self.fx?.wallet?.privateKey.data != privateKey.data {
            self.fx = FunctionX(wallet: FxWallet(privateKey: privateKey))
        }
        return self.fx!
    }
    
    func showSelectAddressAlert(_ coin: Coin, symbol: String? = nil) {
        DispatchQueue.main.async {

            Router.showAuthorizeDappAlert(dapp: self.dapp, types: [0]) { (authVC, allow) in
                Router.dismiss(authVC, animated: false) {
                    guard allow else { return }

                    Router.showDappSelectAddressAlert(wallet: self.wallet, dapp: self.dapp, coin: coin, symbol: symbol) { (vc, _) in
                        vc?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func authSign(account: Keypair, message: Any, callback: XWVScriptObject, handler: @escaping () -> ()) {
        DispatchQueue.main.async {
         
            Router.showWalletConnectSign(dapp: self.dapp, message: message, account: account) { (allow) in
                guard allow else {
                    callback.error(code: .userCanceled)
                    return
                }
                
                Router.showVerifyPasswordAlert { (error) in
                    if error != nil {
                        callback.error(code: .internalError, msg: "sign failed")
                    } else {
                        handler()
                    }
                }
            }
        }
    }
}


//MARK: Utils
extension XWVScriptObject {
    
    static fileprivate var dappDebug = false
    
    enum DappActionCode: Int {
        case success = 200
        case internalError = 200001
        case unrecognizedParams = 300000
        case userCanceled = 300001
        case authorizationDenied = 300002
        case networkRequestFailed = 300003
        case networkUnreachable = 300004
        case notInFXBrowser = 400000
    }
    
    func response(code: Int = 200, msg: String? = nil, data: Any = [:]) {
        
        var result = [String: Any]()
        result["code"] = code
        result["data"] = data
        if let msg = msg { result["msg"] = msg }
        let jsonString = JSDictionaryToString(params: result)
        if XWVScriptObject.dappDebug {
            DispatchQueue.main.async {
                Router.currentNavigator?.hud?.text(m: jsonString, d: 1)
            }
        }
        call(arguments: [jsonString], completionHandler: nil)
    }
    
    func success(data: Any = [:]) {
        response(code: DappActionCode.success.rawValue, data: data)
    }
    
    func error(code: DappActionCode, msg: String? = nil) {
        response(code: code.rawValue, msg: msg ?? TR("Dapp.Error\(code.rawValue)"))
    }
    
    func error(_ error: WKError) {
        response(code: error.code, msg: error.msg)
    }
}
