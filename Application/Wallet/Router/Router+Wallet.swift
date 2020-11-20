import HapticGenerator
import Hero
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit
public typealias Wallet = TrustWalletCore.Wallet
extension Router {
    static var createWalletController: UIViewController { return viewController("CreateWalletViewController") }
    static var welcomeCreateWalletController: UIViewController { return viewController("WelcomeCreateWalletViewController") }
    static func pushToSetNickName(wallet: WKWallet, ticket: String = "") {
        pushViewController("SetNickNameViewController", context: ["wallet": wallet, "ticket": ticket])
    }

    static func setNickNameController(wallet: WKWallet, ticket: String = "") -> UIViewController {
        return viewController("SetNickNameViewController", context: ["wallet": wallet, "ticket": ticket])
    }

    static func pushToSecurityType(wallet: WKWallet) {
        pushViewController("SecurityTypeViewController", context: ["wallet": wallet])
    }

    static func securityTypeController(wallet: WKWallet) -> UIViewController {
        return viewController("SecurityTypeViewController", context: ["wallet": wallet])
    }

    static func showBiometricsAlert(completionHandler: @escaping (WKError?) -> Void) {
        Haptic.impactMedium.generate()
        presentViewController("BiometricsAlertViewController", context: ["handler": completionHandler])
    }

    static func pushToBackUpNow(wallet: WKWallet) {
        pushViewController("BackUpNowViewController", context: ["wallet": wallet])
    }

    static func backUpNowController(wallet: WKWallet) -> UIViewController {
        return viewController("BackUpNowViewController", context: ["wallet": wallet])
    }

    static func pushToImportWallet() { pushViewController("ImportWalletViewController") }
    static func pushToImportNamed(wallet: WKWallet) {
        pushViewController("ImportNamedViewController", context: ["wallet": wallet])
    }

    static func importNamedController(wallet: WKWallet) -> UIViewController {
        return viewController("ImportNamedViewController", context: ["wallet": wallet])
    }

    static func showBackAlert() {
        Haptic.impactMedium.generate()
        presentViewController("BackAlertViewController")
    }

    static func pushToBackUpNotice(wallet: WKWallet, completion: ((UIViewController) -> Void)? = nil) {
        pushViewController("BackUpNoticeViewController", context: ["wallet": wallet], completion: completion)
    }

    @discardableResult
    static func pushToPrepareMnemonic(nextHandler: @escaping () -> Void) -> UIViewController? {
        return pushViewController("PreMnemonicViewController", context: ["handler": nextHandler])
    }

    static func tokenListController(wallet: WKWallet) -> UIViewController {
        return viewController("TokenListViewController", context: ["wallet": wallet])
    }

    static func pushTokenInfo(wallet: WKWallet, coin: Coin) {
        Haptic.impactMedium.generate()
        pushViewController("TokenInfoViewController", context: ["wallet": wallet, "coin": coin])
    }

    static func showTokenActionSheet(wallet: WKWallet, coin: Coin, account: Keypair) {
        Haptic.impactMedium.generate()
        pushViewController("TokenActionSheet", context: ["wallet": wallet, "coin": coin, "account": account])
    }

    static func pushToAddToken(wallet: WKWallet) {
        Haptic.impactMedium.generate()
        pushViewController("AddTokenViewController", context: ["wallet": wallet])
    }

    static func showRemoveToken(wallet: Wallet, coin: Coin) {
        Haptic.impactMedium.generate()
        presentViewController("RemoveTokenViewController", context: ["wallet": wallet, "coin": coin])
    }

    static func showRemoveAddress(completionHandler: @escaping (WKError?) -> Void, presenCompletion: ((UIViewController) -> Void)? = nil) {
        Haptic.impactMedium.generate()
        pushViewController("RemoveAddressViewController", context: ["handler": completionHandler], completion: presenCompletion)
    }

    static func pushToReceiveToken(coin: Coin, account: Keypair, completion: ((UIViewController) -> Void)? = nil) {
        Haptic.impactMedium.generate()
        pushViewController("ReceiveTokenViewController", context: ["coin": coin, "account": account], completion: completion)
    }

