//
//  DappWebViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/23.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import WebKit
import RxSwift
import RxCocoa
import XWebView
import FunctionX
import SwiftyJSON
import TrustWalletCore

extension DappWebViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let dapp = context["dapp"] as? Dapp else { return nil }
        
        return DappWebViewController(dapp: dapp, wallet: wallet)
    }
}

class DappWebViewController: WKURLWebController {

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    let dapp: Dapp
    let wallet: TrustWalletCore.Wallet
    init(dapp: Dapp, wallet: TrustWalletCore.Wallet) {
        self.dapp = dapp
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var navigationTheme: WKNavBarTheme {
        return WKNavBarTheme(barTint: HDA(0x222222), backTint: .white, titleColor: .white)
    }
    override func navigationItems(_ navigationBar: WKNavigationBar) {
        
        weak var welf = self
        let backItem = navigationBar.action(.back, imageName: "ic_back_white") { welf?.backAction() }!
        let closeItem = navigationBar.action(.left, imageName: "ic_close_white") { welf?.closeAction() }!
        navigationBar.set(actions: [backItem, closeItem])
        
        navigationBar.action(.right, imageName: "ic_more_white")
    }
    
    override var userAgent: String? { return "FxBridgeBrowser" }
    
    override func viewDidLoad() {
    super.viewDidLoad()
 
        self.urlString = dapp.url
        self.progressView.progressTintColor = HDA(0x2D90FF)
        view.bringSubviewToFront(webView)
            
        guard let js = self.jscript,
        let httpURL = self.urlString, let url = URL(string: httpURL) else {
            return
        }

        js.loadPlugin(key: "navigation", plugin: DappJSNavigation(dapp: dapp, wallet: wallet, webViewController: self))
        js.loadPlugin(key: "account", plugin: DappJSAccount(dapp: dapp, wallet: wallet))
        js.loadPlugin(key: "del", plugin: DappJSDelegate(dapp: dapp, wallet: wallet))
        js.loadPlugin(key: "sms", plugin: DappJSSms(dapp: dapp, wallet: wallet))
        js.loadPlugin(key: "store", plugin: DappJSStorage(project: dapp.url.md5()))
        js.loadPlugin(key: "system", plugin: DappJSSystem(dapp: dapp, wallet: wallet, webViewController: self))

        self.webView.startHttp(project: "dapp", url: url, jsCore: js)
        DappManager.shared.add(dapp)
    }
    
    fileprivate func backAction() {
        DispatchQueue.main.async {
            
            if self.webView.canGoBack {
                self.webView.goBack()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    fileprivate func closeAction() {
        DispatchQueue.main.async {
            self.navigationController?.popToRootOrDismiss(animated: true)
        }
    }
}

extension DappWebViewController {
    
//    #if DEBUG
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust {
            
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
//    #endif

    override open func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        self.hud?.text(m: message)
        completionHandler()
    }

    override  open func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        self.hud?.text(m: message)
        completionHandler(true)
    }
}

//MARK: JSActions

public class DappJSAction: WKJSAction {
    
    let dapp: Dapp
    let wallet: TrustWalletCore.Wallet
    weak var webViewController: DappWebViewController?
    init(dapp: Dapp, wallet: TrustWalletCore.Wallet, webViewController: DappWebViewController? = nil) {
        self.dapp = dapp
        self.wallet = wallet
        self.webViewController = webViewController
        super.init()
    }
    
    var fx: FunctionX?
    func fx(_ privateKey: PrivateKey) -> FunctionX {
        
        if self.fx == nil || self.fx?.wallet?.privateKey.data != privateKey.data {
            self.fx = FunctionX(wallet: FxWallet(privateKey: privateKey))
        }
        return self.fx!
    }
    
    func pushToSelectAddressIfAllow(_ selectAddressHandler: @escaping ((String, String, PrivateKey) -> Void)) {
        
//        DispatchQueue.main.async {
//            
//            Router.manager.showAuthorizeDappAlert(dapp: self.dapp) { (authVC, allow) in
//                
//                authVC?.dismiss(animated: false, completion: {
//                    
//                    if !allow {
//                        Router.manager.topViewController?.hud?.text(m: "user denied")
//                    } else {
//                        
//                        let vc = DappSelectAddressViewController(wallet: self.wallet, dapp: self.dapp)
//                        vc.confirmHandler = selectAddressHandler
//                        Router.manager.currentNavigator?.pushViewController(vc, animated: true)
//                    }
//                })
//            }
//        }
    }
}


//MARK: JS.Account
public class DappJSAccount: DappJSAction {
    
    override public func support() -> [String] {
        return ["getAddress", "register"]
    }
    
    private func responseAddress(_ callback: XWVScriptObject) {
        guard let account = DappManager.shared.account(for: dapp) else { return }
        
        callback.success(data: ["address": account.address, "remarks": account.remark])
    }
    
    @objc func getAddress(_ params: [String: Any], _ callback: XWVScriptObject) {
        
        let chainId = string(forKey: "chainId", in: params) ?? "functionxhub"
        var chain = 0
        if chainId == "functionxsms" { chain = 1 }
        DispatchQueue.main.async {
            
            Router.manager.showAuthorizeDappAlert(dapp: self.dapp, authorityTypes: [0]) { (authVC, allow) in
                authVC?.dismiss(animated: false, completion: {
                    guard allow else {
                        callback.error(code: .authorizationDenied, msg: "user denied")
                        return
                    }
                    
                    Router.manager.showDappSelectAddressAlert(wallet: self.wallet, dapp: self.dapp, chain: chain) { (vc, address, _, privateKey) in
                        vc?.dismiss(animated: true, completion: nil)
                        self.responseAddress(callback)
                    }
                })
            }
        }
    }
    
    @objc func register(_ params: [String: Any], _ callback: XWVScriptObject) {
        guard let account = DappManager.shared.account(for: dapp) else {
            callback.error(code: .internalError, msg: "can`t find address")
            return
        }
        
        guard let registerName = string(forKey: "name", in: params) else {
            callback.error(code: .unrecognizedParams, msg: "name is empty")
            return
        }
        
        let json = JSON(params)
        let tx = FxTransaction(json)
        tx.from = account.address
        tx.registerName = registerName
        tx.txType = .userRegister
        DispatchQueue.main.async {

            Router.manager.showAuthorizeDappAlert(dapp: self.dapp, authorityTypes: [1]) { [weak self] (authVC, allow) in
                authVC?.dismiss(animated: false, completion: {
                    guard allow else {
                        callback.error(code: .authorizationDenied)
                        self?.webViewController?.hud?.text(m: "user denied")
                        return
                    }
                        
                    Router.manager.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey) { (error, result) in

                        if let err = error {
                            callback.error(err)
                        } else {
                            callback.success(data: result.dictionaryObject ?? [:])
                        }
                    }
                })
            }
        }
    }
    
}

//MARK: JS.Delegate
public class DappJSDelegate: DappJSAction {
    
    override public func support() -> [String] {
        return ["delegate", "undelegate", "withdrawValidatorReward", "withdrawDelegationReward"]
    }
    
    @objc func delegate(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .delegate, params, callback)
    }
    
    @objc func undelegate(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .undelegate, params, callback)
    }
    
