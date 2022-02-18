//
//  DappJSAccount.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/22.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import XWebView
import FunctionX
import SwiftyJSON

extension UserDefaults {
    
    fileprivate static var authKey: String { "fx.dapp.auth" }
    fileprivate static var authInfo: [String: Bool] {
        set { standard.setValue(newValue, forKey: authKey) }
        get { (standard.dictionary(forKey: authKey) as? [String: Bool]) ?? [:]  }
    }
}

public class DappJSAccount: TransactionDappJSAction {
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.authKey)
    }
    
    override public func support() -> [String] {
        return ["getAddress", "register"]
    }
    
    private func isAuthorized(type: Int) -> Bool { UserDefaults.authInfo["\(dapp.id)_\(type)"] ?? false }
    private func didAuthorize(type: Int) {
        
        var authInfo = UserDefaults.authInfo
        authInfo["\(dapp.id)_\(type)"] = true
        UserDefaults.authInfo = authInfo
    }
    
    @objc func getAddress(_ params: [String: Any], _ callback: XWVScriptObject) {
        
        var filter: (Coin, [String: Any]?) -> Bool = { _,_ in true }
        var authority = 0
        let chainName = string(forKey: "chainId", in: params) ?? FxChain.core.id
        if chainName == FxChain.core.id {
            filter = { coin,_ in coin.isFxCore }
        } else if chainName == FxChain.ethereum.id {
            authority = 3
            filter = { coin,_ in coin.isEthereum }
        }
        
        DispatchQueue.main.async {
            
            if self.isAuthorized(type: authority) {
                
                Router.showSelectAccount(wallet: self.wallet, current: nil, filter: filter) { vc, coin, account in
                    Router.dismiss(vc)
                    
                    callback.success(data: ["address": account.address, "publicKey": account.publicKey().data.hexString])
                }
            } else {
             
                Router.showAuthorizeDappAlert(dapp: self.dapp, types: [authority]) { (authVC, allow) in
                    Router.dismiss(authVC, animated: false) {
                        guard allow else {
                            callback.error(code: .userCanceled)
                            return
                        }

                        self.didAuthorize(type: authority)
                        Router.showSelectAccount(wallet: self.wallet, current: nil, filter: filter) { vc, coin, account in
                            Router.dismiss(vc)
                            
                            callback.success(data: ["address": account.address, "publicKey": account.publicKey().data.hexString])
                        }
                    }
                }
                
                
            }
        }
    }
    
    @objc func register(_ params: [String: Any], _ callback: XWVScriptObject) {
        
        callback.error(code: .unrecognizedParams)
        print("xxx FxChain no register")
        
//        guard let account = dappManager.account(for: dapp) else {
//            callback.error(code: .internalError)
//            showSelectAddressAlert(.hub)
//            return
//        }
//
//        guard let registerName = string(forKey: "name", in: params) else {
//            callback.error(code: .unrecognizedParams)
//            return
//        }
//
//        let json = JSON(params)
//        let tx = FxTransaction(json)
//        tx.from = account.address
//        tx.registerName = registerName
//        tx.txType = .userRegister
//        tx.coin = .hub
//        DispatchQueue.main.async {
//
//            Router.showAuthorizeDappAlert(dapp: self.dapp, types: [1]) { [weak self] (authVC, allow) in
//                Router.dismiss(authVC, animated: false) {
//                    guard allow else {
//                        callback.error(code: .userCanceled)
//                        self?.webViewController?.hud?.text(m: "user denied")
//                        return
//                    }
//
//                    Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: { (error, result) in
//
//                        if let err = error {
//                            callback.error(err)
//                        } else {
//                            callback.success(data: result.dictionaryObject ?? [:])
//                        }
//                    })
//                }
//            }
//        }
    }
    
}
