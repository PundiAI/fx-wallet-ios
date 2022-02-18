//
//  SendTokenCrossChainCommitController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/12.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit
import SwiftyJSON
import TrustWalletCore

private typealias InfoCell = WKTableViewCell.InfoCell
private typealias InfoCellViewModel = WKTableViewCell.InfoCellViewModel

extension WKWrapper where Base == SendTokenCrossChainCommitController {
    var view: Base.View { return base.view as! Base.View }
}

extension SendTokenCrossChainCommitController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction,
            let account = context["account"] as? Keypair else { return nil }
        
        return SendTokenCrossChainCommitController(tx: tx, account: account)
    }
}

class SendTokenCrossChainCommitController: FxRegularPopViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction, account: Keypair) {
        self.tx = tx
        self.account = account
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    let tx: FxTransaction
    var coin: Coin { tx.coin }
    let account: Keypair
    
    override func getView() -> BaseView { View(frame: ScreenBounds) }
    
    override var dismissWhenTouch: Bool { false }
    override var interactivePopIsEnabled: Bool { false }
    
    private var ethFeeCell: InfoCell?
    override func bindListView() {
        
        if tx.isFxDeposit {
            bindE2F()
        } else {
            bindF2E()
        }
        
        listBinder.scrollViewDidScroll = { [weak self] listView in
            
            let limit: CGFloat = 108
            let offset = min(limit, max(0, listView.contentOffset.y))
            self?.wk.view.navBar.alpha = (offset * 2) / limit
        }
    }
    
    override func bindAction() {
        
        weak var welf = self
        wk.view.cancelButton.action { welf?.pop() }
        wk.view.confirmButton.action { welf?.doConfirm() }
    }
    
    private func pop() {
        tx.csEditFeeType = ""
        Router.pop(to: ["SendTokenInputViewController", "FxValidatorOverviewViewController"])
    }
    
    private func doConfirm() {
        
        Router.showBroadcastTxVerifyPassword(tx: tx, privateKey: account.privateKey, completionHandler: { [weak self](error, result) in
            guard self != nil else { return }
            
            if WKError.canceled.isEqual(to: error) {
                if result.count == 0 {
                    self?.pop()
                } else {
                    Router.pop(to: ["TokenInfoViewController", "FxValidatorOverviewViewController"])
                }
            }
        }, completion: { _ in
//            if  Router.isExistInNavigator("SendTokenInputViewController") {
//                Router.popAllButTop{ $0?.heroIdentity == "SendTokenInputViewController" }
//            }
        })
    }
    
    private func bindE2F() {
        
        let legalFee = legal(amount: tx.decimalFee, token: tx.feeToken)
        let amountText = "\(tx.amount.div10(tx.coin.decimal).thousandth(tx.coin.decimal)) \(tx.denom.displayCoinSymbol)"
        wk.view.navSubtitleLabel.text = amountText
        
        listBinder.push(TitleCell.self)
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Amount"), content: amountText, corners: (true, true)))
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(SectionTitleCell.self){
            $0.titleLabel.text = TR("CrossChain.FromETH")
            $0.chainTypeButton.bind(CoinService.current.ethereum)
        }
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Address"), content: account.address, corners: (true, false)).subOneInterval())
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Fee"), content: "\(tx.decimalFee.thousandth(ThisAPP.FeeDecimal, autoTrim: false)) \(tx.feeToken)", detail: legalFee, corners: (false, true)))
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(SectionTitleCell.self){
            $0.titleLabel.text = self.tx.txType == .ethereumToFx ?  TR("CrossChain.ToFX") : TR("CrossChain.ToPAY")
            $0.chainTypeButton.bind(self.tx.toCoin ?? .empty)
        }
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Address"), content: tx.to, corners: (true, true)))
    }
    
