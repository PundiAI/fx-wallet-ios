

import TrustWalletCore
import UIKit
import WebKit
import WKKit

class DAppWebViewController: UIViewController {
    var urlField = UITextField(frame: CGRect(x: 0, y: 0, width: 375, height: 60))
    var homepage: String { return "https:--" }

    let privateKey = PrivateKey(data: Data(hexString: "1b46beca47ac628524b6bac688c3b864e00ebde31352bcff545533e987b25e80")!)!
    lazy var scriptConfig: WKUserScriptConfig = {
        WKUserScriptConfig(
            address: address,
            chainId: 1,
            rpcUrl: "https:--",
            privacyMode: false
        )
    }()

    lazy var address: String = {
        CoinType.ethereum.deriveAddress(privateKey: privateKey).lowercased()
    }()

    lazy var webview: WKWebView = {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.addUserScript(scriptConfig.providerScript)
        controller.addUserScript(scriptConfig.injectedScript)
        for name in DAppMethod.allCases {
            controller.add(self, name: name.rawValue)
        }
        config.userContentController = controller
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.uiDelegate = self
        return webview
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSubviews()
        urlField.text = homepage
        navigate(to: homepage)
    }

    func setupSubviews() {
        urlField.keyboardType = .URL
        urlField.delegate = self
        urlField.backgroundColor = .green
        view.addSubview(urlField)
        urlField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlField.topAnchor.constraint(equalTo: view.topAnchor),
            urlField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlField.widthAnchor.constraint(equalTo: view.widthAnchor),
            urlField.heightAnchor.constraint(equalToConstant: 60),
        ])
        view.addSubview(webview)
        NSLayoutConstraint.activate([
            webview.topAnchor.constraint(equalTo: urlField.bottomAnchor),
            webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webview.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }

    func navigate(to url: String) {
        guard let url = URL(string: url) else { return }
        webview.load(URLRequest(url: url))
    }
}

extension DAppWebViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigate(to: textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}

extension DAppWebViewController: WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        let json = message.json
        print(json)
        guard let name = json["name"] as? String,
            let method = DAppMethod(rawValue: name),
            let id = json["id"] as? Int64
        else {
            return
        }
        switch method {
        case .requestAccounts:
            handleRequestAccounts(id: id)
        case .signMessage:
            guard let data = extractMessage(json: json) else {
                print("data is missing")
                return
            }
            handleSignMessage(id: id, data: data, addPrefix: false)
        case .signPersonalMessage:
            guard let data = extractMessage(json: json) else {
                print("data is missing")
                return
            }
            handleSignMessage(id: id, data: data, addPrefix: true)
        case .ecRecover:
            guard let tuple = extractSignature(json: json) else {
                print("signature or message is missing")
                return
            }
            let recovered = ecRecover(signature: tuple.signature, message: tuple.message) ?? ""
            print(recovered)
            DispatchQueue.main.async {
                self.webview.sendResult(recovered, to: id)
            }
        default:
            break
        }
    }

    func handleRequestAccounts(id: Int64) {
        let alert = UIAlertController(
            title: webview.title,
            message: "\(webview.url?.host! ?? "Website") would like to connect your account",
            preferredStyle: .alert
        )
        let address = scriptConfig.address
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { [weak webview] _ in
            webview?.sendError("Canceled", to: id)
        }))
        alert.addAction(UIAlertAction(title: "Connect", style: .default, handler: { [weak webview] _ in
            webview?.evaluateJavaScript("window.ethereum.setAddress(\"\(address)\");", completionHandler: nil)
            webview?.sendResults([address], to: id)
        }))
        present(alert, animated: true, completion: nil)
    }

    func handleSignMessage(id: Int64, data: Data, addPrefix: Bool) {
        let alert = UIAlertController(
            title: "Sign Message",
            message: addPrefix ? String(data: data, encoding: .utf8) ?? "" : data.hexString,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { [weak webview] _ in
            webview?.sendError("Canceled", to: id)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak webview] _ in
            let signed = self.signMessage(data: data, addPrefix: addPrefix)
            webview?.sendResult("0x" + signed.hexString, to: id)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func extractMessage(json: [String: Any]) -> Data? {
        guard let params = json["object"] as? [String: Any],
            let string = params["data"] as? String,
            let data = Data(hexString: string)
        else {
            return nil
        }
        return data
    }

    private func extractSignature(json: [String: Any]) -> (signature: Data, message: Data)? {
        guard let params = json["object"] as? [String: Any],
            let signature = params["signature"] as? String,
            let message = params["message"] as? String
        else {
            return nil
        }
        return (Data(hexString: signature)!, Data(hexString: message)!)
    }

    private func signMessage(data: Data, addPrefix: Bool = true) -> Data {
        let message = addPrefix ? Hash.keccak256(data: ethereumMessage(for: data)) : data
        var signed = privateKey.sign(digest: message, curve: .secp256k1)!
        signed[64] += 27
        return signed
    }

    private func ecRecover(signature: Data, message: Data) -> String? {
        let data = ethereumMessage(for: message)
        let hash = Hash.keccak256(data: data)
        guard let publicKey = PublicKey.recover(signature: signature, message: hash),
            PublicKey.isValid(data: publicKey.data, type: publicKey.keyType)
        else {
            return nil
        }
        return CoinType.ethereum.deriveAddressFromPublicKey(publicKey: publicKey).lowercased()
    }

    private func ethereumMessage(for data: Data) -> Data {
        let prefix = "\u{19}Ethereum Signed Message:\n\(data.count)".data(using: .utf8)!
        return prefix + data
    }
}

extension DAppWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.request.url != nil else {
            return nil
        }
        _ = webView.load(navigationAction.request)
        return nil
    }

    func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }

    func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        present(alert, animated: true, completion: nil)
    }
}
