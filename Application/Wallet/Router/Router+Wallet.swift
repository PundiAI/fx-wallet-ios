//
//  Router+XWallet.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/5.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import WKKit
import Hero
import RxSwift
import SwiftyJSON
import TrustWalletCore
import HapticGenerator

public typealias Wallet = TrustWalletCore.Wallet



//MARK: Scene Router
extension Router {
    
    static var createWalletController: UIViewController { return viewController("CreateWalletViewController") }
    
    static func showAgreementAlert(doneHandler: @escaping (Bool) -> Bool, state:Bool = false) {
        pushViewController("AgreementViewController", context: ["handler": doneHandler, "state": state])
    }
    
    static var welcomeCreateWalletController: UIViewController { return viewController("WelcomeCreateWalletViewController") }
    
    static func pushToSetNickName(wallet: WKWallet, ticket: String = "", completion:((UIViewController) -> Void)? = nil) {
        pushViewController("SetNickNameViewController", context: ["wallet": wallet, "ticket": ticket], completion: completion)
    }
    
    static func setNickNameController(wallet: WKWallet, ticket: String = "") -> UIViewController {
        return viewController("SetNickNameViewController", context: ["wallet": wallet, "ticket": ticket])
    }

    static func pushToSetPasswordController(wallet: WKWallet) {
        pushViewController("SetPasswordViewController", context: ["wallet": wallet])
    }
    
    static func setPasswordController(wallet: WKWallet) -> UIViewController {
        return viewController("SetPasswordViewController", context: ["wallet": wallet])
    }
    
    static func pushToReSetPasswordViewController(wallet: WKWallet, pwd: String = "") {
        pushViewController("ReSetPasswordViewController", context: ["wallet": wallet, "pwd": pwd])
    }
    
    static func pushToSetBiometricsViewController(wallet: WKWallet) {
        pushViewController("SetBiometricsViewController", context: ["wallet": wallet])
    }
    
    static func setBiometricsViewController(wallet: WKWallet) -> UIViewController {
        return viewController("SetBiometricsViewController", context: ["wallet": wallet])
    }
    
