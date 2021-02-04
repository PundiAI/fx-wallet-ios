//
//  SendCrossChainCommitBinder.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/12.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Web3
import WKKit
import RxSwift
import RxCocoa
import XChains
import FunctionX
import SwiftyJSON
import TrustWalletCore

extension SendTokenCommitViewController {
    
    class FxCrossChainBinder: RxObject {
        
        let view: View
        init(view: View) {
            self.view = view
        }
        
        private var tx: FxTransaction!
        private var coin: Coin { tx.coin }
        private var account: Keypair!
        private var wallet: WKWallet!
        
        private var csActionBag: DisposeBag!
        private var csBridge: FxBridgeInfo?
        lazy var isValidInput = BehaviorRelay<Bool>(value: false)
        
        func bind(tx: FxTransaction, account: Keypair, wallet: WKWallet) {
            self.tx = tx
            self.wallet = wallet
            self.account = account
            
            view.unlockView.relayout(isE2F: coin.isEthereum)
            isValidInput
                .bind(to: view.unlockView.actionView.submitButton.rx.isEnabled)
                .disposed(by: defaultBag)
        }
        
        func check(address: String) {
            view.showUnlock(false)
            guard address.count > 20 else { return }
            
            if coin.isEthereum {
                checkIsE2F(address)
            } else if coin.isFunctionX {
                checkIsF2E(address)
            }
        }
        
        //MARK: E2F(Deposit)
        private func checkIsE2F(_ address: String) {
            guard let (hrp, _) = FunctionXAddress.decode(address: address) else { return }
            
            weak var welf = self
            let fxEthereum = FunctionX.shared.ethereum
            view.loading(true)
            fetchFxBridgeInfo(hrp).flatMap{ info -> Observable<String> in
                guard let this = welf else { return .empty() }
                
                welf?.csBridge = info
                let bridge = FunctionXEthereumBridge(rpc: fxEthereum.rpc, chainId: fxEthereum.chainId, contract: info.bridgeContract)
                if this.coin.isETH {
                    return .just(bridge.maxApproveAmount.description)
                } else {
                    return bridge.isSupport(erc20: this.coin.contract).flatMap { isSupport -> Observable<String> in
                        guard isSupport else { return .error(WKError(.default, "unsupport fx address")) }
                        
                        return bridge.allowance(owner: this.account.address, spender: this.csBridge!.bridgeContract, tokenContract: this.coin.contract)
                    }
                }
            }.subscribe(onNext: { allowance in

                welf?.view.loading(false)
                welf?.isValidInput.accept(true)
                welf?.bindE2F(allowance)
            }, onError: { e in

                welf?.view.loading(false)
                welf?.isValidInput.accept(false)
                welf?.view.hud?.text(m: e.asWKError().msg)
                welf?.view.relayoutHeaderIfNeed()
            }).disposed(by: defaultBag)
        }
        
        private func bindE2F(_ allowance: String) {
            guard let bridge = csBridge else { return }
            
            allowanceIsEnough?.cancel()
            view.showUnlock(true, allowance.isGreaterThan(decimal: "0") ? .regular : .multiStep)
            view.unlockView.bridgeAddressLabel.attributedText = NSAttributedString(string: bridge.bridgeContract, attributes: [.font: XWallet.Font(ofSize: 14), .foregroundColor: COLOR.subtitle, .underlineColor: COLOR.subtitle, .underlineStyle: NSUnderlineStyle.single.rawValue])
            
            view.relayoutHeaderIfNeed()
            bindE2FActions()
        }
        
