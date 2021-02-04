//
//  WalletConnectSession.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/6.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import Web3
import WKKit
import RxSwift
import RxCocoa
import XChains
import FunctionX
import SwiftyJSON
import TrustWalletCore

class FxWalletConnectSession: WalletConnectSession {
    
    init(id: String? = nil, url: String, wallet: WKWallet) {
        self.wallet = wallet
        super.init(id: id, url: url)
    }
    
    let wallet: WKWallet
    
    var coin = Coin.empty
    var dapp = Dapp.empty
    var account: Keypair!
    var privateKey: PrivateKey { account.privateKey }
    
    override var chainId: Int { coin.node.chainId.i }
    override func accounts(for peer: WCSessionRequestParam) -> [String] {
        if peer.isFunctionX {
            
            if !peer.isCloud {
                return [account.address, account.publicKey().data.hexString]
            } else {
                return [account.address, account.publicKey().data.hexString, coin.json.rawString() ?? ""]
            }
        } else {
            return [account.address]
        }
    }
    override func approveSession(_ id: Int64, _ peerParam: WCSessionRequestParam) {
        if account == nil {
            bindAccount(id, peerParam)
        } else {
            approveSession(true, id, peerParam)
        }
    }
    
    override func onSessionBeKilled() {
        super.onSessionBeKilled()
        if viewController == nil {
            Router.showDisconnectWalletConnect()
        } else {
            Router.pop(viewController) {
                Router.showDisconnectWalletConnect()
            }
        }
    }
    
    private func bindAccount(_ id: Int64, _ peerParam: WCSessionRequestParam) {
        
        weak var welf = self
        let peer = peerParam.peerMeta
        let icon = (peer.icons.first ?? "").replacingOccurrences(of: "./", with: "")
        let dapp = Dapp(url: peer.url, icon: icon, name: peer.name, detail: "")
        if !peerParam.isFunctionX {
            
            Router.showSelectWalletConnectAccount(wallet: wallet, cancelHandler: {
                welf?.approveSession(false, id, peerParam)
            }, confirmHandler: { (vc, account) in
                Router.pushToAuthorizeWalletConnect(dapp: dapp, account: account) { (authVC, allow) in
                    if allow {
                        welf?.coin = Coin.ethereum
                        welf?.dapp = dapp
                        welf?.account = account
                    }
                    welf?.approveSession(allow, id, peerParam)
                    Router.popToRoot(animated: true, completion: nil)
                }
            })
        } else {
            
            let filter: (Coin, [String: Any]?) -> Bool
            if peerParam.isCloud {
                filter = { (coin, _) in coin.isCloud }
            } else {
                filter = { (coin, _) in coin.id == peerParam.coin.id }
            }
            
            Router.showSelectAccount(wallet: wallet, current: nil, filter: filter, cancelHandler: {
                welf?.approveSession(false, id, peerParam)
            }, confirmHandler: { (vc, coin, account) in
                Router.dismiss(vc, animated: false) {
                    
                    Router.pushToAuthorizeWalletConnect(dapp: dapp, account: account) { (authVC, allow) in
                        Router.pop(authVC, animated: false) {
                            
                            if allow {
                                welf?.coin = coin
                                welf?.dapp = dapp
                                welf?.account = account
                            }
                            welf?.approveSession(allow, id, peerParam)
                        }
                   }
                    
                }
            })
        }
    }
    
    override func bind(interactor: WCInteractor) {
        super.bind(interactor: interactor)
        
        weak var welf = self
        interactor.eth.onSign = { (id, payload) in
            welf?.authSign(id, payload.message, {
                welf?.signEth(id, payload)
            })
        }
        
        interactor.eth.onTransaction = { (id, event, transaction) in
            
            if event == .ethSendTransaction {
                
//                welf?.auth(id, event.rawValue, {
                    welf?.sendEthTx(id, event, transaction)
//                })
            } else if event == .ethSignTransaction {
                
                welf?.authSign(id, event.rawValue, {
                    welf?.signEthTx(id, event, transaction)
                })
            }
        }
    }
    
    override func handleMethod(_ request: JSON, _ method: String, _ parameter: JSON) {
        
        switch method {
        case "functionx_sign":
            self.signFx(request, parameter: parameter)
        case "functionx_address":
            self.fxAddress(request, parameter: parameter)
        case "functionx_addchain":
            self.addFxCoin(request, parameter: parameter)
        case "functionx_accounts":
            self.getFxAccounts(request, parameter: parameter)
        case "functionx_sendTransaction":
            self.fxSendTx(request, parameter: parameter)
        default: break
        }
    }
    
