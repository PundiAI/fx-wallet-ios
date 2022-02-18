//
//  SendTokenFeeViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/8/11.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit
import SwiftyJSON
import TrustWalletCore

extension WKWrapper where Base == SendTokenFeeViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension SendTokenFeeViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction,
            let account = context["account"] as? Keypair else { return nil }
        let type:Int = context["type"] as? Int ?? 0
        let vc = SendTokenFeeViewController(tx: tx, account: account, type: type)
        vc.completionHandler = context["handler"] as? (WKError?, JSON) -> Void
        return vc
    }
}

class SendTokenFeeViewController: FxActionPopViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction, account: Keypair, type:Int) {
        self.tx = tx
        self.account = account
        self.heroType = type
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    let tx: FxTransaction
    var coin: Coin { tx.coin }
    let account: Keypair
    var heroType:Int = 0
    private var completionHandler: ((WKError?, JSON) -> Void)?
    
    override var interactivePopIsEnabled: Bool { false }
    
    override func getView() -> BaseView { View(frame: ScreenBounds).then { _ = $0.mainView.cornerRadius(36.auto(), layerRadius: true) }}
    override func bindListView() {
        bindTx()
    }
    
    private func bindTx() {
        
        let feeVM = WKTableViewCell.FeeCellViewModel(gas: tx.gasLimit, gasPrice: tx.mutilGasPrice, coin: tx.coin)
        let feeExchangeRate = coin.feeSymbol.exchangeRate().value.value
        if !feeExchangeRate.isUnknown {
            let legalFee = feeVM.fee.div10(coin.feeDecimal).mul(feeExchangeRate.value)
            feeVM.hideNotice = !legalFee.isGreaterThan(decimal: "30")
        }
        
        var optionsCell: OptionsCell?
        let amountCell = listBinder.push(AmountCell.self)
        let feeCell = listBinder.push(WKTableViewCell.FeeCell.self, vm: feeVM)
        if tx.coin.isEthereum || tx.isFxDeposit { optionsCell = listBinder.push(OptionsCell.self) }
        
        optionsCell?.actionButton.action { [weak self] in
            guard let this = self else { return }
            Router.pushToSendTokenFeeOptions(tx: this.tx, account: this.account, contentHeight: this.contentHeight, completionHandler: this.completionHandler)
        }
        
        feeCell.noticeButton.action {
            Router.showWebViewController(url: ThisAPP.WebURL.gasTrackerURL, push: true)
        }
        
        self.wk.view.submitButton.action { [weak self] in
            self?.doConfirm()
        }
        
        self.wk.view.closeButton.action {[weak self] in
            self?.tx.recoverMaxAmountIfNeed()
            if let handler = self?.completionHandler {
                handler(.canceled, [:])
            } else {
                Router.pop(self)
            }
        }
        
        feeVM.speed.subscribe(onNext: { [weak self](speed) in
            guard let this = self else { return }
            
            let coin = this.coin
            let fee = feeVM.fee.div10(coin.feeDecimal)
            let feeSymbol = this.coin.feeSymbol.displayCoinSymbol
            
            var spend = feeVM.fee
            if coin.isMainCoin {
                spend = this.tx.amount.add(feeVM.fee)
            }
            
            this.tx.set(fee: feeVM.fee, denom: this.tx.feeDenom)
            this.tx.gasPrice = feeVM.gasPrice
            
            let feeDecimal = ThisAPP.FeeDecimal
            let exchangeRate = feeSymbol.exchangeRate().value.value
            amountCell.amountLabel.text = "\(fee.thousandth(feeDecimal)) \(feeSymbol)"
            if !exchangeRate.isUnknown {
                amountCell.legalAmountLabel.wk.set(amount: fee.mul(exchangeRate.value), thousandth: ThisAPP.CurrencyDecimal, isLegal: true)
            } else {
                amountCell.legalAmountLabel.text = "$ \(unknownAmount)"
            }
            
            let isInsufficient = spend.isGreaterThan(decimal: this.tx.balance)
            if isInsufficient {
                
                var total = TR("SendToken.Fee.Total$$$$", spend.div10(coin.decimal).thousandth(feeDecimal), feeSymbol, fee.thousandth(feeDecimal), feeSymbol)
                let balance = TR("Balance") + ": \(this.tx.balance.div10(coin.decimal).thousandth(feeDecimal)) \(feeSymbol)"
                if this.coin.isERC20 {
                    total = TR("SendToken.Fee.Total$$", fee.thousandth(feeDecimal), feeSymbol)
                }
                this.wk.view.totalLabel.text = "\(total)\n\(balance)"
                this.wk.view.balanceLabel.text = balance
            }
            this.wk.view.submitButton.isEnabled = !isInsufficient
            this.wk.view.hideNotice(!isInsufficient)
            this.updateContentHeight()
        }).disposed(by: defaultBag)
    }
    
