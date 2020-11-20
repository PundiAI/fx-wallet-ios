import WKKit
import XWebView
public class DappJSSystem: DappJSAction {
    override public func support() -> [String] {
        return ["copy", "camera", "showLoading", "dismissLoading"]
    }

    @objc func camera(_ callback: XWVScriptObject) {
        DispatchQueue.main.async {
            Router.pushToFxScanQRCode { result in
                Router.currentNavigator?.popViewController(animated: true)
                callback.call(arguments: [result], completionHandler: nil)
            }
        }
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