    static func showSelectAccount(wallet: WKWallet, current: (Coin, Keypair)?, filterCoin: Coin?, cancelHandler: (() -> Void)? = nil, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void) {
        var filter: ((Coin, [String: Any]?) -> Bool)?
        if let filterCoin = filterCoin { filter = { coin, _ in coin.id == filterCoin.id } }
        showSelectAccount(wallet: wallet, current: current, filter: filter, cancelHandler: cancelHandler, confirmHandler: confirmHandler)
    }

    static func showSelectAccount(wallet: WKWallet, current: (Coin, Keypair)?, filter: ((Coin, [String: Any]?) -> Bool)? = nil, cancelHandler: (() -> Void)? = nil, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void) {
        presentViewController("SelectAccountViewController", context: ["wallet": wallet, "currentCoin": current?.0, "currentAccount": current?.1, "filter": filter, "handler": confirmHandler, "cancelHandler": cancelHandler])
    }

    static func pushToSelectOrAddAccount(wallet: WKWallet, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void) {
        pushViewController("SelectOrAddAccountViewController", context: ["wallet": wallet, "handler": confirmHandler])
    }

    static func pushToSendTokenInput(wallet: WKWallet, coin: Coin, amount: String? = nil, account: Keypair? = nil, receiver: User? = nil, completion: ((UIViewController) -> Void)? = nil) {
        pushViewController("SendTokenInputViewController", context: ["wallet": wallet, "coin": coin, "amount": amount, "account": account, "receiver": receiver], completion: completion)
    }

    static func pushToSendTokenFee(tx: FxTransaction, account: Keypair, completionHandler: ((WKError?, JSON) -> Void)? = nil) {
        pushViewController("SendTokenFeeViewController", context: ["tx": tx, "account": account, "handler": completionHandler])
    }

    static func pushToSendTokenFeeOptions(tx: FxTransaction, account: Keypair, contentHeight: CGFloat, completionHandler: ((WKError?, JSON) -> Void)? = nil) {
        pushViewController("SendTokenFeeOptionsViewController", context: ["tx": tx,
                                                                          "account": account,
                                                                          "handler": completionHandler, "contentHeight": contentHeight])
    }

    static func pushToSendTokenCommit(tx: FxTransaction, account: Keypair, completion: ((UIViewController) -> Void)? = nil) {
        pushViewController("SendTokenCommitViewController", context: ["tx": tx, "account": account], completion: completion)
    }

    static func pushToSettings() { pushViewController("SettingsViewController")
    }

    static func settingsController() -> UIViewController {
        return viewController("SettingsViewController")
    }

    static func pushViewConsensus(wallet: Wallet) {
        pushViewController("ViewConsensusViewController", context: ["wallet": wallet])
    }

    static func showNotificationList(wallet: Wallet) {
        presentViewController("NotificationListViewController", context: ["wallet": wallet])
    }

    static func showNotificationAlert() {
        Haptic.success.generate()
        pushViewController("NotificationAlertController")
    }

    static func pushToPreMnemonic(mnemonic: String, completion: ((UIViewController) -> Void)? = nil) {
        pushViewController("PreMnemonicViewController", context: ["mnemonic": mnemonic], completion: completion)
    }

    static func preMnemonicController(mnemonic: String) -> UIViewController {
        return viewController("PreMnemonicViewController", context: ["mnemonic": mnemonic])
    }

    static func pushToCheckBackUp(mnemonic: String, completion: ((UIViewController) -> Void)? = nil) {
        pushViewController("CheckBackUpViewController", context: ["mnemonic": mnemonic], completion: completion)
    }

    static func checkBackUpController(mnemonic: String) -> UIViewController {
        return viewController("CheckBackUpViewController", context: ["mnemonic": mnemonic])
    }

    static func showBackUpSuccess(completionHandler: @escaping (Bool) -> Void, completion: ((UIViewController) -> Void)? = nil) {
        presentViewController("VerifyAlertViewController", context: ["handler": completionHandler], completion: completion)
    }

    static func showBackUpError(completionHandler: @escaping (Bool) -> Void, completion: ((UIViewController) -> Void)? = nil) {
        presentViewController("VerifyAlertErrorViewController", context: ["handler": completionHandler], completion: completion)
    }

    static func showVerifyStopAlert(completionHandler: @escaping (WKError?) -> Void) {
        presentViewController("VerifyStopAlertViewController", context: ["handler": completionHandler])
    }

