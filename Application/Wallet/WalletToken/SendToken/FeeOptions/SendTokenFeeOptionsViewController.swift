//
//  SendTokenFeeOptionsViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/10/9.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON

extension SendTokenFeeOptionsViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction,
            let account = context["account"] as? Keypair else { return nil }
        let contentHeight = context["contentHeight"] as? CGFloat ?? 0
        let vc = SendTokenFeeOptionsViewController(tx: tx, account: account, contentHeight: contentHeight)
        vc.completionHandler = context["handler"] as? (WKError?, JSON) -> Void
        return vc
    }
}

class SendTokenFeeOptionsViewController: FxActionPopViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction, account: Keypair, contentHeight:CGFloat) {
        self.tx = tx
        self.account = account
        self.superContentHeight = contentHeight
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    let tx: FxTransaction
    var coin: Coin { tx.coin }
    let account: Keypair
    var superContentHeight: CGFloat = 0
    private var regularContentHeight: CGFloat = 0
    private var completionHandler: ((WKError?, JSON) -> Void)?
    
    lazy var viewS = View(frame: ScreenBounds)
    override func getView() -> BaseView { viewS }
    
    override var contentHeight: CGFloat { listBinder.estimatedHeight + navBarHeight + viewS.actionsHeight }
    override func update(navBarHeight: CGFloat) {}
    
    override var interactivePopIsEnabled: Bool { false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindKeyboard()
    }
    
    override func bindListView() {
        if tx.csEditFeeType == "1" {
            bindEditCSFee()
        } else if tx.csEditFeeType == "2" {
            bindEditCSBridgeFee()
        } else {
            bindTx()
        }
    }
    
    private func bindTx() {
        
        let amountCell = listBinder.push(AmountCell.self)
        let contentCell = listBinder.push(ContentCell.self)
        contentCell.tapButton.action{ [weak self] in self?.view.endEditing(true) }
        contentCell.gasLimitNoticeLabel.text = TR("SendToken.Fee.MinimalGasLimit$", tx.gasLimit)
        Observable.combineLatest(limit(contentCell.gasPriceInputTF, 6), limit(contentCell.gasLimitInputTF, 8))
            .subscribe(onNext: { [weak self] t in
                guard let this = self else { return }
                let (gasPrice, gasLimit) = t
                
                let isValidGas = this.tx.gasLimit.i <= gasLimit.i
                contentCell.gasLimitNoticeLabel.isHidden = isValidGas
                contentCell.gasLimitInputView.isError = !isValidGas
                guard isValidGas, gasPrice.f > 0 && gasLimit.f > 0 else {
                    
                    this.viewS.submitButton.isEnabled = false
                    this.viewS.submitButton.disabledTitle = TR("Next")
                    this.viewS.submitButton.disabledTitleColor = HDA(0x999999)
                    if !isValidGas {
                        this.viewS.hideNotice(true)
                        this.updateContentHeight()
                    }
                    return
                }
                
                let coin = this.tx.coin
                let fee = gasPrice.gwei.mul(gasLimit)
                let feeDecimal = ThisAPP.FeeDecimal
                let feeText = fee.div10(coin.feeDecimal).thousandth(feeDecimal, autoTrim: false)
                let feeSymbol = this.tx.feeToken
                
                var spend = fee
                if coin.isETH { spend = this.tx.amount.add(fee) }
                
                let exchangeRate = feeSymbol.exchangeRate().value.value
                amountCell.amountLabel.text = "\(feeText) \(feeSymbol)"
                if !exchangeRate.isUnknown {
                    amountCell.legalAmountLabel.wk.set(amount: fee.div10(coin.feeDecimal).mul(exchangeRate.value), thousandth: ThisAPP.CurrencyDecimal, isLegal: true)
                } else {
                    amountCell.legalAmountLabel.text = "$ \(unknownAmount)"
                }

                let isInsufficient = spend.isGreaterThan(decimal: this.tx.balance)
                if isInsufficient {
                    var total = TR("SendToken.Fee.Total$$$$", spend.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false), feeSymbol, feeText, feeSymbol)
                    let balance = TR("Balance") + ": \(this.tx.balance.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false)) \(feeSymbol)"
                    if this.coin.isERC20 {
                        total = TR("SendToken.Fee.Total$$", feeText, feeSymbol)
                    }
                    
                    this.viewS.submitButton.disabledTitle = TR("SendToken.InsufficientBalance")
                    this.viewS.submitButton.disabledTitleColor = HDA(0xFA6237)
                    this.viewS.totalLabel.text = "\(total)\n\(balance)"
                    this.viewS.balanceLabel.text = balance
                }
                this.viewS.submitButton.isEnabled = !isInsufficient
                this.viewS.hideNotice(!isInsufficient)
                this.updateContentHeight()
            }).disposed(by: defaultBag)
        
