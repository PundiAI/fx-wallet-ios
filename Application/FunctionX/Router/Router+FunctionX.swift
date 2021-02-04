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

extension Router {
    
    static func showFxWalletConnect(url: String, wallet: WKWallet, completion:((UIViewController) -> Void)? = nil) {
        presentViewController("WalletConnectNavController", context: ["url": url, "wallet": wallet], completion: completion)
    }
    
    static func pushToFxCloudWalletConnect(url: String, wallet: Wallet, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("FxCloudWalletConnectViewController", context: ["url": url, "wallet": wallet], completion: completion)
    }
    
    static func showDisconnectWalletConnect(confirmHandler: @escaping (Bool) -> Void,completion:((UIViewController) -> Void)? = nil) {
        presentViewController("WalletConnectDisconnectAlertController", context: ["handler": confirmHandler], completion: completion)
    }
    
    static func showDisconnectWalletConnect() {
        presentViewController("WalletConnectBeKilledAlertController")
    }
    
    static func showWalletConnectExistAlert(completion:((UIViewController) -> Void)? = nil) {
        presentViewController("WalletConnectExistAlertController", completion: completion)
    }
    
    static func pushToAuthorizeWalletConnect(dapp: Dapp, types: [Int] = [0], 
                                             account: Keypair? = nil,
                                             allowHandler: @escaping (UIViewController?, Bool) -> Void, completion:((UIViewController) -> Void)? = nil) {
        pushViewController("WalletConnectAuthorizeController", context: ["dapp": dapp, "types": types, "account": account, "handler": allowHandler], completion: completion)
    }
    
    static func showWalletConnectSign(dapp: Dapp, message: Any, account: Keypair, confirmHandler: @escaping (Bool) -> Void) {
        pushViewController("WalletConnectSignAlertController", context: ["dapp": dapp, "message": message, "account": account, "handler": confirmHandler])
    }
    
    static func pushToSubmitValidatorAddress(wallet: Wallet, hrp: String, chainName: String, parameter: [String: Any]? = nil, confirmHandler: @escaping ((Keypair) -> ())) {
        pushViewController("FxCloudSubmitValidatorAddressViewController", context: ["wallet": wallet, "hrp": hrp, "chainName": chainName, "parameter": parameter ?? [:], "handler": confirmHandler])
    }
    
    static func pushToSubmitValidatorPublicKey(privateKey: PrivateKey, parameter: [String: Any]? = nil) {
        pushViewController("FxCloudSubmitValidatorPublicKeyViewController", context: ["privateKey": privateKey, "parameter": parameter ?? [:]])
    }
    
    static func pushToSubmitValidatorPublicKeyCompleted(keypair: FunctionXValidatorKeypair) {
        pushViewController("FxCloudSubmitValidatorPublicKeyCompletedViewController", context: ["keypair": keypair])
    }
    
    static func pushToSubmitValidatorKeypair(wallet: Wallet, hrp: String, chainName: String, parameter: [String: Any]? = nil, confirmHandler: @escaping ((Keypair) -> ())) {
        pushViewController("FxCloudSubmitValidatorKeypairViewController", context: ["wallet": wallet, "hrp": hrp, "chainName": chainName, "parameter": parameter ?? [:], "handler": confirmHandler])
    }
    
    static func pushToCreateValidator(hrp: String, chainName: String, txParams: [String: Any], confirmHandler: @escaping () -> Void) {
        pushViewController("FxCloudCreateValidatorViewController", context: ["hrp": hrp, "chainName": chainName, "txParams": txParams, "handler": confirmHandler])
    }
    
    static func pushToUnjailValidator(tx: FxTransaction, confirmHandler: @escaping () -> Void) {
        pushViewController("FxCloudUnjailValidatorViewController", context: ["tx": tx, "handler": confirmHandler])
    }
}