        private func bindE2FActions() {
            csActionBag = DisposeBag()
            guard let bridge = csBridge else { return }
            
            weak var welf = self
            let actionView = view.unlockView.actionView
            actionView.state = .normal
            actionView.approveButton.interactor.rx.tap.subscribe(onNext: { [weak self]value in
                guard let this = self else { return }
                
                actionView.state = .refresh
                this.view.isEditable = false
                this.buildApproveTx(bridge).subscribe(onNext: { tx in
                    this.view.isEditable = true

                    let tx = tx
                    if tx.fee.isGreaterThan(decimal: tx.balance) {
                        actionView.state = .disabled
                        this.view.hud?.text(m: "no enough \(this.coin.feeSymbol) to pay fee")
                    } else {

    //                    this.wallet.wk.receivers(forCoin: this.coin).addOrUpdate(receiver)
    //                    this.wallet.wk.accountRecord.addOrUpdate((this.coin, this.account))
                        
                        Router.pushToSendTokenFee(tx: tx, account: this.account, type: 1) { (error, result) in
                            
                            if result["hash"].string != nil { this.pollingCheckAllowance(bridge: bridge) }
                            if let e = error, !e.isUserCanceled { actionView.state = .normal }
                            
                            if WKError.canceled.isEqual(to: error) {
                                Router.pop(to: "SendTokenCommitViewController")
                            }
                        }
                    }
                }, onError: { e in
                    
                    actionView.state = .normal
                    welf?.view.hud?.text(m: e.asWKError().msg)
                    this.view.isEditable = true
                }).disposed(by: this.csActionBag ?? this.defaultBag)
            }).disposed(by: csActionBag)
            
            actionView.step2Button.interactor.rx.tap.subscribe(onNext: { value in
                welf?.doE2FSubmit(bridge)
            }).disposed(by: csActionBag)
            
            actionView.submitButton.rx.tap.subscribe(onNext: { value in
                welf?.doE2FSubmit(bridge)
            }).disposed(by: csActionBag)
        }
        
        var allowanceIsEnough: PollingTask<String>?
        private func pollingCheckAllowance(bridge: FxBridgeInfo) {
            
            weak var welf = self
            let node = EthereumNode(endpoint: NodeManager.shared.currentEthereumNode.url, chainId: 0)
            let task = PollingTask<String>(workFactory: {
                guard let this = welf else { return .error(WKError.timeout) }
                return node.allowance(owner: this.account.address, spender: bridge.bridgeContract, tokenContract: this.coin.contract)
            }, takeUtil: { $0.isGreaterThan(decimal: "1000".wei) })
            task.run().subscribe(onNext: { value in
                welf?.view.unlockView.actionView.state = .completed
            }).disposed(by: defaultBag)
            self.allowanceIsEnough = task
        }
        
        private func doE2FSubmit(_ bridge: FxBridgeInfo) {
            
            weak var welf = self
            self.view.hud?.waiting()
            buildE2FTx(bridge).subscribe(onNext: { tx in
                welf?.view.hud?.hide()
                guard let this = welf else { return }

                if tx.fee.isGreaterThan(decimal: tx.balance) {
                    this.view.hud?.text(m: "no enough \(this.coin.feeSymbol) to pay fee")
                } else {
                    Router.pushToSendTokenFee(tx: tx, account: this.account, type: 1)
                }
            }, onError: { e in
                welf?.view.hud?.hide()
                welf?.view.hud?.text(m: e.asWKError().msg)
            }).disposed(by: csActionBag)
        }
        
        private func buildApproveTx(_ bridge: FxBridgeInfo) -> Observable<FxTransaction> {
            
            let tx = FxTransaction()
            let node = FunctionXEthereumBridge(rpc: coin.node.url, chainId: coin.node.chainId.i, contract: bridge.bridgeContract)
            let rawTx = node.buildApproveTx(erc20: coin.contract, owner: account.address)
            
            let fetchGasLimit = node.estimatedGas(of: rawTx)
            let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
                tx.mutilGasPrice = v
                return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
            }

            var balance = wallet.balance(of: account.address, coin: coin)
            if coin.isERC20 {
                balance = wallet.balance(of: account.address, coin: .ethereum)
            }
            
