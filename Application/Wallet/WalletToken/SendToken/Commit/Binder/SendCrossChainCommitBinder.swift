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
        
        private var bridgeBag: DisposeBag!
        private lazy var bridge: FunctionXEthereumBridge = {
            let node = NodeManager.shared.currentEthereumNode
            return FunctionXEthereumBridge(rpc: node.url, chainId: node.chainId.i, contract: ThisAPP.FxConfig.bridge())
        }()
        
        lazy var isValidInput = BehaviorRelay<Bool>(value: false)
        
        func bind(tx: FxTransaction, account: Keypair, wallet: WKWallet) {
            self.tx = tx
            self.wallet = wallet
            self.account = account
            
            isValidInput
                .bind(to: view.unlockView.actionView.submitButton.rx.isEnabled)
                .disposed(by: defaultBag)
            
            view.unlockView.tipButton.action {
                Router.pushToCrossChainInfo(isE2F: tx.coin.isEthereum)
            }
        }
        
        func check(address: String) {
            view.showUnlock(false)
            guard (coin.isERC20 || coin.isFunctionX) && address.count > 20 else { return }
            
            if coin.isERC20 {
                checkIsDeposit(address)
            } else if coin.isFunctionX {
                checkIsWithdraw(address)
            }
        }
        
        //MARK: E2F(Deposit)
        private func checkIsDeposit(_ address: String) {
            guard let (hrp, _) = FunctionXAddress.decode(address: address) else { return }
            
            weak var welf = self
            view.loading(true)
            view.unlockView.relayout(hrp == NodeManager.shared.currentFxNode.hrp ? .ethereumToFx : .ethereumToPay)
            bridge.isSupport(erc20: coin.contract).flatMap { isSupport -> Observable<String> in
                guard let this = welf else { return .empty() }
                guard isSupport else { return .error(WKError(.default, "invalid address")) }
                
                return this.bridge.allowance(owner: this.account.address, spender: this.bridge.address, tokenContract: this.coin.contract)
            }.subscribe(onNext: { allowance in

                welf?.view.loading(false)
                welf?.isValidInput.accept(true)
                welf?.bindDeposit(allowance)
            }, onError: { e in

                welf?.view.loading(false)
                welf?.isValidInput.accept(false)
                welf?.view.hud?.text(m: e.asWKError().msg)
                welf?.view.relayoutHeaderIfNeed()
            }).disposed(by: defaultBag)
        }
        
        private func bindDeposit(_ allowance: String) {
            allowanceIsEnough?.cancel()
            
            view.showUnlock(true, allowance.isGreaterThan(decimal: "10000".wei) ? .regular : .multiStep)
            view.relayoutHeaderIfNeed()
            bindDepositActions()
        }
        
        private func bindDepositActions() {
            bridgeBag = DisposeBag()
            
            weak var welf = self
            let actionView = view.unlockView.actionView
            actionView.state = .normal
            actionView.approveButton.interactor.rx.tap.subscribe(onNext: { [weak self]value in
                guard let this = self else { return }
                
                actionView.state = .refresh
                this.view.isEditable = false
                this.buildApproveTx().subscribe(onNext: { tx in
                    this.view.isEditable = true

                    let tx = tx
                    if tx.fee.isGreaterThan(decimal: tx.balance) {
                        actionView.state = .disabled
                        this.view.hud?.text(m: TR("Alert.Tip$", this.coin.feeSymbol))
                    } else {
                        
                        Router.pushToSendTokenFee(tx: tx, account: this.account, type: 1) { (error, result) in
                            
                            if error != nil, result.isEmpty { actionView.state = .normal }
                            if result["hash"].string != nil { this.pollingCheckAllowance() }
                            
                            if WKError.canceled.isEqual(to: error) {
                                Router.pop(to: "SendTokenCommitViewController")
                            }
                        }
                    }
                }, onError: { e in
                    
                    actionView.state = .normal
                    welf?.view.hud?.text(m: e.asWKError().msg)
                    this.view.isEditable = true
                }).disposed(by: this.bridgeBag ?? this.defaultBag)
            }).disposed(by: bridgeBag)
            
            actionView.step2Button.interactor.rx.tap.subscribe(onNext: { value in
                welf?.doDepositSubmit()
            }).disposed(by: bridgeBag)
            
            actionView.submitButton.rx.tap.subscribe(onNext: { value in
                welf?.doDepositSubmit()
            }).disposed(by: bridgeBag)
        }
        
        var allowanceIsEnough: PollingTask<String>?
        private func pollingCheckAllowance() {
            
            weak var welf = self
            let node = EthereumNode(endpoint: NodeManager.shared.currentEthereumNode.url, chainId: 0)
            let task = PollingTask<String>(workFactory: {
                guard let this = welf else { return .error(WKError.timeout) }
                return node.allowance(owner: this.account.address, spender: this.bridge.address, tokenContract: this.coin.contract)
            }, takeUtil: { $0.isGreaterThan(decimal: "10000".wei) })
            task.run().subscribe(onNext: { (value, e) in
                if value != nil {
                    welf?.view.unlockView.actionView.state = .completed
                } else if WKError.canceled.isEqual(to: e) {
                    welf?.view.unlockView.actionView.state = .disabled
                }
            }).disposed(by: defaultBag)
            self.allowanceIsEnough = task
        }
        
        private func doDepositSubmit() {
            
            weak var welf = self
            self.view.hud?.waiting()
            buildDepositTx().subscribe(onNext: { tx in
                welf?.view.hud?.hide()
                guard let this = welf else { return }

                if tx.fee.isGreaterThan(decimal: tx.balance) {
                    this.view.hud?.text(m: TR("Alert.Tip$", this.coin.feeSymbol))
                } else {
                    this.addOrUpdateReceiver()
                    Router.pushToSendTokenFee(tx: tx, account: this.account, type: 1)
                }
            }, onError: { e in
                welf?.view.hud?.hide()
                welf?.view.hud?.text(m: e.asWKError().msg)
            }).disposed(by: bridgeBag)
        }
        
        private func buildApproveTx() -> Observable<FxTransaction> {
            
            let tx = FxTransaction()
            let node = self.bridge
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
        
        private func buildDepositTx() -> Observable<FxTransaction> {
            
            let tx = self.tx!
            let node = self.bridge//FunctionXEthereumBridge(rpc: coin.node.url, chainId: coin.node.chainId.i, contract: bridge.address)
            let amount = tx.amount
            let toAddress = view.inputTF.text ?? ""
            let isToPay = toAddress.hasPrefix(NodeManager.shared.currentFxPaymentNode.hrp)
            var rawTx: EthereumTransaction?
            let fxChain = isToPay ? 1 : 0
            if coin.isETH {
                rawTx = node.buildDepositErc20Tx(from: account.address, to: toAddress, fxChain: fxChain, erc20: coin.contract, amount: BigUInt(amount) ?? 0)
            } else {
                rawTx = node.buildDepositErc20Tx(from: account.address, to: toAddress, fxChain: fxChain, erc20: coin.contract, amount: BigUInt(amount) ?? 0)
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
                    tx.txType = isToPay ? .ethereumToPay : .ethereumToFx
                    tx.balance = balance
                    tx.needVerify = true
                    tx.to = toAddress
                    tx.set(amount: amount, denom: coin.symbol)
                    return tx
            }.take(1)
        }
        
        //MARK: F2E(Withdraw)
        private func checkIsWithdraw(_ address: String) {
            guard !coin.isPAYC, !address.hasPrefix(coin.node.hrp) else { return }
            
            let isToEthereum = AnyAddress.isValid(string: address, coin: .ethereum)
            guard isToEthereum || FunctionXAddress.isValid(string: address) else { return }
            
            if isToEthereum {
                view.unlockView.relayout(coin.isFxCore ? .fxToEthereum : .payToEthereum)
            } else {
                view.unlockView.relayout(coin.isFxCore ? .fxToPay : .payToFx)
            }
            
            let checkCoinIsSupport: Observable<Bool>
            if coin.isFXC {
                checkCoinIsSupport = .just(true)
            } else {
                checkCoinIsSupport = bridge.isSupport(erc20: coin._contract)
            }
            
            weak var welf = self
            view.loading(true)
            checkCoinIsSupport.flatMap { isSupport -> Observable<Bool> in
                guard isSupport else { return .error(WKError(.default, "invalid address")) }
                return .just(isSupport)
            }.subscribe(onNext: { allowance in

                welf?.view.loading(false)
                welf?.bindWithdraw()
            }, onError: { e in

                welf?.view.loading(false)
                welf?.isValidInput.accept(false)
                welf?.view.hud?.text(m: e.asWKError().msg)
                welf?.view.relayoutHeaderIfNeed()
            }).disposed(by: defaultBag)
            
//            bindWithdraw()
        }
        
        private func bindWithdraw() {
            
            isValidInput.accept(true)
            
            view.showUnlock(true)
            view.relayoutHeaderIfNeed()
            bindWithdrawActions()
        }
        
        private func bindWithdrawActions() {
            bridgeBag = DisposeBag()
            
            weak var welf = self
            view.unlockView.actionView.submitButton.rx.tap.subscribe(onNext: { value in
                welf?.doWithdrawSubmit()
            }).disposed(by: bridgeBag)
        }
        
        private func doWithdrawSubmit() {
            
            weak var welf = self
            self.view.hud?.waiting()
            buildWithdrawTx().subscribe(onNext: { tx in
                welf?.view.hud?.hide()
                guard let this = welf else { return }
                
                this.addOrUpdateReceiver()
                this.tx.adjustF2EMaxAmountIfNeed()
                Router.pushToSendTokenCrossChainCommit(tx: tx, account: this.account)
            }, onError: { e in
                welf?.view.hud?.hide()
                welf?.view.hud?.text(m: e.asWKError().msg)
            }).disposed(by: bridgeBag)
        }
        
        private func buildWithdrawTx() -> Observable<FxTransaction> {
            
            let tx = self.tx!
            tx.from = account.address
            tx.to = view.inputTF.text
            
            let isToEthereum = AnyAddress.isValid(string: tx.to, coin: .ethereum)
            if !isToEthereum {
                tx.txType = coin.isFxCore ? .fxToPay : .payToFx
            } else {
                tx.txType = coin.isFxCore ? .fxToEthereum : .payToEthereum
            }
            
            return setBridgeFee().flatMap{ [weak self] _ -> Observable<FxTransaction> in
                guard let this = self else { return .empty() }

                if tx.txType == .fxToEthereum {
                    return this.buildFxCoreToEthereumTx()
                } else {
                    return this.buildIbcTransferTx(isToEthereum ? .ethereum : .functionx)
                }
            }
        }
        
        private func buildFxCoreToEthereumTx() -> Observable<FxTransaction> {
            guard let amount = estimatedTxAmount() else {
                return .error(WKError(.default, TR("Alert.Tip$", tx.token)))
            }
            
            let tx = self.tx!
            let fxWallet = FxWallet(privateKey: account.privateKey, chain: .core)
            let node = FxHubNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: fxWallet)
            let feeCoin = CoinService.current.fxCore
            let balance = wallet.balance(of: account.address, coin: feeCoin)
            
            let buildTx = node.buildWithdrawEthereumTx(to: tx.to, amount: amount, amountDenom: tx.denom, bridgeFee: tx.csBridgeFee, bridgeFeeDenom: tx.csBridgeDenom, txFee: "1", txFeeDenom: feeCoin.symbol, gas: 0).flatMap{ txMsg in

                return node.estimatedFee(ofTx: txMsg).map { (gas: UInt64, gasPrice: String, fee: String) -> FxTransaction in

                    tx.feeCoin = feeCoin
                    tx.gasLimit = String(gas)
                    tx.gasPrice = gasPrice
                    tx.set(fee: fee, denom: feeCoin.symbol)
                    return tx
                }
            }
            return Observable.combineLatest(buildTx, balance.refresh())
                .map { (tx, balance) -> FxTransaction in
                    tx.balance = balance
                    return tx
            }.take(1)
        }
        
        private func buildIbcTransferTx(_ router: TransactionMessage.IBCTransferRouter) -> Observable<FxTransaction> {
            guard let amount = estimatedTxAmount() else {
                return .error(WKError(.default, TR("Alert.Tip$", tx.token)))
            }
            
            let tx = self.tx!
            let fxWallet = FxWallet(privateKey: account.privateKey, chain: tx.coin.fxChain)
            let node = FxNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: fxWallet)
            let balance = wallet.balance(of: account.address, coin: coin)
            
            let txFeeDenom = tx.coin.fxChain.symbol
            let buildTx = node.buildIBCTransferTx(to: tx.to, router: router, amount: amount, amountDenom: tx.denom, bridgeFee: tx.csBridgeFee, bridgeFeeDenom: tx.csBridgeDenom, txFee: "1", txFeeDenom: txFeeDenom, gas: 0).flatMap{ txMsg in

                return node.estimatedFee(ofTx: txMsg).map { (gas: UInt64, gasPrice: String, fee: String) -> FxTransaction in

                    tx.gasLimit = String(gas)
                    tx.gasPrice = gasPrice
                    tx.set(fee: fee, denom: txFeeDenom)
                    return tx
                }
            }
            return Observable.combineLatest(buildTx, balance.refresh())
                .map { (tx, balance) -> FxTransaction in
                    tx.balance = balance
                    return tx
            }.take(1)
        }
        
        private func setBridgeFee() -> Observable<FxTransaction> {
            
            tx.csBridgeDenom = coin.symbol
            guard tx.txType == .fxToEthereum || tx.txType == .payToEthereum else {
                return .just(tx)
            }
            
            let tx = self.tx!
            let feeCoin = coin
            let feeBalance = wallet.balance(of: account.address, coin: feeCoin)
            return APIManager.fx.fetchFxBridgeFee(of: coin.chain).flatMap{ fee -> Observable<FxTransaction> in
                if fee.normal.isGreaterThan(decimal: feeBalance.value.value) {
                    return .error(WKError(.default, TR("Alert.Tip$", feeCoin.symbol.displayCoinSymbol)))
                }
                
                tx.csBridgeFee = fee.normal
                tx.csMutilGasPrice = fee
                tx.csBridgeFeeCoin = feeCoin
                tx.csBridgeBalance = feeBalance.value.value
                return .just(tx)
            }
        }
        
        private func estimatedTxAmount() -> String? {
            
            var tempFee = "10"
            if tx.denom == tx.csBridgeDenom { tempFee = tempFee.add(tx.csBridgeFee) }
            let balance = wallet.balance(of: account.address, coin: coin).value.value
            let spend = tx.amount.add(tempFee)
            
            if balance.isGreaterThan(decimal: spend) { return tx.amount }
            if balance.isGreaterThan(decimal: tempFee) { return balance.sub(tempFee) }
            return nil
        }
        
        //MARK: Utils
        private func addOrUpdateReceiver() {
            guard let toCoin = tx.toCoin, let toAddress = view.inputTF.text else { return }
            
            wallet.receivers(forCoin: toCoin).addOrUpdate(User(address: toAddress))
            wallet.accountRecord.addOrUpdate((coin, account))
        }
    }
}
