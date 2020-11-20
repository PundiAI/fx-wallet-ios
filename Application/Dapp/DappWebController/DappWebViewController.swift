import FunctionX
import RxCocoa
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WebKit
import WKKit
import XWebKit
import XWebView
extension DappWebViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let dapp = context["dapp"] as? Dapp else { return nil }
        let wallet = context["wallet"] as? WKWallet
        return DappWebViewController(dapp: dapp, wallet: wallet)
    }
}

class DappWebViewController: FxWebViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
        urlString = dapp.url
        if let displayUrl = dapp.displayUrl {
            dapp.displayUrl = nil
            urlString = displayUrl
        }
        progressView.progressTintColor = HDA(0x2D90FF)
        view.bringSubviewToFront(webView)
        view.bringSubviewToFront(navigationBar)
        guard let js = jscript,
            let httpURL = urlString, let url = URL(string: httpURL)
        else {
            return
        }
        js.loadPlugin(key: "store", plugin: DappJSStorage(project: dapp.url.md5()))
        js.loadPlugin(key: "system", plugin: DappJSSystem(dapp: dapp, webViewController: self))
        if let wallet = self.wallet {
            js.loadPlugin(key: "account", plugin: DappJSAccount(dapp: dapp, wallet: wallet, webViewController: self))
            js.loadPlugin(key: "functionx", plugin: DappJSFunctionX(dapp: dapp, wallet: wallet, webViewController: self))
            js.loadPlugin(key: "navigation", plugin: DappJSNavigation(dapp: dapp, wallet: wallet, webViewController: self))
        }
        if let wallet = self.wallet {
            wallet.dappManager.addOrUpdate(dapp)
        }
        webView.startHttp(project: "dapp", url: url, jsCore: js)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        titleView.set(title: webView.title ?? dapp.name)
        navigationBar.action(.title, view: titleView)
    }

    func webView(_: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }

    override func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo,
                          completionHandler: @escaping () -> Void)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.hud?.text(m: message)
        }
        completionHandler()
    }

    override func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo,
                          completionHandler: @escaping (Bool) -> Void)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.hud?.text(m: message)
        }
        completionHandler(true)
    }

    override func heroAnimator(from _: String, to _: String) -> WKHeroAnimator? {
        setNeedsStatusBarAppearanceUpdate()
        return nil
    }
}

class DappJSCore: WKJSCore {
    @objc func setup(_ object: [String: Any], _ callback: XWVScriptObject) {
        if let debug = object["debug"] as? Bool {
            XWVScriptObject.dappDebug = debug
        }
        let nodeInfoJS = String(format: "pundixCommonJs.nodeInfo = %@", NodeManager.shared.currentJsonString)
        callback.evaluateExpression(nodeInfoJS) { _, _ in }
        callback.success(data: ["version": "1.0.0"])
    }
}

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
        if fx == nil || fx?.wallet?.privateKey.data != privateKey.data {
            fx = FunctionX(wallet: FxWallet(privateKey: privateKey))
        }
        return fx!
    }

    func showSelectAddressAlert(_ coin: Coin, symbol: String? = nil) {
        DispatchQueue.main.async {
            Router.showAuthorizeDappAlert(dapp: self.dapp, types: [0]) { authVC, allow in
                Router.dismiss(authVC, animated: false) {
                    guard allow else { return }
                    Router.showDappSelectAddressAlert(wallet: self.wallet, dapp: self.dapp, coin: coin, symbol: symbol) { vc, _ in
                        vc?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func authSign(account: Keypair, message: Any, callback: XWVScriptObject, handler: @escaping () -> Void) {
        DispatchQueue.main.async {
            Router.showWalletConnectSign(dapp: self.dapp, message: message, account: account) { allow in
                guard allow else {
                    callback.error(code: .userCanceled)
                    return
                }
                Router.showVerifyPasswordAlert { error in
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

extension XWVScriptObject {
    fileprivate static var dappDebug = false
    enum DappActionCode: Int {
        case success = 200
        case internalError = 200_001
        case unrecognizedParams = 300_000
        case userCanceled = 300_001
        case authorizationDenied = 300_002
        case networkRequestFailed = 300_003
        case networkUnreachable = 300_004
        case notInFXBrowser = 400_000
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