    @objc func withdrawValidatorReward(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .withdrawValidatorCommission, params, callback)
//        PrivateKey(data: Data(hex: "84c368f72ff1ab48833bf0dadae5cb4aec3eecb7a82521cd59d6d236dabea7e0"))! //验证者私钥
    }
    
    @objc func withdrawDelegationReward(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .withdrawDelegatorReward, params, callback)
    }
    
    private func send(tx txType: MessageType, _ params: [String: Any], _ callback: XWVScriptObject) {
        guard let account = DappManager.shared.account(for: dapp) else {
            callback.error(code: .internalError, msg: "can`t find address")
            return
        }
        
        let json = JSON(params)
        let tx = FxTransaction(json)
        tx.validator = json["validator_address"].stringValue
        tx.delegator = account.address
        tx.txType = txType
        DispatchQueue.main.async {
            
            Router.manager.showAuthorizeDappAlert(dapp: self.dapp, authorityTypes: [1]) { [weak self] (authVC, allow) in
                authVC?.dismiss(animated: false, completion: {
                    guard allow else {
                        callback.error(code: .authorizationDenied)
                        self?.webViewController?.hud?.text(m: "user denied")
                        return
                    }
                        
                    Router.manager.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey) { (error, result) in

                        if let err = error {
                            callback.error(err)
                        } else {
                            callback.success(data: result.dictionaryObject ?? [:])
                        }
                    }
                })
            }
        }
    }
}

//MARK: JS.Sms
public class DappJSSms: DappJSAction {
    
    override public func support() -> [String] {
        return ["transation"]
    }
    
    @objc func transation(_ params: Any, _ callback: XWVScriptObject) {
        
        let content = string(forKey: "content", in: params) ?? ""
        var toAddress = string(forKey: "toAddress", in: params) ?? ""
        let amount = int(forKey: "amount", in: params) ?? 0
        
        pushToSelectAddressIfAllow { (address, name, privateKey) in
            
            let tx = FxTransaction(JSON(params))
            tx.to = toAddress
            tx.from = address
            Router.manager.showBroadcastTxAlert(tx: tx, privateKey: privateKey) { (error, result) in
                
                if let err = error {
                    callback.error(err)
                } else {
                    
                    var data: [String: Any] = [:]
                    if toAddress.isEmpty {
                        let log = JSON(parseJSON: result["deliver_tx", "log"].stringValue)
                        for event in log["events"].arrayValue {
                            if event["type"] == "sendsms" {
                                for attribute in event["attributes"].arrayValue {
                                    if attribute["key"].stringValue == "recipient" {
                                        toAddress = attribute["value"].stringValue
                                    }
                                }
                            }
                        }
                    }

                    data["amount"] = amount
                    data["content"] = content
                    data["fee"] = 0
                    data["fromAdress"] = address
                    data["hash"] = result["hash"].stringValue
                    data["height"] = result["height"].int64Value
                    data["toAdress"] = toAddress
                    callback.success(data: data)
                }
            }
        }
    }
}