        contentCell.gasLimitInputTF.reactiveText = tx.gasLimit
        contentCell.gasPriceInputTF.reactiveText = tx.gasPrice.div10(9, 2)
        
        contentCell.slowGPLabel.text = tx.slowGasPrice.div10(9, 2)
        contentCell.slowTimeLabel.text = "~\(tx.slowGasPriceTime) min"
        contentCell.fastGPLabel.text = tx.fastGasPrice.div10(9, 2)
        contentCell.fastTimeLabel.text = "~\(tx.fastGasPriceTime) min"
        contentCell.normalGPLabel.text = tx.normalGasPrice.div10(9, 2)
        contentCell.normalTimeLabel.text = "~\(tx.normalGasPriceTime) min"
        
        viewS.submitButton.action { [weak self] in
            guard let this = self else { return }
            
            this.tx.gasPrice = contentCell.gasPriceInputTF.text!.gwei
            this.tx.gasLimit = contentCell.gasLimitInputTF.text!
            this.tx.set(fee: this.tx.gasLimit.mul(this.tx.gasPrice), denom: this.tx.feeDenom)
            this.doConfirm()
        }
        
        wk.view.closeButton.action {[weak self] in
            Router.pop(self)
        }
    }
    
    private func bindEditCSFee() {
        
        weak var welf = self
        let amountCell = listBinder.push(AmountCell.self)
        let contentCell = listBinder.push(ContentCell.self)
        contentCell.tapButton.action{ [weak self] in self?.view.endEditing(true) }
        contentCell.gasLimitNoticeLabel.text = TR("SendToken.Fee.MinimalGasLimit$", tx.gasLimit)
        contentCell.gasPriceInputView.isUserInteractionEnabled = false
        Observable.combineLatest(limit(contentCell.gasPriceInputTF, 12, false), limit(contentCell.gasLimitInputTF, 8))
            .subscribe(onNext: { [weak self] t in
                guard let this = self else { return }
                let (gasPrice, gasLimit) = t
                
                let tx = this.tx
                let isValidGas = tx.gasLimit.i <= gasLimit.i
                contentCell.gasLimitNoticeLabel.isHidden = isValidGas
                contentCell.gasLimitInputView.isError = !isValidGas
                guard isValidGas, gasPrice.f > 0 && gasLimit.f > 0 else {
                    
                    this.viewS.submitButton.isEnabled = false
                    this.viewS.submitButton.disabledTitle = TR("Save")
                    this.viewS.submitButton.disabledTitleColor = HDA(0x999999)
                    if !isValidGas {
                        this.viewS.hideNotice(true)
                        this.updateContentHeight()
                    }
                    return
                }
                
                let coin = tx.feeCoin
                var fee = gasPrice.wei.mul(gasLimit)
                let txFee = gasPrice.wei.mul(gasLimit)
                let feeDecimal = ThisAPP.FeeDecimal
                let feeSymbol = tx.feeToken
                
                var spend = fee
                if tx.feeCoin.id == tx.coin.id {
                    spend = tx.amount.add(fee)
                }
                
                if tx.feeCoin.id == tx.csBridgeFeeCoin.id {
                    fee = fee.add(tx.csBridgeFee)
                    spend = spend.add(tx.csBridgeFee)
                }

                let exchangeRate = feeSymbol.exchangeRate().value.value
                amountCell.amountLabel.text = "\(txFee.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false)) \(feeSymbol)"
                if !exchangeRate.isUnknown {
                    amountCell.legalAmountLabel.wk.set(amount: txFee.div10(coin.decimal).mul(exchangeRate.value), thousandth: ThisAPP.CurrencyDecimal, isLegal: true)
                } else {
                    amountCell.legalAmountLabel.text = "$ \(unknownAmount)"
                }

                let isInsufficient = spend.isGreaterThan(decimal: this.tx.balance)
                if isInsufficient {
                    let feeText = fee.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false)
                    var total = TR("SendToken.Fee.Total$$$$", spend.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false), feeSymbol, feeText, feeSymbol)
                    let balance = TR("Balance") + ": \(this.tx.balance.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false)) \(feeSymbol)"
//                    if this.coin.isERC20 {
//                        total = TR("SendToken.Fee.Total$$", feeText, feeSymbol)
//                    }
                    
                    this.viewS.submitButton.disabledTitle = TR("SendToken.InsufficientBalance")
                    this.viewS.submitButton.disabledTitleColor = HDA(0xFA6237)
                    this.viewS.totalLabel.text = "\(total)\n\(balance)"
                    this.viewS.balanceLabel.text = balance
                }
                this.viewS.submitButton.isEnabled = !isInsufficient
                this.viewS.hideNotice(!isInsufficient)
                this.updateContentHeight()
            }).disposed(by: defaultBag)
        
        contentCell.gasLimitInputTF.reactiveText = tx.gasLimit
        contentCell.gasPriceInputTF.reactiveText = tx.gasPrice.div10(18)
        
        let symbol = tx.feeCoin.symbol.displayCoinSymbol
        contentCell.slowGPLabel.text = "~"
        contentCell.slowTimeLabel.text = "~ min"
        contentCell.fastGPLabel.text = "~"
        contentCell.fastTimeLabel.text = "~ min"
        contentCell.normalGPLabel.text = "~"
        contentCell.normalTimeLabel.text = "~ min"
        contentCell.gasPriceSymbolLabel.text = symbol
        contentCell.slowGPSymbolLabel.text = symbol
        contentCell.normalGPSymbolLabel.text = symbol
        contentCell.fastGPSymbolLabel.text = symbol
        
        viewS.submitButton.title = TR("Save")
        viewS.submitButton.action {
            guard let this = welf else { return }
            
            this.tx.gasPrice = contentCell.gasPriceInputTF.text!.wei
            this.tx.gasLimit = contentCell.gasLimitInputTF.text!
            this.tx.set(fee: this.tx.gasLimit.mul(this.tx.gasPrice), denom: this.tx.feeDenom)
            this.completionHandler?(nil, ["success": 1])
            Router.pop(self)
        }
        
        wk.view.closeButton.action { Router.pop(welf) }
    }
    
    private func bindEditCSBridgeFee() {
        
        weak var welf = self
        let minBridgeFee = tx.csMutilGasPrice.slow.div10(tx.csBridgeFeeCoin.decimal)
        
        let amountCell = listBinder.push(AmountCell.self)
        let contentCell = listBinder.push(ContentCell.self, vm: FxTableViewCellViewModel())
        contentCell.relayoutForBridgeFee(tx.csBridgeDenom.displayCoinSymbol)
        contentCell.tapButton.action{ [weak self] in self?.view.endEditing(true) }
        contentCell.csBridgeNoticeLabel.text = TR("SendToken.Fee.MinimalBridgeFee$", minBridgeFee)
        
        limit(contentCell.csBridgeInputTF, 8, false).subscribe(onNext: { [weak self] bridgeFee in
            guard let this = self else { return }
            
            let tx = this.tx
            let isValidGas = minBridgeFee.f <= bridgeFee.f
            contentCell.gasLimitNoticeLabel.isHidden = isValidGas
            contentCell.csBridgeInputView.isError = !isValidGas
            guard isValidGas, bridgeFee.f > 0 else {
                
                this.viewS.submitButton.isEnabled = false
                this.viewS.submitButton.disabledTitle = TR("Save")
                this.viewS.submitButton.disabledTitleColor = HDA(0x999999)
                if !isValidGas {
                    this.viewS.hideNotice(true)
                    this.updateContentHeight()
                }
                return
            }
            
            let coin = this.tx.csBridgeFeeCoin
            let feeDecimal = ThisAPP.FeeDecimal
            let feeSymbol = tx.csBridgeDenom
            
            var fee = bridgeFee.mul10(coin.decimal)
            var spend = fee
            var feeBalance = tx.csBridgeBalance
            
            if tx.feeCoin.id == tx.csBridgeFeeCoin.id {
                fee = fee.add(tx.fee)
                spend = fee
            }
            
            if this.tx.coin.id == this.tx.csBridgeFeeCoin.id {
                spend = tx.amount.add(fee)
                feeBalance = tx.balance
            }
            
            let exchangeRate = feeSymbol.exchangeRate().value.value
            amountCell.amountLabel.text = "\(bridgeFee.thousandth(feeDecimal, autoTrim: false)) \(feeSymbol)"
            if !exchangeRate.isUnknown {
                amountCell.legalAmountLabel.wk.set(amount: fee.div10(coin.decimal).mul(exchangeRate.value), thousandth: ThisAPP.CurrencyDecimal, isLegal: true)
            } else {
                amountCell.legalAmountLabel.text = "$ \(unknownAmount)"
            }
            
            let isInsufficient = spend.isGreaterThan(decimal: feeBalance)
            if isInsufficient {
                let feeText = fee.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false)
                var total = TR("SendToken.Fee.Total$$$$", spend.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false), feeSymbol, feeText, feeSymbol)
                let balance = TR("Balance") + ": \(feeBalance.div10(coin.decimal).thousandth(feeDecimal, autoTrim: false)) \(feeSymbol)"
//                if this.coin.isERC20 {
//                    total = TR("SendToken.Fee.Total$$", feeText, feeSymbol)
//                }
                
                this.viewS.submitButton.disabledTitle = TR("SendToken.InsufficientBalance")
                this.viewS.submitButton.disabledTitleColor = HDA(0xFA6237)
                this.viewS.totalLabel.text = "\(total)\n\(balance)"
                this.viewS.balanceLabel.text = balance
            }
            this.viewS.submitButton.isEnabled = !isInsufficient
            this.viewS.hideNotice(!isInsufficient)
            this.updateContentHeight()
        }).disposed(by: defaultBag)
        
        contentCell.csBridgeInputTF.reactiveText = tx.csBridgeFee.div10(tx.csBridgeFeeCoin.decimal)
        
        contentCell.slowGPLabel.text = tx.csMutilGasPrice.slow.div10(tx.csBridgeFeeCoin.decimal, 2)
        contentCell.slowTimeLabel.text = "~ min"
        contentCell.fastGPLabel.text = tx.csMutilGasPrice.fast.div10(tx.csBridgeFeeCoin.decimal, 2)
        contentCell.fastTimeLabel.text = "~ min"
        contentCell.normalGPLabel.text = tx.csMutilGasPrice.normal.div10(tx.csBridgeFeeCoin.decimal, 2)
        contentCell.normalTimeLabel.text = "~ min"
        
        viewS.submitButton.title = TR("Save")
        viewS.submitButton.action {
            guard let this = welf else { return }
            
            this.tx.csBridgeFee = contentCell.csBridgeInputTF.text!.mul10(this.tx.csBridgeFeeCoin.decimal)
            this.completionHandler?(nil, ["success": 1])
            Router.pop(self)
        }
        
        wk.view.closeButton.action { Router.pop(welf) }
    }
    
    private func doConfirm() {
        
        if tx.isCrossChain {
            Router.pushToSendTokenCrossChainCommit(tx: tx, account: account)
            return
        }
        
        if let handler = completionHandler {
            Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: handler)
        } else {
            
            Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: { (error, result) in

                if WKError.canceled.isEqual(to: error) {
                    
                    if result.count == 0 {
                        Router.pop(to: "SendTokenInputViewController", elseToPreviousOrRoot: false)
                    } else if Router.canPop(to: "TokenInfoViewController") {
                        Router.pop(to: "TokenInfoViewController")
                    } else {
                        Router.popToRoot()
                    }
                }
            })
        }
    }
    
    private func bindKeyboard() {
        
        self.regularContentHeight = self.contentHeight
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] note in
                guard let this = self, this.presentedViewController == nil else { return }
                
                let duration = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                let endFrame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = UIScreen.main.bounds.height - endFrame.origin.y
                
                let height = ScreenHeight - endFrame.height - StatusBarHeight - 24.auto()
                this.viewS.mainView.snp.updateConstraints( { (make) in
                    make.bottom.equalTo(this.view).offset(-margin-24.auto())
                    if height < this.regularContentHeight {
                        make.height.equalTo(height)
                    }
                })
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
                
            }).disposed(by: defaultBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: {[weak self] _ in
                guard let this = self else { return }
                self?.viewS.mainView.snp.updateConstraints( { (make) in
                    make.bottom.equalTo(-PopBottom)
                    make.height.equalTo(this.regularContentHeight)
                })
                UIView.animate(withDuration: 0.2) {
                    self?.view.layoutIfNeeded()
                }
            }).disposed(by: defaultBag)
    }
    
    //MARK: Utils
    private func limit(_ input: UITextField, _ count: Int, _ integer: Bool = true) -> Observable<String> {
        return input.rx.text.map{ v in
            
            var text = v ?? ""
            if integer, text.hasSuffix(".") {
                text = text.replacingOccurrences(of: ".", with: "")
                input.text = text
            }
            if text.count > count {
                text = text.substring(to: count - 1)
                input.text = text
            }
            return text
        }
    }
    
    override func layoutUI() {
        super.layoutUI()
        
        view.backgroundColor = .clear
        wk.view.backgroundButton.backgroundColor = .white
     
        wk.view.navBar.relayoutForPopTitle()
        wk.view.navBar.backButton.image = IMG("ic_back_white")
        wk.view.navBar.backButton.title = TR("SendToken.Fee.Options")
    }
}