            return Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance.refresh())
                .map { (gasPrice, gas, balance) -> FxTransaction in
                
                    var ethTx = rawTx
                    ethTx?.gas = EthereumQuantity(quantity: gas)
                    ethTx?.gasPrice = gasPrice
                    tx.sync(ethTx)
                    tx.balance = balance
                    tx.isApprove = true
                    return tx
            }.take(1)
        }
        
        private func buildE2FTx(_ bridge: FxBridgeInfo) -> Observable<FxTransaction> {
            
            let tx = self.tx!
            let node = FunctionXEthereumBridge(rpc: coin.node.url, chainId: coin.node.chainId.i, contract: bridge.bridgeContract)
            let amount = tx.amount
            let toAddress = view.inputTF.text ?? ""
            var rawTx: EthereumTransaction?
            if coin.isETH {
                rawTx = node.buildLockETHTx(from: account.address, to: toAddress, amount: BigUInt(amount) ?? 0)
            } else {
                rawTx = node.buildLockERC20Tx(from: account.address, to: toAddress, erc20: coin.contract, amount: BigUInt(amount) ?? 0)
            }
            
            let fetchGasLimit = node.estimatedGas(of: rawTx)
            let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
                tx.mutilGasPrice = v
                return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
            }
            
            var balance = wallet.balance(of: account.address, coin: coin)
            if coin.isERC20 {
                balance = wallet.balance(of: account.address, coin: .ethereum)
            }
            
            let coin = self.coin
            return Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance.refresh())
                .map { (gasPrice, gas, balance) -> FxTransaction in
                
                    var ethTx = rawTx
                    ethTx?.gas = EthereumQuantity(quantity: gas)
                    ethTx?.gasPrice = gasPrice
                    tx.sync(ethTx)
                    tx.coin = coin
                    tx.txType = coin.isETH ? .depositEthereum : .depositERC20
                    tx.balance = balance
                    tx.needVerify = true
                    tx.amountInData = amount
                    return tx
            }.take(1)
        }
        
        //MARK: F2E(Withdraw)
        
        private var F2EAccountBag: DisposeBag!
        private var F2EAccount: Keypair?
        private var F2EminGas = "500000"
        private var F2EminGasPrice = "40".gwei
        private var F2EminFee = "0.1".wei
        private var F2EGasPrice: MutilGasPrice?
        
        private func checkIsF2E(_ address: String) {
            guard coin.hrp.isNotEmpty, AnyAddress.isValid(string: address, coin: .ethereum) else { return }
    
            let wallet = FxCloudWallet(privateKey: account.privateKey)
            wallet.sync(chainId: coin.node.chainId, hrp: coin.hrp)
            let hub = FxHubNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: wallet)
            
            weak var welf = self
            view.loading(true)
            let fetchGasPrice = APIManager.fx.estimateGasPrice()
            let fetchBridgeInfo = fetchFxBridgeInfo(coin.hrp)
            let fetchBridgeErc20 = hub.ethBridge(ofSymbol: coin.symbol)
            Observable.combineLatest(fetchGasPrice, fetchBridgeErc20, fetchBridgeInfo).subscribe(onNext: { (gasPrice, erc20, bridge) in
                guard let this = welf else { return }

                this.F2EminGasPrice = gasPrice.normal
                this.F2EminFee = this.F2EminGas.mul(this.F2EminGasPrice, 18)
                this.F2EGasPrice = gasPrice

                welf?.view.loading(false)
                welf?.csBridge = bridge
                welf?.csBridge?.erc20Contract = erc20["token_contract"].stringValue
                welf?.isValidInput.accept(true)
                welf?.bindF2E()
            }, onError: { e in

                welf?.view.loading(false)
                welf?.isValidInput.accept(false)
                welf?.view.hud?.text(m: e.asWKError().msg)
                welf?.view.relayoutHeaderIfNeed()
            }).disposed(by: defaultBag)
        }
        
        private func bindF2E() {
            guard let bridge = csBridge else { return }
            
            view.showUnlock(true)
            self.isValidInput.accept(false)
            
            view.unlockView.feeLabel.text = "\(F2EminFee.div10(18)) ETH"
            view.unlockView.bridgeAddressLabel.attributedText = NSAttributedString(string: bridge.bridgeContract, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium), .foregroundColor: COLOR.title, .underlineColor: COLOR.subtitle, .underlineStyle: NSUnderlineStyle.single.rawValue])
            
            view.relayoutHeaderIfNeed()
            bindF2EActions()
        }
        
        private func bindF2EActions() {
            csActionBag = DisposeBag()
            guard let bridge = csBridge else { return }
            
            weak var welf = self
            let wallet = self.wallet!
            view.unlockView.feeProviderActionButton.rx.tap.subscribe(onNext: { value in
                Router.showSelectAccount(wallet: wallet, current: nil, filterCoin: .ethereum) { (vc, _, account) in
                    Router.dismiss(vc)
                    
                    welf?.bindF2E(account: account)
                    welf?.view.unlockView.feeProviderAddressLabel.text = account.address
                    welf?.view.unlockView.feeProviderPlaceHolderLabel.isHidden = true
                }
            }).disposed(by: csActionBag)
            
            view.unlockView.actionView.submitButton.rx.tap.subscribe(onNext: { value in
                welf?.doF2ESubmit(bridge)
            }).disposed(by: csActionBag)
        }
        
        private func bindF2E(account: Keypair) {
            self.F2EAccount = account
            self.F2EAccountBag = DisposeBag()
            
            let eth = CoinService.current.ethereum
            view.unlockView.tokenIV.setImage(urlString: eth.imgUrl, placeHolderImage: eth.imgPlaceholder)
            
            let balance = wallet.balance(of: account.address, coin: eth)
            balance.value.subscribe(onNext: { [weak self] value in
                self?.view.unlockView.feeProviderBalanceLabel.text = "\(value.div10(eth.decimal).thousandth()) \(eth.token)"
                
                let isInsufficient = self?.F2EminFee.isGreaterThan(decimal: value) == true
                self?.isValidInput.accept(!isInsufficient)
                self?.view.unlockView.relayout(isFeeError: isInsufficient)
                self?.view.relayoutHeaderIfNeed()
            }).disposed(by: F2EAccountBag)
        }
        
        private func doF2ESubmit(_ bridge: FxBridgeInfo) {
            
            weak var welf = self
            self.view.hud?.waiting()
            buildF2ETx(bridge).subscribe(onNext: { tx in
                welf?.view.hud?.hide()
                guard let this = welf else { return }
                
                if tx.fxProof.count == 0 {
                    Router.pushToSendTokenCrossChainCommit(tx: tx, wallet: this.wallet, account: this.account)
                } else {
                    Router.pushToSendTokenCrossChainRecommit(tx: tx, wallet: this.wallet, account: this.account)
                }
            }, onError: { e in
                welf?.view.hud?.hide()
                welf?.view.hud?.text(m: e.asWKError().msg)
            }).disposed(by: csActionBag)
        }
        
        private func buildF2ETx(_ bridge: FxBridgeInfo) -> Observable<FxTransaction> {
            guard let ethAccount = F2EAccount else { return .error(WKError(.default, "no ethereum account")) }
            
            let tx = self.tx!
            let eth = CoinService.current.ethereum
            tx.from = account.address
            tx.to = view.inputTF.text
            tx.coin = coin
            tx.txType = coin.isETH ? .withdrawEthereum : .withdrawERC20
            tx.fxBridge = bridge
            tx.f2eETHPrivateKey = ethAccount.privateKey.data.hexString
            tx.f2eETHAddress = ethAccount.address
            tx.f2eETHGasLimit = F2EminGas
            tx.f2eETHGasPrice = F2EminGasPrice
            tx.f2eETHBalance = wallet.balance(of: ethAccount.address, coin: eth).value.value
            if let v = F2EGasPrice {
                tx.f2eMutilGasPrice = v
            }
            
            let hub = FxHubNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: nil)
            let balance = self.wallet.balance(of: account.address, coin: coin)
            let fxBridge = FunctionXEthereumBridge(rpc: eth.node.url, chainId: eth.node.chainId.i, contract: bridge.bridgeContract)
            
            weak var welf = self
            let buildTx = fxBridge.fxNonce(of: account.address).flatMap{ fxNonce -> Observable<FxTransaction> in
                guard let this = welf else { return .empty() }
                
                tx.fxNonce = String(fxNonce)
                return hub.ethBridgeTxProof(ofNonce: UInt32(fxNonce), ethChainId: UInt32(eth.node.chainId) ?? 0, fxSender: tx.from)
                    .catchErrorJustReturn([:])
                    .flatMap{ proof -> Observable<FxTransaction> in
                        
                        if proof["claim_hash"].string != nil {
                            tx.fxProof = proof
                            return .just(tx)
                        } else {
                            
                            let asset = this.coin.isETH ? "0x0000000000000000000000000000000000000000" : bridge.erc20Contract ?? ""
                            let txMsg = TransactionMessage.withdrawEthereum(from: this.account.address, to: tx.to, asset: asset, bridge: bridge.bridgeContract, ethChainId: Int32(eth.node.chainId) ?? 0, fxNonce: String(fxNonce), amount: tx.amount, symbol: tx.denom, fee: "0", feeDenom: "", gas: 0)
                            return hub.estimatedFee(ofTx: txMsg).map { (gas: UInt64, gasPrice: String, fee: String) -> FxTransaction in
                                
                                tx.gasLimit = String(gas)
                                tx.gasPrice = gasPrice
                                tx.set(fee: fee, denom: this.coin.symbol)
                                return tx
                            }
                        }
                    }
            }
            
            return Observable.combineLatest(buildTx, balance.refresh())
                .map { (tx, balance) -> FxTransaction in
                    tx.balance = balance
                    return tx
            }.take(1)
        }
        
        private func fetchFxBridgeInfo(_ hrp: String) -> Observable<FxBridgeInfo> {
            return FunctionX.shared.ethereum.manager.bridgeRecords(of: hrp)
        }
    }
}