//MARK: JS.Navigation
public class DappJSNavigation: DappJSAction {
    
    private var navigationController: UINavigationController? {
        return webViewController?.navigationController
    }
    
    override public func support() -> [String] {
        return ["router", "close"]
    }
    
    @objc func router(_ params: Any, _ callback: XWVScriptObject) {
        guard let scene = string(forKey: "scene", in: params),
            let url = self.string(forKey: "url", in: params)  else {
            callback.error(code: .unrecognizedParams)
            return
        }
        
        switch scene {
        case "web":
            DispatchQueue.main.async {
                
                let vc = DappWebViewController(dapp: self.dapp, wallet: self.wallet)
                vc.urlString = url
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case "local": break
            
        default: break
        }
        
    }
    
    @objc func close(_ callback: XWVScriptObject) {
        webViewController?.closeAction()
    }
}

//MARK: JS.System
public class DappJSSystem: DappJSAction {
    
    override public func support() -> [String] {
        return ["copy", "showLoading", "dismissLoading"]
    }
    
    @objc func showLoading(_ callback: XWVScriptObject) {
        DispatchQueue.main.async {
            self.webViewController?.hud?.waiting()
        }
        callback.success()
    }
    
    @objc func dismissLoading(_ callback: XWVScriptObject) {
        DispatchQueue.main.async {
            self.webViewController?.hud?.hide()
        }
        callback.success()
    }
    
    @objc func copy(_ params: Any, _ callback: XWVScriptObject) {
        guard let content = string(forKey: "content", in: params) else {
            callback.error(code: .unrecognizedParams)
            return
        }
        
        UIPasteboard.general.string = content
        callback.success()
    }
}

//MARK: JS.Storage
class DappJSStorage: WKJSAction {
    
    static private var storage: [String: [String: Any]] = [:]
    static private func keyValues(forProject project: String) -> [String: Any] {
        return storage[project] ?? [:]
    }
    
    static private func setKeyValues(forProject project: String, _ kv: [String: Any]) {
        guard kv.count > 0 else { return }
        
        var temp = keyValues(forProject: project)
        for (k, v) in kv {
            temp[k] = v
        }
        storage[project] = temp
    }
    
    convenience init(project: String) {
        self.init()
        self.project = project
    }
    
    override public func support() -> [String] {
        return ["setValues", "getValues"].map({ (_it) -> String in
            return "\(getPrefix())\(_it)"
        })
    }
    
    private func projectName() -> String {
        return self.project ?? "default"
    }

    @objc func setValues(_ keyValues: [String: Any], _ callback: XWVScriptObject) {
        DappJSStorage.setKeyValues(forProject: projectName(), keyValues)
        callback.success()
    }

    // 获取缓存数据
    @objc func getValues(_ parmas: [String: Any], _ callback: XWVScriptObject) {
        guard let keys = parmas["keys"] as? [String] else {
            callback.error(code: .unrecognizedParams)
            return
        }
        
        let storage = DappJSStorage.keyValues(forProject: projectName())
        var result: [String: Any] = [:]
        for key in keys {
            result[key] = storage[key] ?? ""
        }
        callback.success(data: result)
    }
    
}


//MARK: Utils
extension XWVScriptObject {
    
    fileprivate enum Code: Int {
        case success = 200
        case internalError = 200001
        case unrecognizedParams = 300000
        case userCanceled = 300001
        case authorizationDenied = 300002
        case networkRequestFailed = 300003
        case networkUnreachable = 300004
        case noAddressToRegister = 300005
        case initializationFailed = 300006
        case notInFXBrowser = 400000
    }
    
    func response(code: Int = 200, msg: String? = nil, data: [String: Any] = [:]) {
        
        var result: [String: Any] = [String: Any]()
        result["code"] = code
        result["data"] = data
        if let msg = msg { result["msg"] = msg }
        let jsonString = JSDictionaryToString(params: result)
        call(arguments: [jsonString], completionHandler: nil)
    }
    
    func success(data: [String: Any] = [:]) {
        response(code: Code.success.rawValue, data: data)
    }
    
    fileprivate func error(code: Code, msg: String? = nil) {
        response(code: code.rawValue, msg: msg)
    }
    
    func error(_ error: WKError) {
        response(code: error.code, msg: error.msg)
    }
}