/// hero
extension SendTokenFeeOptionsViewController : HeroViewControllerDelegate {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { 
        switch (from, to) {
        case ("SendTokenFeeViewController",  "SendTokenFeeOptionsViewController"):  return animators["0"]
        case ("SendTokenFeeOptionsViewController", "BroadcastTxAlertController"):  return animators["1"]
        case ("SendTokenFeeOptionsViewController", "BroadcastTxInfoController"):  return animators["1"]
        case ("SendTokenFeeOptionsViewController", "SendTokenCrossChainCommitController"):  return animators["1"]
        case ("SendTokenCrossChainCommitController", "SendTokenFeeOptionsViewController"): return animators["3"]
        case (_, "SendTokenFeeOptionsViewController"): return animators["2"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        
        let onSuspendBlock:(WKHeroAnimator) ->Void = { a in
            welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
            welf?.wk.view.mainView.hero.modifiers = nil
            welf?.wk.view.mainView.macawView.hero.modifiers = nil 
        }
        
        animators["0"] = WKHeroAnimator({ (a) in
            welf?.setBackgoundOverlayViewImage()
            welf?.wk.view.mainView.macawView.hero.id = "backgroundView"
            welf?.wk.view.mainView.macawView.hero.modifiers = [.masksToBounds(true), .resizableCap(UIEdgeInsets(top: 36.auto(), left: 36.auto(), bottom: 36.auto(), right: 36.auto()),
                                                                                         .stretch), .useGlobalCoordinateSpace, .useOptimizedSnapshot, .spring]
            welf?.wk.view.contentView.hero.modifiers = [.fade, .useOptimizedSnapshot, .translate(x: ScreenWidth), .spring]
        }, onSuspend: onSuspendBlock)
        
        animators["1"] = WKHeroAnimator({ (a) in
            let mainView = welf?.wk.view.mainView
            let offsetY = ScreenHeight - mainView!.mj_y + 100 + ScreenHeight 
            welf?.wk.view.mainView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:offsetY)]
        }, onSuspend: onSuspendBlock)
        
        animators["2"] = WKHeroAnimator({ (a) in
            welf?.wk.view.mainView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:1000)]
        }, onSuspend: onSuspendBlock)
        
        animators["3"] = self.heroAnimatorBackgoundTo()
    }
    
    func heroWillStartAnimating(transition: HeroTransition) { 
        if let contentBGView = transition.context?.snapshotView(for: wk.view.mainView.macawView),
           let contentView = transition.context?.snapshotView(for: wk.view.contentView) {
            contentView.frame = CGRect(origin: CGPoint.zero, size: contentView.size)
            contentBGView.layer.masksToBounds = true
            contentBGView.addSubview(contentView) 
        } 
    }
}
