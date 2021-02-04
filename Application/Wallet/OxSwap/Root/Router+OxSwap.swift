//
//  Router+OxSwap.swift
//  fxWallet
//
//  Created by Pundix54 on 2020/12/29.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation
import WKKit
import RxSwift
import FunctionX
import SwiftyJSON
import TrustWalletCore
import HapticGenerator

//MARK: Scene Router
extension Router {
    static func pushToSwap(wallet: WKWallet,  current: (Coin, Keypair)? = nil, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("OxSwapViewController", context: ["wallet": wallet, "currentCoin": current?.0, "currentAccount": current?.1], completion:completion)
    }
    
    static func setSwapController(wallet: WKWallet,  current: (Coin, Keypair)? = nil, completion:((UIViewController) -> Void)? = nil) -> UIViewController {
        return viewController("OxSwapViewController", context: ["wallet": wallet, "currentCoin": current?.0, "currentAccount": current?.1])
    }

    static func pushToOxConfirmSwap(wallet: WKWallet, vm: OxSwapModel, amountsMdoel: OxAmountsModel) {
        pushViewController("OxSwapConfirmViewController", context: ["wallet": wallet, "vm": vm, "amountsModel": amountsMdoel])
    }

    static func showOxTipAlert(current: (String, String)) {
        Haptic.impactMedium.generate()
        presentViewController("OxNotFeeViewController", context:["minNeedPay": current.0, "balance": current.1])
    }
    
    static func showOxReceiveInfoToast(amountsMdoel: OxAmountsModel) {
        presentViewController("OxToastViewController", context: ["amountsModel": amountsMdoel])
    }
    
    static func pushToAdvancedSetting(wallet: WKWallet, completionHandler:((CGFloat) -> Void)? = nil) {
        pushViewController("AdvancedSettingViewController", context: ["wallet": wallet, "handler": completionHandler])
    }
    
    
    static func showToSelectCoin(wallet: WKWallet, filterCoin: Coin?, completionHandler:((Coin) -> Void)? = nil) {
        presentViewController("SelectReceiveCoinViewController", context: ["wallet": wallet, "filter": filterCoin, "handler": completionHandler])
    }
    
    static func showSelectPayAccount(wallet: WKWallet, current: (Coin, Keypair)?, filter: ((Coin, [String: Any]?) -> Bool)? = nil, cancelHandler: (() -> Void)? = nil, confirmHandler: @escaping (UIViewController?, Coin, Keypair) -> Void) {
        presentViewController("SelectPayAccountViewController", context: ["wallet": wallet, "currentCoin": current?.0, "currentAccount": current?.1, "filter": filter, "handler": confirmHandler, "cancelHandler": cancelHandler])
    }
}
