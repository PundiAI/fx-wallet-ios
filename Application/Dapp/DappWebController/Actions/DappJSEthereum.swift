//
//  DappJSEthereum.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/22.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import WebKit
import RxSwift
import RxCocoa
import XWebView
import FunctionX
import SwiftyJSON

public class DappJSEthereum: TransactionDappJSAction {

    override public func support() -> [String] {
        return ["depositeEth", "approveErc20", "depositeErc20", "withdrawEth", "withdrawErc20"]
    }
    
    @objc func depositeEth(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .depositEthereum, params, callback)
    }
    
    @objc func approveErc20(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .depositERC20Approve, params, callback)
    }
    
    @objc func depositeErc20(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .depositERC20, params, callback)
    }
    
    @objc func withdrawEth(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .withdrawEthereum, params, callback)
    }
       
    @objc func withdrawErc20(_ params: [String: Any], _ callback: XWVScriptObject) {
        send(tx: .withdrawERC20, params, callback)
    }
    
    private func send(tx txType: MessageType, _ params: [String: Any], _ callback: XWVScriptObject) {
        
//        print(params)
        
        let json = JSON(params)
        let tx = FxTransaction(json)
        tx.txType = txType
        tx.coin = tx.isFxDeposit ? .ethereum : .order
        guard let account = dappManager.account(for: dapp) else {
            callback.error(code: .internalError)
            showSelectAddressAlert(tx.coin, symbol: tx.token)
            return
        }
        
        tx.to = json["toAddress"].stringValue
        tx.from = account.address
        
        DispatchQueue.main.async {
            
            Router.showAuthorizeDappAlert(dapp: self.dapp, types: [1]) { [weak self] (authVC, allow) in
                Router.dismiss(authVC, animated: false) {
                    guard allow else {
                        callback.error(code: .userCanceled)
                        self?.webViewController?.hud?.text(m: "user denied")
                        return
                    }
                        
                    Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: { (error, result) in

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