    //MARK: Ethereum
    func signEth(_ id: Int64, _ payload: WCEthereumSignPayload) {
        
        let data = payload.data
        var result = privateKey.sign(digest: Hash.keccak256(data: data), curve: .secp256k1)!
        result[64] += 27
        interactor?.approveRequest(id: id, result: "0x" + result.hexString).cauterize()
    }
    
    func signTypedMessage(_ datas: [EthTypedData]) {
        let schemas = datas.map { $0.schemaData }.reduce(Data(), { $0 + $1 }).sha3(.keccak256)
        let values = datas.map { $0.typedData }.reduce(Data(), { $0 + $1 }).sha3(.keccak256)
        let combined = (schemas + values).sha3(.keccak256)
//        return signHash(combined, for: account)
    }
    
    func sendEthTx(_ id: Int64, _ event: WCEvent, _ transaction: WCEthereumTransaction, _ keypair: Keypair? = nil) {
        guard let account = keypair ?? self.account else {
            interactor?.rejectRequest(id: id, message: "miss privateKey").cauterize()
            return
        }
        
        weak var welf = self
        let bulidTx = self.buildEthTx(id, event, transaction)
        self.viewController?.hud?.waiting()
        _ = bulidTx.subscribe(onNext: { (tx) in
            welf?.viewController?.hud?.hide()
            guard let this = welf else { return }
            
            if transaction.gasPrice != nil {
                
                Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey,completionHandler: { error, json in
                    if let hash = json["hash"].string {
                        welf?.interactor?.approveRequest(id: id, result: "0x\(hash)").cauterize()
                    } else {
                        welf?.interactor?.rejectRequest(id: id, message: error?.asWKError().msg ?? "send tx failed").cauterize()
                    }
                    
                    if WKError.canceled.isEqual(to: error) {
                        welf?.pop()
                    }
                })
            } else {

                tx.balance = this.wallet.balance(of: account.address, coin: .ethereum).value.value
                Router.pushToSendTokenFee(tx: tx, account: account) { error, json in
                    if let hash = json["hash"].string {
                        welf?.interactor?.approveRequest(id: id, result: "0x\(hash)").cauterize()
                    } else {
                        welf?.interactor?.rejectRequest(id: id, message: error?.asWKError().msg ?? "send tx failed").cauterize()
                    }
                    
                    if WKError.canceled.isEqual(to: error) {
                        welf?.pop()
                    }
                }
            }
        }, onError: { (e) in
            welf?.viewController?.hud?.hide()
            welf?.interactor?.rejectRequest(id: id, message: e.asWKError().msg).cauterize()
        })
    }
    
    func signEthTx(_ id: Int64, _ event: WCEvent, _ transaction: WCEthereumTransaction) {
        
        weak var welf = self
        let chainId = NodeManager.shared.currentEthereumNode.chainId.quantity() ?? 1
        let privateKey = account.privateKey
        let bulidTx = self.buildEthTx(id, event, transaction)
        _ = bulidTx.subscribe(onNext: { (tx) in

            if let ethPrivateKey = try? EthereumPrivateKey(hexPrivateKey: privateKey.data.hexString),
                let signedTx = try? tx.ethTransaction?.sign(with: ethPrivateKey, chainId: chainId),
                let rawTx = signedTx.rlp().ethereumValue().string {
                welf?.interactor?.approveRequest(id: id, result: rawTx).cauterize()
            } else {
                welf?.interactor?.rejectRequest(id: id, message: "sign tx failed").cauterize()
            }
        }, onError: { (e) in
            welf?.interactor?.rejectRequest(id: id, message: e.asWKError().msg).cauterize()
        })
    }
    
    //MARK: FunctionX
    
    private func fxSendTx(_ request: JSON, parameter: JSON) {
  
        guard let chain = parameter.arrayValue.first?.string,
              let coin = coin(forChain: chain) else {
            interactor?.rejectRequest(id: currentRequestId, message: "miss args \(parameter.rawString() ?? "")").cauterize()
            return
        }
        
        let id = currentRequestId
        let args = JSON(parseJSON: parameter.arrayValue.last?.stringValue ?? "")
        Router.showSelectAccount(wallet: wallet, current: nil, filterCoin: coin) { [weak self](vc, _, account) in
            Router.dismiss(vc)
            
            if coin.isEthereum {
                
                let tx = WCEthereumTransaction(from: account.address,
                                               to: args["toAddress"].string,
                                               nonce: args["nonce"].string,
                                               gasPrice: args["gasPrice"].string,
                                               gas: args["gas"].string,
                                               gasLimit: args["gas"].string,
                                               value: args["value"].string ?? "0",
                                               data: args["data"].stringValue)
                self?.sendEthTx(id, .ethSendTransaction, tx, account)
            }
            
        }
    }
    
    private func signFx(_ request: JSON, parameter: JSON) {
        
        guard let address = parameter.arrayValue.first?.stringValue,
              let privateKey = privateKey(for: address),
              let txHex = parameter.arrayValue.last?.stringValue else {
            interactor?.rejectRequest(id: currentRequestId, message: "miss args \(parameter.rawString() ?? "")").cauterize()
            return
        }
        
        let id = currentRequestId
        self.authSign(id, txHex, { [weak self] in
          
            if let data = try? ECC.ecdsaCompactsign(data: Data(hex: txHex), privateKey: privateKey.data) {
                if self?.peerMeta?.isCloud == true || self?.peerMeta?.isFxHub == true {
                    
                    let response: JSON = ["sign": data.hexString, "publicKey": privateKey.getPublicKeySecp256k1(compressed: true).data.hexString ?? ""]
                    self?.interactor?.approveRequest(id: id, result: response.rawString() ?? "").cauterize()
                } else {
                    self?.interactor?.approveRequest(id: id, result: data.hexString).cauterize()
                }
            } else {
                self?.interactor?.approveRequest(id: id, result: "0x0").cauterize()
            }
        })
    }
    
    private func getFxAccounts(_ request: JSON, parameter: JSON) {
  
        let args = JSON(parseJSON: parameter.arrayValue.last?.stringValue ?? "")
        guard let address = parameter.arrayValue.first?.stringValue,
              let hrp = args["hrp"].string else {
            interactor?.rejectRequest(id: currentRequestId, message: "miss args \(parameter.rawString() ?? "")").cauterize()
            return
        }
        
        let id = currentRequestId
        weak var welf = self
        if args["isNodeValidator"].boolValue {
            
            let validatorPKHrp = hrp + "valconspub"
            Router.showFxValidatorSelectKeypairAlert(wallet: wallet, hrp: validatorPKHrp) { (vc, account) in
                Router.dismiss(vc, animated: true, completion: nil)
                
                let validatorKeypair = FunctionXValidatorKeypair(account.privateKey)
                let response: JSON = ["nodeValidatorPublicKey": validatorKeypair.encodedPublicKey(hrp: validatorPKHrp) ?? "", "nodeValidatorPrivateKey": validatorKeypair.encodedPrivateKey()]
                welf?.interactor?.approveRequest(id: id, result: response.rawString() ?? "").cauterize()
            }
        } else {
            
            let isValidator = args["isValidator"].boolValue
            let isPrivateKey = args["isPrivateKey"].boolValue
            Router.showAnyHrpSelectAddressAlert(wallet: wallet, hrp: hrp) { (vc, account) in
                Router.dismiss(vc, animated: true, completion: nil)
                
                var response: JSON = ["address": account.address, "publicKey": account.publicKey().data.hexString, "derivationPath": account.derivationPath]
                if isValidator {
                    response["validatorAddress"].string = FunctionXAddress(hrpString: "\(hrp)valoper", publicKey: account.publicKey().data)?.description ?? ""
                }
                if isPrivateKey {
                    response["privateKey"].string = account.privateKey.data.hexString
                }
                welf?.interactor?.approveRequest(id: id, result: response.rawString() ?? "").cauterize()
            }
        }
    }
    
    private func fxAddress(_ request: JSON, parameter: JSON) {
        var c: Coin?
        if let chain = parameter["chain"].string?.lowercased() {
            if chain == "ethereum" { c = .ethereum }
            else if chain == "hud" { c = .hub }
            else if chain == "order" { c = .order }
        }
        
        guard let coin = c else {
            interactor?.rejectRequest(id: currentRequestId, message: "miss args \(parameter.rawString() ?? "")").cauterize()
            return
        }
        
        let id = currentRequestId
        Router.showSelectAddressAlert(wallet: wallet, coin: coin) { [weak self](vc, account) in
            Router.dismiss(vc)
            
            var response: JSON = ["address": account.address, "publicKey": account.publicKey().data.hexString]
            if coin.isHub || coin.isETH { response["privateKey"].string = "391313a35f9a4b54d789c7d9b2dc4d6309e5e0d1986033f4714edf3411642905" }
            self?.interactor?.approveRequest(id: id, result: response.rawString() ?? "").cauterize()
        }
    }
    
    private func addFxCoin(_ request: JSON, parameter: JSON) {
        
        let args = JSON(parseJSON: parameter.arrayValue.last?.stringValue ?? "")
        guard let _ = parameter.arrayValue.first?.stringValue, args.count > 0 else {
            interactor?.rejectRequest(id: currentRequestId, message: "miss args").cauterize()
            return
        }
        
        let coin = Coin(cloudJson: args)
        Router.showAddCoinAlert(coin: coin) { [weak self] allow in
            guard allow else { return }
            self?.wallet.coinManager.add(coin)
        }
    }
    
    //MARK: Utils
    private func pop() {
        if viewController != nil {
            Router.pop(to: viewController)
        } else {
            Router.popToRoot()
        }
    }
    
    private func buildEthTx(_ id: Int64, _ event: WCEvent, _ transaction: WCEthereumTransaction) -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let coin = Coin.ethereum
        let node = EthereumNode(endpoint: coin.node.url, chainId: coin.node.chainId.i)
        let fetchGasPrice: Observable<EthereumQuantity>
        let fetchGasLimit: Observable<EthereumQuantity>
        if let v = transaction.gasPrice?.quantity() {
            fetchGasPrice = .just(v)
        } else {
            fetchGasPrice = APIManager.fx.estimateGasPrice().flatMap { v -> Observable<EthereumQuantity> in
                tx.mutilGasPrice = v
                return .just(EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0))
            }
        }
        
        if let v = transaction.gas?.quantity() ?? transaction.gasLimit?.quantity() {
            fetchGasLimit = .just(v)
        } else {
            
            let data = Data(hex: transaction.data)
            if data.isEmpty {
                fetchGasLimit = .just(21000)
            } else {
                fetchGasLimit = node.estimatedGasOfTx(from: transaction.from, to: transaction.to ?? "", value: transaction.value?.bigInt() ?? 0, data: data)
                    .map{ EthereumQuantity(quantity: $0 < 60000 ? 60000 : $0) }
            }
        }
        
        return Observable.combineLatest(fetchGasPrice, fetchGasLimit).map { t -> FxTransaction in
            let (gasPrice, gasLimit) = t
            
            var ethTx = transaction.tx
            ethTx.gas = gasLimit
            ethTx.gasPrice = gasPrice
            tx.sync(ethTx)
            return tx
        }
    }
    
    private func auth(_ id: Int64, _ method: String, _ handler: @escaping () -> ()) {
        Router.showAuthorizeDappAlert(dapp: self.dapp, types: [1]) { [weak self](authVC, allow) in
            
            Router.pop(authVC, animated: false) {
                if allow {
                    handler()
                } else {
                    self?.interactor?.rejectRequest(id: id, message: "User canceled").cauterize()
                }
            }
        }
    }
    
    private func authSign(_ id: Int64, _ message: Any, _ handler: @escaping () -> ()) {
        Router.showWalletConnectSign(dapp: self.dapp, message: message, account: account) { [weak self](allow) in
            guard allow else {
                self?.interactor?.rejectRequest(id: id, message: "User canceled").cauterize()
                return
            }
            
            Router.showVerifyPasswordAlert(dissmissWhenCompeted:false) { (error) in
                if error != nil {
                    self?.interactor?.rejectRequest(id: id, message: "sign failed").cauterize()
                } else {
                    Router.popToRoot() {
                        handler()
                    }
                }
            }
        }
    }
    
    private func privateKey(for address: String) -> PrivateKey? {
        if address.contains("/"), let path = address.bip44Path {
            return wallet.hd?.getKey(derivationPath: path)
        }
        if let privateKey = wallet.accounts(forCoin: self.coin).account(for: address)?.privateKey {
            return privateKey
        }
        return account.privateKey
    }
    
    private func coin(forChain chain: String) -> Coin? {
        
        let chain = chain.lowercased()
        if chain == "ethereum" { return .ethereum }
        if chain == "hud" { return .hub }
        if chain == "order" { return .order }
        return nil
    }
}


extension WCSessionRequestParam {
    var isFxDex: Bool { chainId == 39777 }
    var isFxHub: Bool { chainId == 39778 }
    var isCloud: Bool { chainId == 39779 }
    var isFunctionX: Bool { isFxDex || isFxHub || isCloud }
    
    var coin: Coin {
        if isFxDex { return .order }
        if isFxHub { return .hub }
        return .ethereum
    }
}