    private func bindFxWithdrawTx() {
        
//        let feeVM = WKTableViewCell.FeeCellViewModel(gas: "1", gasPrice: tx.csMutilGasPrice, coin: tx.csFeeCoin)
//        feeVM.useRawValue = true
//        
//        let amountCell = listBinder.push(AmountCell.self)
//        listBinder.push(WKTableViewCell.FeeCell.self, vm: feeVM)
//        
//        self.wk.view.submitButton.action { [weak self] in
//            self?.doConfirm()
//        }
//        
//        self.wk.view.closeButton.action {[weak self] in
//            if let handler = self?.completionHandler {
//                handler(.canceled, [:])
//            } else {
//                Router.pop(self)
//            }
//        }
//        
//        feeVM.speed.subscribe(onNext: { [weak self](speed) in
//            guard let this = self else { return }
//            
//            let tx = this.tx
//            let coin = this.tx.csFeeCoin
//            var csFee = feeVM.fee
//            let feeSymbol = coin.symbol.displayCoinSymbol
//            
//            var spend = feeVM.fee
//            var feeBalance = tx.csBridgeBalance
//            let isSameCoin = this.tx.coin.id == this.tx.csFeeCoin.id
//            if isSameCoin {
//                csFee = csFee.add(tx.fee)
//                spend = tx.amount.add(csFee)
//                feeBalance = tx.balance
//            }
//            
//            this.tx.csBridgeFee = feeVM.fee
//            
//            let feeDecimal = ThisAPP.FeeDecimal
//            let feeValue = csFee.div10(coin.feeDecimal)
//            let exchangeRate = feeSymbol.exchangeRate().value.value
//            amountCell.amountLabel.text = "\(feeValue.thousandth(feeDecimal)) \(feeSymbol)"
//            if !exchangeRate.isUnknown {
//                amountCell.legalAmountLabel.wk.set(amount: feeValue.mul(exchangeRate.value), thousandth: ThisAPP.CurrencyDecimal, isLegal: true)
//            } else {
//                amountCell.legalAmountLabel.text = "$ \(unknownAmount)"
//            }
//            
//            let isInsufficient = spend.isGreaterThan(decimal: feeBalance)
//            if isInsufficient {
//                
//                var total = TR("SendToken.Fee.Total$$$$", spend.div10(coin.decimal).thousandth(feeDecimal), feeSymbol, feeValue.thousandth(feeDecimal), feeSymbol)
//                let balance = TR("Balance") + ": \(feeBalance.div10(coin.decimal).thousandth(feeDecimal)) \(feeSymbol)"
//                if !isSameCoin {
//                    total = TR("SendToken.Fee.Total$$", feeValue.thousandth(feeDecimal), feeSymbol)
//                }
//                this.wk.view.totalLabel.text = "\(total)\n\(balance)"
//                this.wk.view.balanceLabel.text = balance
//            }
//            this.wk.view.submitButton.isEnabled = !isInsufficient
//            this.wk.view.hideNotice(!isInsufficient)
//            this.updateContentHeight()
//        }).disposed(by: defaultBag)
    }
    
