import FunctionX
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit

extension Router {
    static func dappListController(wallet: Wallet) -> UIViewController {
        return viewController("DappListViewController", context: ["wallet": wallet])
    }

    static func pushToAddDapp(wallet: Wallet) {
        pushViewController("AddDappViewController", context: ["wallet": wallet])
    }

    static func pushToDappBrowser(dapp: Dapp, wallet: WKWallet?) {
        pushViewController("DappWebViewController", context: ["dapp": dapp, "wallet": wallet])
    }

    static func showFxExplorer(url: String? = nil, push: Bool = true, completion: ((UIViewController) -> Void)? = nil) {
        var dapp = Dapp.fxExplorer
        if let url = url { dapp.displayUrl = url }
        if push {
            pushViewController("DappWebViewController", context: ["dapp": dapp], completion: completion)
        } else {
            presentViewController("DappWebViewController", context: ["dapp": dapp], completion: completion)
        }
    }

    static func showExplorer(_ coin: Coin, path: ExplorerURL.Path? = nil, push: Bool = true, completion: ((UIViewController) -> Void)? = nil) {
        if coin.isFunctionX {
            showFxExplorer(url: ExplorerURL(coin, path: path).description, push: push, completion: completion)
        } else { showWebViewController(url: ExplorerURL(coin, path: path).description, push: push, completion: completion)
        }
    }

    static func pushToChatList(privateKey: PrivateKey) {
        pushViewController("ChatListViewController", context: ["privateKey": privateKey, "coin": "Fx"])
    }

    static func presentNewChat(wallet: FxWallet, didAddContactHandler: @escaping (() -> Void)) {
        presentViewController("NewChatViewController", context: ["wallet": wallet, "handler": didAddContactHandler])
    }

    static func presentSendCryptoGift(receiver: SmsUser, wallet: FxWallet) {
        presentViewController("SendChatGiftViewController", context: ["receiver": receiver, "wallet": wallet])
    }

    static func pushToChat(receiver: SmsUser, wallet: FxWallet) {
        pushViewController("ChatViewController", context: ["receiver": receiver, "wallet": wallet])
    }

    static func presentChatMessageInfo(receiver: SmsUser, wallet: FxWallet, sms: SmsMessage) {
        presentViewController("ChatMessageInfoViewController", context: ["receiver": receiver, "wallet": wallet, "sms": sms])
    }

    static func showChatMessageEncryptedTipAlert() {
        presentViewController("FxTipAlert", context: ["type": 0])
    }
}
