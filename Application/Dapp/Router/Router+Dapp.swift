//
//  Router+XWallet.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/5.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import FunctionX
import SwiftyJSON
import TrustWalletCore
import SafariServices

//MARK: Scene Router
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
    
    static func showFxExplorer(url: String? = nil, push: Bool = true , completion:((UIViewController) -> Void)? = nil) {
        
        var dapp = Dapp.fxExplorer
        if let url = url { dapp.displayUrl = url }

        if push {
            pushViewController("DappWebViewController", context: ["dapp": dapp], completion: completion)
        } else {
            presentViewController("DappWebViewController", context: ["dapp": dapp], completion: completion)
        }
    }
    
    static func showExplorer(_ coin: Coin, path: ExplorerURL.Path? = nil, push: Bool = true, completion:((UIViewController) -> Void)? = nil) {
        
        if coin.isFunctionX {
            showFxExplorer(url: ExplorerURL(coin, path: path).description, push: push, completion: completion)
        } else { 
            showWebViewController(url: ExplorerURL(coin, path: path).description, push: push, completion: completion)
        }
    }
    
    static func pushToChatList(privateKey: PrivateKey) {
        pushViewController("ChatListViewController", context: ["privateKey": privateKey, "coin": "Fx"])
    }
    
    static func presentNewChat(wallet: FxWallet, didAddContactHandler: @escaping (() -> Void)) {
        presentViewController("NewChatViewController", context: ["wallet": wallet, "handler": didAddContactHandler])
    }
    
    static func showChatMessageEncryptedTipAlert() {
        presentViewController("FxTipAlert", context: ["type": 0])
    }
    
    static func pushToFxStaking(wallet: WKWallet, npxs: Coin, fx: Coin) {
        pushViewController("FxStakingOverviewViewController", context: ["wallet": wallet, "npxs": npxs, "fx": fx])
    }
    
    static func pushToFxStake(wallet: WKWallet, coin: Coin, account: Keypair) {
        pushViewController("FxStakeViewController", context: ["wallet": wallet, "coin": coin, "account": account])
    }
    
    static func pushToFxRedeem(wallet: WKWallet, coin: Coin, account: Keypair) {
        pushViewController("FxRedeemViewController", context: ["wallet": wallet, "coin": coin, "account": account])
    }
    
    static func pushToFxClaim(wallet: WKWallet, coin: Coin, account: Keypair) {
        pushViewController("FxClaimViewController", context: ["wallet": wallet, "coin": coin, "account": account])
    }
    
    static func pushToNPXSSwap(wallet: WKWallet, coin: Coin) {
        pushViewController("NPXSSwapViewController", context: ["wallet": wallet, "coin": coin])
    }
    
    static func pushToValidatorList(wallet: WKWallet, coin: Coin) {
        pushViewController("FxValidatorListViewController", context: ["wallet": wallet, "coin": coin])
    }
    
    static func pushToFxMyDelegates(wallet: WKWallet, coin: Coin) {
        pushViewController("FxMyDelegatesViewController", context: ["wallet": wallet, "coin": coin])
    }
    
    static func pushToFxValidatorOverview(wallet: WKWallet, coin: Coin, validator: Validator, account: Keypair?) {
        pushViewController("FxValidatorOverviewViewController", context: ["wallet": wallet, "coin": coin, "validator": validator, "account": account])
    }
    
    static func pushToERC20ToFxTransferAlert(wallet: WKWallet, coin: Coin, account: Keypair) {
        pushViewController("ERC20ToFxTransferAlertController", context: ["wallet": wallet, "coin": coin, "account": account])
    }
    
    static func pushToFxDelegate(wallet: WKWallet, coin: Coin, validator: Validator, account: Keypair?) {
        pushViewController("FxDelegateViewController", context: ["wallet": wallet, "coin": coin, "validator": validator, "account": account])
    }
    
    static func pushToFxUndelegate(wallet: WKWallet, coin: Coin, validator: Validator, account: Keypair) {
        pushViewController("FxUndelegateViewController", context: ["wallet": wallet, "coin": coin, "validator": validator, "account": account])
    }
    
    static func pushToFxRewards(wallet: WKWallet, coin: Coin, validator: Validator, account: Keypair) {
        pushViewController("FxRewardsViewController", context: ["wallet": wallet, "coin": coin, "validator": validator, "account": account])
    }
    
    static func pushToCryptoBankAllAsserts(wallet: WKWallet) {
        pushViewController("CryptoBankAllAssertsViewController", context: ["wallet": wallet])
    }
    
    static func pushToCryptoBankAssetsOverview(wallet: WKWallet, coin: Coin) {
        pushViewController("CryptoBankAssetsOverviewViewController", context: ["wallet": wallet, "coin": coin])
    }
    
    static func pushToCryptoBankMyDeposits(wallet: WKWallet) {
        pushViewController("CryptoBankMyDepositsViewController", context: ["wallet": wallet])
    }
    
    static func pushToCryptoBankTxHistory(wallet: WKWallet) {
        pushViewController("CryptoBankTxHistoryViewController", context: ["wallet": wallet])
    }
    
    static func pushToCryptoBankDeposit(wallet: WKWallet, coin: Coin, account: Keypair) {
        pushViewController("CryptoBankDepositViewController", context: ["wallet": wallet, "coin": coin, "account": account])
    }
    
    static func pushToCryptoBankWithdraw(wallet: WKWallet, coin: Coin, account: Keypair) {
        pushViewController("CryptoBankWithdrawViewController", context: ["wallet": wallet, "coin": coin, "account": account])
    }
    
    static func showCashBuyController(coin: Coin) {
        pushViewController("CashBuyViewController", context: ["coin": coin])
    }
    
    static func showRampWebController(userAddress:String, swapAsset:String, swapAmount:String) ->UIViewController {
        let request = RampApi(userAddress: userAddress, swapAsset: swapAsset, swapAmount: swapAmount) 
        let config = SFSafariViewController.Configuration()
        let rampVC = SFSafariViewController(url: request.url(), configuration: config) 
        rampVC.modalPresentationStyle = .overFullScreen
        Router.topViewController?.present(rampVC, animated: true)
        return rampVC
    }
    
    static func pushToAllPurchaseController() {
        pushViewController("AllPurchaseViewController")
    }
}








