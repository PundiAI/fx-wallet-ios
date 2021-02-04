//
//  FxValidatorConnectSession.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/5/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import FunctionX
import SwiftyJSON
import TrustWalletCore

class FxCloudWalletConnectSession: WalletConnectSession {
        
    init(id: String? = nil, url: String, wallet: Wallet) {
        self.wallet = wallet
        super.init(id: id, url: url)
        self.bindPing()
    }
    
    let wallet: Wallet
    
    var timer: Timer?
    let bag = DisposeBag()
    private func bindPing() {
        
        self.isConnected.subscribe(onNext: { [weak self](v) in
            self?.timer?.invalidate()
            if v {
                self?.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (_) in
                    self?.interactor?.approveRequest(id: Int64(Date().timestamp), result: "ping").cauterize()
                })
            }
        }).disposed(by: bag)
    }
    
    override func onSessionBeKilled() {
        super.onSessionBeKilled()
        Router.pop(viewController) {
            Router.showDisconnectWalletConnect()
        }
    }
    
    override var sessionIsAuthed: Bool { true }
    override func accounts(for peer: WCSessionRequestParam) -> [String] { return [] }
    
    override func handleMethod(_ request: JSON, _ method: String, _ parameter: JSON) {
        
        switch method {
        case "login":
            self.login(request, parameter: parameter)
        case "unjail":
            self.unjailValidator(request, parameter: parameter)
        case "create-validator":
            self.createValidator(request, parameter: parameter)
        case "sign-create-validator":
            self.signCreateValidator(request, parameter: parameter)
        case "get-node-validator-keyPair":
            self.getValidatorKeypair(request, parameter: parameter)
        case "get-validator-delegate-address":
            self.getDelegatorAddress(request, parameter: parameter)
        default: break
        }
    }
    
    //MARK: Actions
    
    private func login(_ request: JSON, parameter: JSON) {
        guard let rawData = parameter["data"].string else {
            error(.canceled, msg: "no data to sign", data: [:])
            return
        }
        
        let wallet = self.wallet
        let authView = WalletConnectAuthView(frame: ScreenBounds)
        authView.logoIV.image = IMG("Dapp.FxCloud")
        authView.logoIV.cornerRadius = 22
        authView.titleLabel.text = "FunctionX Cloud"
        authView.subtitleLabel.text = "Request to login"
        authView.eventHandler = { [weak self] allow in
            guard allow else {
                self?.error(.canceled, msg: "user denied", data: [:])
                return
            }
            
            Router.showSelectAccount(wallet: wallet.wk, current: nil, filterCoin: .hub) { (vc, _, account) in
                Router.dismiss(vc, animated: false)
                
                let data = rawData + account.publicKey().data.hexString
                let fxWallet = FxWallet(privateKey: account.privateKey)
                guard let signature = try? fxWallet.sign(data: data.data(using: .utf8)!) else {
                    self?.error(.canceled, msg: "sign failed", data: [:])
                    return
                }
                
                self?.response(data: ["nonce": parameter["nonce"].stringValue,
                                      "timestamp": parameter["timestamp"].stringValue,
                                      "pubKey": account.publicKey().data.hexString,
                                      "signature": signature.base64EncodedString()])
                
            }
        }
        
        Router.pop(self.viewController, animated: false)
        DispatchQueue.main.async {
            authView.show(inView: Router.topViewController!.view)
        }
    }
    
    private func getValidatorKeypair(_ request: JSON, parameter: JSON) {
        
        let hrp = parameter["prefix"].string ?? "fx"
        let chainName = parameter["chainId"].string ?? "--"
        let validatorPKHrp = hrp + "valconspub"
        Router.pushToSubmitValidatorKeypair(wallet: self.wallet, hrp: hrp, chainName: chainName, parameter: parameter.dictionaryObject) { (keypair) in
            
            let validatorKeypair = FunctionXValidatorKeypair(keypair.privateKey)
            self.response(data: ["nodeValidatorPublicKey": validatorKeypair.encodedPublicKey(hrp: validatorPKHrp) ?? "", "nodeValidatorPrivatekey": validatorKeypair.encodedPrivateKey()])
        }
        Router.currentNavigator?.remove([viewController])
    }
    
    private func getDelegatorAddress(_ request: JSON, parameter: JSON) {
        
        let hrp = parameter["prefix"].string ?? "fx"
        let chainName = parameter["chainId"].string ?? "--"
        let validatorHrp = hrp + "valoper"
        Router.pushToSubmitValidatorAddress(wallet: self.wallet, hrp: hrp, chainName: chainName, parameter: parameter.dictionaryObject) { keypair in
            
            let validatorAddress = FunctionXAddress(hrpString: validatorHrp, publicKey: keypair.publicKey().data)?.description ?? ""
            self.response(data: ["delegateAddress": keypair.address, "validatorAddress": validatorAddress, "derivationPath": keypair.derivationPath])
        }
        Router.currentNavigator?.remove([viewController])
    }

    private func signCreateValidator(_ request: JSON, parameter: JSON) {
        guard let derivationPath = parameter["derivationPath"].string?.bip44Path else {
            error(.canceled, msg: "no derivationPath", data: [:])
            return
        }
        
        let hrp = parameter["prefix"].string ?? "fx"
        let chainName = parameter["chainId"].string ?? "--"
        let hdWallet = wallet.key.wallet(password: Data())
        guard let privateKey = hdWallet?.getKey(derivationPath: derivationPath) else {
            error(.canceled, msg: "derivationPath is invalid", data: [:])
            return
        }
        
        Router.pushToCreateValidator(hrp: hrp, chainName: chainName, txParams: parameter.dictionaryValue) {
            
            Router.showAuthorizeDappAlert(dapp: .fxCloudWidget, types: [1]) { [weak self] (authVC, allow) in
                Router.dismiss(authVC, animated: false) {
                    guard allow else {
                        self?.error(.canceled, msg: "user denied", data: [:])
                        return
                    }
                    
                    let signer = CreateValidatorSigner(FxWallet(privateKey: privateKey))
                    let input = signer.input
                    input.fee = "0"
                    input.gas = 250000
                    input.denom = parameter["denom"].stringValue
                    input.amount = parameter["delegatorAmount"].stringValue
                    input.chainId = parameter["chainId"].stringValue
                    
                    input.commissionRate = parameter["commissionRate"].stringValue.formattedDecimal()
                    input.commissionMaxRate = parameter["maxCommissionRate"].stringValue.formattedDecimal()
                    input.commissionMaxChangeRate = parameter["maxChangeRate"].stringValue.formattedDecimal()
                    
                    input.details = parameter["description"].stringValue
                    input.moniker = parameter["name"].stringValue
                    input.website = parameter["website"].stringValue
                    input.identity = parameter["identity"].stringValue
                    input.securityContact = parameter["securityContact"].stringValue
                    
                    input.minSelfDelegation = parameter["minSelfDelegation"].stringValue
                    
                    input.validatorPublicKey = parameter["validatorPublicKey"].stringValue
                    input.delegatorAddress = parameter["delegatorAddress"].stringValue
                    input.validatorAddress = parameter["validatorAddress"].stringValue
                    
                    guard let signature = try? signer.sign() else {
                        self?.error(.canceled, msg: "sign failed", data: [:])
                        return
                    }
                    
                    self?.response(data: ["signature": signature.signature.base64EncodedString(),
                                          "publicKey": privateKey.getPublicKeySecp256k1(compressed: true).data.base64EncodedString()])
                    Router.currentNavigator?.popViewController(animated: true)
                }
            }
        }
        Router.currentNavigator?.remove([viewController])
    }
    
    private func createValidator(_ request: JSON, parameter: JSON) {
        guard let derivationPath = parameter["derivationPath"].string?.bip44Path else {
            error(.canceled, msg: "no derivationPath", data: [:])
            return
        }
        
        let hrp = parameter["prefix"].string ?? "fx"
        let chainName = parameter["chainId"].string ?? "--"
        let hdWallet = wallet.key.wallet(password: Data())
        guard let privateKey = hdWallet?.getKey(derivationPath: derivationPath) else {
            error(.canceled, msg: "derivationPath is invalid", data: [:])
            return
        }
        
        let tx = FxTransaction(parameter)
        let symbol = parameter["denom"].stringValue
        let fee = tx.gasPrice.mul(tx.gasLimit)
        tx.coin = Coin(id: Coin.CloudId, chain: .functionx, type: 118, name: chainName, symbol: symbol, decimal: 18)
        tx.set(fee: fee, denom: symbol)
        tx.set(amount: parameter["delegatorAmount"].stringValue, denom: symbol)
        tx.txType = .createValidator
        tx.validator = parameter["validatorAddress"].stringValue
        tx.delegator = parameter["delegatorAddress"].stringValue
        
        Router.pushToCreateValidator(hrp: hrp, chainName: chainName, txParams: parameter.dictionaryValue) {
            
            Router.showAuthorizeDappAlert(dapp: .fxCloudWidget, types: [1]) { [weak self] (authVC, allow) in
                Router.dismiss(authVC, animated: false) {
                    guard allow else {
                        self?.error(.canceled, msg: "user denied", data: [:])
                        return
                    }
                        
                    Router.showBroadcastTxAlert(tx: tx, privateKey: privateKey, completionHandler: { (error, result) in

                        if error == nil {
                            self?.response(data: result.dictionaryObject ?? [:])
                        } else if let err = error {
                            
                            if WKError.canceled.isEqual(to: err) {
                                DispatchQueue.main.async {
                                    Router.currentNavigator?.popViewController(animated: true)
                                }
                            } else {
                                self?.error(.canceled, msg: err.msg, data: [:])
                            }
                        }
                    })
                }
            }
        }
        Router.currentNavigator?.remove([viewController])
    }
    
    private func unjailValidator(_ request: JSON, parameter: JSON) {
        guard let derivationPath = parameter["derivationPath"].string?.bip44Path else {
            error(.canceled, msg: "no derivationPath", data: [:])
            return
        }
        
        let hdWallet = wallet.key.wallet(password: Data())
        guard let privateKey = hdWallet?.getKey(derivationPath: derivationPath) else {
            error(.canceled, msg: "derivationPath is invalid", data: [:])
            return
        }
        
        let tx = FxTransaction(parameter)
        tx.coin = Coin(id: Coin.CloudId, chain: .functionx, type: 118, name: parameter["chainId"].stringValue, symbol: parameter["denom"].stringValue, decimal: 18)
        tx.txType = .unjailValidator
        tx.validator = parameter["validatorAddress"].stringValue
        tx.delegator = FunctionXAddress(hrpString: parameter["prefix"].stringValue, publicKey: privateKey.getPublicKeySecp256k1(compressed: true).data)?.description ?? ""
        
        Router.pushToUnjailValidator(tx: tx) {
         
            Router.showAuthorizeDappAlert(dapp: .fxCloudWidget, types: [1]) { [weak self] (authVC, allow) in
                Router.dismiss(authVC, animated: false) {
                    guard allow else {
                        self?.error(.canceled, msg: "user denied", data: [:])
                        return
                    }
                        
                    Router.showBroadcastTxAlert(tx: tx, privateKey: privateKey, completionHandler: { (error, result) in

                        if error == nil {
                            self?.response(data: result.dictionaryObject ?? [:])
                        } else if let err = error {
                            
                            if WKError.canceled.isEqual(to: err) {
                                DispatchQueue.main.async {
                                    Router.currentNavigator?.popViewController(animated: true)
                                }
                            } else {
                                self?.error(.canceled, msg: err.msg, data: [:])
                            }
                        }
                    })
                }
            }
        }
        Router.currentNavigator?.remove([viewController])
    }
}

extension String {
    var bip44Path: String? {
        
        var result = self
        if result.contains("H") {
            result = result.replacingOccurrences(of: "H", with: "'")
            result = "m/\(result)"
        }
        return result.hasPrefix("m/44") ? result : nil
    }
}
