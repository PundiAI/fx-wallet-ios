import FunctionX
import SwiftyJSON
import WebKit
import WKKit
import XWebView
public class DappJSFunctionX: TransactionDappJSAction {
    override public func support() -> [String] {
        return ["sign"]
    }

    @objc func sign(_ params: [String: Any], _ callback: XWVScriptObject) {
        let json = JSON(params)
        guard let address = json["address"].string,
            let hex = json["msg"].string
        else {
            callback.error(code: .unrecognizedParams)
            return
        }
        var coin: Coin?
        if address.hasPrefix(FxChain.hub.hrp.string) {
            coin = .hub
        } else if address.hasPrefix(FxChain.order.hrp.string) {
            coin = .order
        } else {
            for c in wallet.coins {
                guard c.isCloud, let hrp = c.hrp else { continue }
                if address.hasPrefix(hrp) {
                    coin = c; break
                }
            }
        }
        guard let c = coin, let account = wallet.accounts(forCoin: c).account(for: address) else {
            callback.error(code: .unrecognizedParams)
            return
        }
        authSign(account: account, message: hex, callback: callback) {
            if let data = try? ECC.ecdsaCompactsign(data: Data(hex: hex), privateKey: account.privateKey.data) {
                callback.success(data: data.hexString)
            } else {
                callback.error(code: .internalError, msg: "sign failed")
            }
        }
    }
}