    private func doConfirm() {
        
        if tx.isCrossChain {
            Router.pushToSendTokenCrossChainCommit(tx: tx, account: account)
            return
        }
        
        if let handler = completionHandler {
            Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: handler)
        } else {
            weak var welf = self
            Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: { (error, result) in
                guard welf != nil else { return }
                if WKError.canceled.isEqual(to: error) { 
                    if result.count == 0 {
                        Router.pop(to: "SendTokenInputViewController", elseToPreviousOrRoot: false)
                    } else if Router.canPop(to: "TokenInfoViewController") {
                        Router.pop(to: "TokenInfoViewController")
                    } else {
                        Router.popToRoot()
                    }
                }
            }, completion: { _ in
    //            if  !isApproveTx, Router.isExistInNavigator("SendTokenInputViewController") {
    //                Router.popAllButTop{ $0?.heroIdentity == "SendTokenInputViewController" }
    //            }
            })
        }
    }
    
    override func layoutUI() {
        super.layoutUI()
        
        view.backgroundColor = .clear
        wk.view.backgroundButton.backgroundColor = .white
     
        wk.view.navBar.relayoutForPopTitle()
        wk.view.navBar.backButton.title = TR("SendToken.Fee.Title")
    }
    
}

/// hero
extension SendTokenFeeViewController : HeroViewControllerDelegate  {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SendTokenCommitViewController", "SendTokenFeeViewController"): return animators["0"]
        case ("FxStakeViewController", "SendTokenFeeViewController"): return animators["3"]
        case ("SendTokenFeeViewController", "SendTokenFeeOptionsViewController"):  return animators["1"]
        case ("SendTokenFeeViewController", "BroadcastTxInfoController"):  return animators["2"]
        case (_,  "SendTokenFeeViewController"):  return animators["3"]
        case ("SendTokenFeeViewController", "SendTokenCrossChainCommitController"):  return animators["2"] 
        default: return nil
        }
    }
    
    private func bindHero() { 
        weak var welf = self
        
        let onSuspendBlock:(WKHeroAnimator) ->Void = { a in
            welf?.heroDidEndAnimator()
        }
        
        animators["0"] = WKHeroAnimator({ (a) in
            welf?.wk.view.backgroundView.hero.modifiers = [.fade, .useOptimizedSnapshot, .useGlobalCoordinateSpace] 
            welf?.wk.view.mainView.macawView.hero.id = "backgroundView"
            welf?.wk.view.mainView.macawView.hero.modifiers = [.resizableCap(UIEdgeInsets(top: 36.auto(), left: 36.auto(), bottom: 36.auto(), right: 36.auto()),
                                                                             .stretch), .useGlobalCoordinateSpace, .useOptimizedSnapshot, .spring]
            welf?.wk.view.contentView.hero.modifiers = [.scale(0.8),.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: ScreenHeight + 100), .spring]
        }, onSuspend: onSuspendBlock)
        
        animators["1"] = WKHeroAnimator({ (a) in
            welf?.wk.view.mainView.macawView.hero.id = "backgroundView"
            welf?.wk.view.mainView.macawView.hero.modifiers = [.masksToBounds(true), .resizableCap(UIEdgeInsets(top: 36.auto(), left: 36.auto(), bottom: 36.auto(), right: 36.auto()),
                                                                                         .stretch), .useGlobalCoordinateSpace, .useOptimizedSnapshot, .spring]
            welf?.wk.view.contentView.hero.modifiers = [.scale(0.8),.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(x: -1 * ScreenWidth), .spring]
        }, onSuspend: onSuspendBlock)
         
        animators["2"] = self.heroAnimatorBackgoundFrom()
        animators["3"] = self.heroAnimatorBackgound()
    }
    
    func heroWillStartAnimating(transition: HeroTransition) {
        if self.wk.view.mainView.macawView.hero.id != nil,
           let contentBGView = transition.context?.snapshotView(for: wk.view.mainView.macawView),
           let contentView = transition.context?.snapshotView(for: wk.view.contentView) {
            contentView.frame = CGRect(origin: CGPoint.zero, size: contentView.size)
            contentBGView.layer.masksToBounds = true
            contentBGView.addSubview(contentView)
        }
    }
}
