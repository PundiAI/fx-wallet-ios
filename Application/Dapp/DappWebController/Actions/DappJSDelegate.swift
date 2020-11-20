import FunctionX
import SwiftyJSON
import WebKit
import WKKit
import XWebView
public class DappJSDelegate: TransactionDappJSAction {
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
    }

    @objc func withdrawDelegationReward(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .withdrawDelegatorReward, params, callback)
    }

    private func send(tx txType: MessageType, _ params: [String: Any], _ callback: XWVScriptObject) {
        guard let account = dappManager.account(for: dapp) else {
            callback.error(code: .internalError)
            showSelectAddressAlert(.hub)
            return
        }
        let json = JSON(params)
        let tx = FxTransaction(json)
        tx.validator = json["validator_address"].stringValue
        tx.delegator = account.address
        tx.txType = txType
        tx.coin = .hub
        DispatchQueue.main.async {
            Router.showAuthorizeDappAlert(dapp: self.dapp, types: [1]) { [weak self] authVC, allow in
                Router.dismiss(authVC, animated: false) {
                    guard allow else {
                        callback.error(code: .userCanceled)
                        self?.webViewController?.hud?.text(m: "user denied")
                        return
                    }
                    Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: { error, result in
                        if let err = error {
                            callback.error(err)
                        } else {
                            callback.success(data: result.dictionaryObject ?? [:])
                        }
                        if WKError.canceled.isEqual(to: error) {
                            Router.pop(to: self?.webViewController)
                        }
                    })
                }
            }
        }
    }
}