    static func showSetLanguageAlert(completionHandler: @escaping CompletionHandler) {
        presentViewController("SetLanguageViewController", context: ["handler": completionHandler])
    }

    static func pushToResetWallet(wallet: WKWallet) {
        pushViewController("ResetWalletViewController", context: ["wallet": wallet])
    }

    static func pushToSecurity() {
        pushViewController("SecurityViewController")
    }

    static func showSetBioAlert(completionHandler: @escaping (WKError?) -> Void) {
        presentViewController("SetBioAlertController", context: ["handler": completionHandler])
    }

    static func showChangePwdAlert(wallet: Wallet, completionHandler: @escaping (WKError?) -> Void) {
        presentViewController("ChangePasswordAlertController", context: ["wallet": wallet, "handler": completionHandler])
    }

    static func showFirstSetPwdAlert(wallet: WKWallet, completionHandler: @escaping (WKError?) -> Void) {
        presentViewController("FirstSetPwdAlertController", context: ["wallet": wallet, "handler": completionHandler])
    }

    static func pushToSetCurrency(wallet: WKWallet) {
        pushViewController("SetCurrencyViewController", context: ["wallet": wallet])
    }

    static func pushToSwap(wallet: WKWallet, completion: ((UIViewController) -> Void)? = nil) {
        pushViewController("SwapViewController", context: ["wallet": wallet], completion: completion)
    }

    static func pushToConfirmSwap(wallet: WKWallet, vm: SwapModel, amountsMdoel: AmountsModel) {
        pushViewController("SwapConfirmViewController", context: ["wallet": wallet, "vm": vm, "amountsModel": amountsMdoel])
    }

    static func pushToSwapApprove(wallet: WKWallet, vm: SwapModel, completionHandler: @escaping (WKError?) -> Void) {
        pushViewController("SwapApproveViewController", context: ["wallet": wallet, "vm": vm, "handler": completionHandler])
    }

    static func pushToApproveEditPermission(wallet: WKWallet, vm: ApproveViewModel, completionHandler: ((String?) -> Void)? = nil) {
        pushViewController("EditPermissionViewController", context: ["wallet": wallet, "vm": vm, "handler": completionHandler])
    }

    static func showDebugView() {
        let viewController = WKDebugViewController()
        let navController = UINavigationController(rootViewController: viewController)
        viewController.modalPresentationStyle = .pageSheet
        Router.topViewController?.present(navController, animated: true, completion: nil)
    }

    static func showDebugWebView() {
        let viewController = WKDebugWebViewController()
        viewController.modalPresentationStyle = .fullScreen
        Router.topViewController?.present(viewController, animated: true, completion: nil)
    }

    static var isSecurityVerifying = false
    static func showSecurityVerificationIfNeed(completion: (() -> Void)? = nil) {
        if isSecurityVerifying { return }
        let viewController = Router.viewController("SecurityVerificationController")
        viewController.modalPresentationStyle = .fullScreen
        Router.topViewController?.present(viewController, animated: false, completion: completion)
    }

    static func showResetWalletNoticeAlert(completionHandler: @escaping (WKError?) -> Void) {
        Router.presentViewController("ResetWalletNoticeAlertController", context: ["handler": completionHandler])
    }
}

class TargetWallet: NSObject {
    override class func perform(action: String, parameter: [String: Any] = [:]) -> Any? {
        print("handle action:", action, parameter)
        switch action {
        case "empty":
            return "empty"
        default:
            assert(false, "has no action(\(action)) in Module:Wallet")
            return nil
        }
    }
}

extension Router {
    private static let TargetWallet = "TargetWallet"
    @discardableResult
    private static func perform(action: String, parameter: [String: Any] = [:]) -> Any? {
        return dispatch(task: Router.InvocationTask(Router.TargetWallet, action: action).set(parameters: parameter))
    }

    static func doNothing() {
        perform(action: "empty", parameter: ["xxx": "xxx"])
    }
}

extension Router {
    static func goSystemSetting() {
        if let URL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(URL as URL, options: [:], completionHandler: { (result) -> Void in
                WKLog.Verbose("\(result)")
                return
            })
        }
    }
}