    private var csFeeCell: ImageInfoCell?
    private var bridgeFeeCell: BridgeFeeCell?
    private func bindF2E() {
        
        let legalFee = legal(amount: tx.decimalFee, token: tx.feeToken)
        let hasBridgeFee = tx.csBridgeFee.isGreaterThan(decimal: "0")
        let amountText = "\(tx.amount.div10(tx.coin.decimal).thousandth(tx.coin.decimal)) \(tx.denom.displayCoinSymbol)"
        wk.view.navSubtitleLabel.text = amountText
        
        var fromChain = TR("CrossChain.FromFX")
        if tx.txType == .payToFx || tx.txType == .payToEthereum {
            fromChain = TR("CrossChain.FromPAY")
        }
        
        var toChain = TR("CrossChain.ToETH")
        if tx.txType == .payToFx || tx.txType == .ethereumToFx {
            toChain = TR("CrossChain.ToFX")
        } else if tx.txType == .fxToPay || tx.txType == .ethereumToPay {
            toChain = TR("CrossChain.ToPAY")
        }
            
        weak var welf = self
        listBinder.push(TitleCell.self)
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Amount"), content: amountText, corners: (true, true)))
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(SectionTitleCell.self){
            $0.titleLabel.text = fromChain
            $0.chainTypeButton.bind(self.tx.coin)
        }
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Address"), content: account.address, corners: (true, false)).subOneInterval())
        csFeeCell = listBinder.push(ImageInfoCell.self, vm: InfoCellViewModel(title: TR("Fee"), content: "\(tx.decimalFee.thousandth(ThisAPP.FeeDecimal, autoTrim: false)) \(tx.feeToken)", detail: legalFee, corners: (false, !hasBridgeFee)).adjust(offset: hasBridgeFee ? -24.auto() : 0))
        if hasBridgeFee {
            let height: CGFloat = (36 + (2 + 24) + 24 * 2).auto()
            bridgeFeeCell = listBinder.push(BridgeFeeCell.self, vm: InfoCellViewModel(title: TR("CrossChain.BridgeFee2"), content: "\(tx.csBridgeFee.div10(coin.decimal).thousandth(ThisAPP.FeeDecimal, autoTrim: false)) \(tx.csBridgeDenom.displayCoinSymbol)", corners: (false, true)).set(height: height))
            bridgeFeeCell?.tipButton.action { welf?.showBridgeFeeTip() }
        }
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(SectionTitleCell.self){
            $0.titleLabel.text = toChain
            $0.chainTypeButton.bind(self.tx.toCoin ?? .empty)
        }
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Address"), content: tx.to, corners: (true, true)))
        
        listBinder.didSeletedBlock = { (_,_,cell) in
            guard let this = welf else { return }
            if cell is ImageInfoCell || cell is BridgeFeeCell {
                
                welf?.tx.csEditFeeType = cell is BridgeFeeCell ? "2" : "1"
                Router.pushToSendTokenFeeOptions(tx: this.tx, account: this.account, contentHeight: this.contentHeight, completionHandler: { (e, result) in
                    if result.count > 0 { welf?.updateCsFeeText() }
                })
            }
        }
    }
    
    override func updateContentHeight() {
        
        wk.view.listView.isScrollEnabled = true
        wk.view.mainView.snp.updateConstraints { (make) in
            make.height.equalTo(self.maxContentHeight)
        }
    }
    
    private func updateCsFeeText() {
        
        if tx.csEditFeeType == "1" {
            csFeeCell?.contentLabel.attributedText = NSAttributedString(string: "\(tx.decimalFee.thousandth(ThisAPP.FeeDecimal, autoTrim: false)) \(tx.feeToken)", attributes: [.font: XWallet.Font(ofSize: 16, weight: .bold)])
        } else {
            bridgeFeeCell?.contentLabel.attributedText = NSAttributedString(string: "\(tx.csBridgeFee.div10(coin.decimal).thousandth(ThisAPP.FeeDecimal, autoTrim: false)) \(tx.csBridgeDenom.displayCoinSymbol)", attributes: [.font: XWallet.Font(ofSize: 16, weight: .bold)])
        }
    }
    
    private func showBridgeFeeTip() {
        bridgeFeeCell?.inactiveAWhile()
        
        let tipIV = bridgeFeeCell!.tipIV
        tipIV.alpha = 1
        wk.view.bridgeFeeTip.onHide = { tipIV.alpha = 0.5 }
        wk.view.bridgeFeeTip.show(in: self, at: bridgeFeeCell!.tipIV)
    } 
    
    private func legal(amount: String, token: String) -> String {
        let exchangeRate = token.exchangeRate().value.value
        if exchangeRate.isUnknown { return "" }
        
        return "$ \(exchangeRate.value.mul(amount).thousandth(ThisAPP.CurrencyDecimal, isLegal: true))"
    }
    
    override func layoutUI() {
        super.layoutUI()
        
        view.backgroundColor = .clear
        wk.view.backgroundButton.backgroundColor = .white        
    }
}

/// hero
extension SendTokenCrossChainCommitController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { 
        switch (from, to) {
        case ("SendTokenCrossChainCommitController", "BroadcastTxVerifyPasswordController"):  return animators["2"]
        case ("SendTokenFeeViewController", "SendTokenCrossChainCommitController"):  return animators["1"]
        case ("SendTokenCrossChainCommitController", "SendTokenFeeOptionsViewController"):  return animators["2"]
        case (_, "SendTokenCrossChainCommitController"):  return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        animators["0"] = self.heroAnimatorBackgound()
        animators["1"] = self.heroAnimatorBackgoundTo()
        animators["2"] = self.heroAnimatorBackgoundFrom()
    }
}