    static func pushToNotificationController(wallet: WKWallet, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("NotifcationListPageController", context: ["wallet": wallet], completion: completion)
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
    
    static func pushToImportWallet(completion: ((UIViewController) -> Void)? = nil) {
        pushViewController("ImportWalletViewController", completion: completion)
    }
    
    static func pushToImportNamed(wallet: WKWallet) {
        pushViewController("ImportNamedViewController", context: ["wallet": wallet])
    }
    
    static func importNamedController(wallet: WKWallet) -> UIViewController {
        return viewController("ImportNamedViewController", context: ["wallet": wallet])
    }
    
    
    static func showBackAlert() {
        Haptic.impactMedium.generate()
        pushViewController("BackAlertViewController")
    }
    
    static func pushToBackUpNotice(wallet: WKWallet, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("BackUpNoticeViewController", context: ["wallet": wallet], completion:completion)
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
    
    static func showVisitSocialAlert(social: [String: Any], allowHandler: @escaping (Bool) -> Void) {
        presentViewController("VisitSocialAlertController", context: ["social": social, "handler": allowHandler])
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
    
    
    static func showCrossChainWeb(_ eth: (Coin?, String), fx: (Coin?, String), ethTofx: Bool = true) {
        pushViewController("SheetWebViewController", context: ["eth": eth, "fx": fx, "ethTofx": ethTofx])
    }
    
    static func showRemoveAddress(completionHandler: @escaping (WKError?) -> Void, presenCompletion:((UIViewController)->Void)? = nil) {
        Haptic.impactMedium.generate()
        pushViewController("RemoveAddressViewController", context:  ["handler": completionHandler], completion: presenCompletion)
    }
    
    static func pushToReceiveToken(coin: Coin, account: Keypair, completion:((UIViewController)->Void)? = nil) {
        Haptic.impactMedium.generate()
        pushViewController("ReceiveTokenViewController", context: ["coin": coin, "account": account], completion: completion)
    }
    
    static func showSelectAccount(wallet: WKWallet, current: (Coin, Keypair)?, filterCoin: Coin?, cancelHandler: (() -> Void)? = nil, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void) {
        
        var filter: ((Coin, [String: Any]?) -> Bool)?
        if let filterCoin = filterCoin { filter = { (coin, _) in coin.id == filterCoin.id } }
        showSelectAccount(wallet: wallet, current: current, filter: filter, cancelHandler: cancelHandler, confirmHandler: confirmHandler)
    }
    
    static func showSelectAccount(wallet: WKWallet, current: (Coin, Keypair)?, push: Bool = false, filter: ((Coin, [String: Any]?) -> Bool)? = nil, cancelHandler: (() -> Void)? = nil, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void) {
        
        let context: [String: Any?] = ["wallet": wallet, "currentCoin": current?.0, "currentAccount": current?.1, "push": push, "filter": filter, "handler": confirmHandler, "cancelHandler": cancelHandler]
        if push {
            pushViewController("SelectAccountViewController", context: context)
        } else {
            presentViewController("SelectAccountViewController", context: context)
        }
    }
    
    static func showSelectErc20Account(wallet: WKWallet, current: (Coin, Keypair)?, push: Bool = false, filter: ((Coin, [String: Any]?) -> Bool)? = nil, cancelHandler: (() -> Void)? = nil, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void) {
        
        let context: [String: Any?] = ["wallet": wallet, "currentCoin": current?.0, "currentAccount": current?.1, "showDisabledSection": false, "showMainBalance": true, "push": push, "filter": filter, "handler": confirmHandler, "cancelHandler": cancelHandler]
        if push {
            pushViewController("SelectAccountViewController", context: context)
        } else {
            presentViewController("SelectAccountViewController", context: context)
        }
    }
    
    static func showSelectErc20AccountToJump(wallet: WKWallet, current: (Coin, Keypair)?, push: Bool = false, filter: ((Coin, [String: Any]?) -> Bool)? = nil, cancelHandler: (() -> Void)? = nil, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void) {
        
        let context: [String: Any?] = ["wallet": wallet, "currentCoin": current?.0, "currentAccount": current?.1, "showDisabledSection": false, "showMainBalance": false, "push": push, "filter": filter, "handler": confirmHandler, "cancelHandler": cancelHandler]
        if push {
            pushViewController("SelectAccountViewController", context: context)
        } else {
            presentViewController("SelectAccountViewController", context: context)
        }
    }
    
    static func pushToSelectWalletConnectAccount(wallet: WKWallet, filter: ((Coin, [String: Any]?) -> Bool)? = nil, cancelHandler: (() -> Void)? = nil, confirmHandler: @escaping (UIViewController?, Keypair) -> Void) {
        pushViewController("SelectWalletConnectAccountController", context: ["wallet": wallet, "filter": filter, "handler": confirmHandler, "cancelHandler": cancelHandler])
    }
    
    static func pushToSelectOrAddAccount(wallet: WKWallet, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void, completion:((UIViewController)->Void)? = nil) {
        pushViewController("SelectOrAddAccountViewController", context: ["wallet": wallet, "handler": confirmHandler], completion: completion)
    }
    
    static func pushToSendTokenInput(wallet: WKWallet, coin: Coin, amount: String? = nil, account: Keypair? = nil, receiver: User? = nil, completion:((UIViewController)->Void)? = nil) {
        pushViewController("SendTokenInputViewController", context: ["wallet": wallet, "coin": coin, "amount": amount, "account": account, "receiver": receiver], completion: completion)
    }
    
    static func showPendingTxAlert(confirmHandler: ((WKError?, UIViewController?) -> Void)? = nil) {
        pushViewController("PendingTxAlertController", context: ["handler": confirmHandler])
    }
    
    static func pushToSendTokenFee(tx: FxTransaction,  account: Keypair, type:Int = 0,completionHandler: ((WKError?, JSON) -> Void)? = nil) {

        if let server = ChainTransactionServer.shared, tx.coin.chainType.isEthereumNet {

            _ = server.selectPendingTransaction(symbol: tx.coin.symbol, chainId: tx.coin.chainType.rawValue, address: tx.from)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (item) in

                    if let pendingTx = item, pendingTx.fromAddress.lowercased() == tx.from.lowercased() {

                        self.showPendingTxAlert { (error, alert) in
                            
                            if error == nil {
                                pushViewController("SendTokenFeeViewController", context: ["tx": tx, "account": account, "type":type, "handler": completionHandler]) { (_) in
                                    self.currentNavigator?.remove([alert])
                                }
                            } else if let handler = completionHandler {
                                handler(error, [:])
                            } else {
                                Router.pop(alert)
                            }
                        }
                    } else {
                        pushViewController("SendTokenFeeViewController", context: ["tx": tx, "account": account, "type":type, "handler": completionHandler])
                    }
            })
        } else {
            pushViewController("SendTokenFeeViewController", context: ["tx": tx, "account": account, "type":type, "handler": completionHandler])
        }
    }
    
    static func pushToSendTokenFeeOptions(tx: FxTransaction, account: Keypair, contentHeight:CGFloat, completionHandler: ((WKError?, JSON) -> Void)? = nil) {
        pushViewController("SendTokenFeeOptionsViewController", context: ["tx": tx,
                                                                          "account": account,
                                                                          "handler": completionHandler, "contentHeight":contentHeight])
    }
    
    static func pushToSendTokenCommit(tx: FxTransaction, wallet: WKWallet, account: Keypair, completion:((UIViewController)->Void)? = nil) {
        pushViewController("SendTokenCommitViewController", context: ["tx": tx, "wallet": wallet, "account": account], completion:completion)
    }
    
    static func pushToSendTokenCrossChainCommit(tx: FxTransaction, account: Keypair, completion:((UIViewController)->Void)? = nil) {
        pushViewController("SendTokenCrossChainCommitController", context: ["tx": tx, "account": account], completion:completion)
    }
    
    static func pushToCrossChainInfo(isE2F: Bool) {
        pushViewController("CrossChainInfoAlertController", context: ["isE2F": isE2F])
    }
    
    static func pushToSettings() { 
        pushViewController("SettingsViewController")
    }
    
    static func settingsController() -> UIViewController {
        return viewController("SettingsViewController")
    }
    
    static func pushViewConsensus(wallet: Wallet) {
        pushViewController("ViewConsensusViewController", context: ["wallet": wallet])
    }
    
    static func showNotificationList(wallet: Wallet) {
        presentViewController("NotificationPanelViewController", context: ["wallet": wallet])
    }
    
    static func showNotificationAlert(toSetting:Bool = false, completionHandler:  @escaping (Bool?) -> Void) {
        Haptic.success.generate()
        pushViewController("NotificationAlertController", context: ["toSetting":toSetting, "handler": completionHandler])
    }
    
    static func pushToPreMnemonic(mnemonic: String, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("PreMnemonicViewController", context: ["mnemonic": mnemonic], completion:completion)
    }
    
    static func preMnemonicController(mnemonic: String) -> UIViewController {
       return  viewController("PreMnemonicViewController", context: ["mnemonic": mnemonic])
    }
    
    
    static func pushToCheckBackUp(mnemonic: String, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("CheckBackUpViewController", context: ["mnemonic": mnemonic], completion:completion)
    }
    
    static func checkBackUpController(mnemonic: String) -> UIViewController {
        return viewController("CheckBackUpViewController", context: ["mnemonic": mnemonic])
    }
    
    static func showBackUpSuccess(completionHandler:  @escaping (Bool) -> Void, completion:((UIViewController) -> Void)? = nil) {
        presentViewController("VerifyAlertViewController", context: ["handler": completionHandler], completion:completion)
        
    }
    
    static func showBackUpError(completionHandler:  @escaping (Bool) -> Void, completion:((UIViewController) -> Void)? = nil) {
        presentViewController("VerifyAlertErrorViewController", context: ["handler": completionHandler], completion:completion)
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

    static func pushToSetCurrency(wallet: WKWallet) {
        pushViewController("SetCurrencyViewController", context: ["wallet": wallet])
    }

    static func pushToMessageSet(wallet: WKWallet) {
        pushViewController("MessageSetViewController", context: ["wallet": wallet])
    }
 
    static var isSecurityVerifying = false
    static func showSecurityVerificationIfNeed(completion:(() -> Void)? = nil) {
        if isSecurityVerifying { return }
        let viewController = Router.viewController("SecurityVerificationController")
        viewController.modalPresentationStyle = .fullScreen
        Router.topViewController?.present(viewController, animated: false, completion: completion) 
    }
    
    static func showResetWalletNoticeAlert(completionHandler: @escaping (WKError?) -> Void) {
        pushViewController("ResetWalletNoticeAlertController", context: ["handler": completionHandler])
    }
    
    static func showSettingNewtrok() {
        pushViewController("SettingNodesController")
    }
    
    static func showUnSupportNodeAlert(coin: Coin) {
        pushViewController("UnSupportAlertController", context: ["coin": coin])
    }
    
    static func showChangeNodeAlert(name: String, completionHandler:@escaping ((Bool) -> Void)) {
        pushViewController("ChangeNodeAlertController", context: ["name": name, "handler": completionHandler])
    } 
    
    static func showAddNewtrokNode(completionHandler:@escaping ((String) -> Void)) {
        pushViewController("AddNodesInputController", context: ["handler": completionHandler]) 
    }
    
    static func showWalletBackUpAlert(completionHandler: @escaping (WalletBackUpType) -> Void, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("WalletBackUpAlertController", context: ["handler": completionHandler], completion: completion)
    }
    
    static func showWalletBackUpAlertSecond(completionHandler: @escaping (WalletBackUpType) -> Void, topViewController:UIViewController?, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("WalletBackUpAlertSecondController", context: ["handler": completionHandler, "topViewController":topViewController], completion: completion)
    }
    
    static func pushToBTCAddressType(wallet: WKWallet) {
        pushViewController("BTCAddressTypeViewController", context: ["wallet": wallet])
    } 
}

//MARK: Invocation Router
class TargetWallet: NSObject {
    override class func perform(action: String, parameter: [String : Any] = [:]) -> Any? {
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
    private static func perform(action: String, parameter: [String : Any] = [:]) -> Any? {
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
