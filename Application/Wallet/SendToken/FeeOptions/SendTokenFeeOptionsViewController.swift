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

class SendTokenFeeOptionsViewController: FxRegularPopViewController {
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
    private var completionHandler: ((WKError?, JSON) -> Void)?
    
    lazy var viewS = View(frame: ScreenBounds)
    override func getView() -> BaseView { viewS }
    
    override var interactivePopIsEnabled: Bool { false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindKeyboard()
    }
    
    var noticeCell = SendTokenFeeNoticeCell(style: .default, reuseIdentifier: "")
    override func bindListView() {
        if tx.isFxWithdraw {
            bindFxWithdraw()
        } else {
            bindTx()
        }
    }
    
    private func bindTx() {
        
        let contentCell = listBinder.push(ContentCell.self)
        let nextCell = listBinder.push(SendTokenFeeNextCell.self)
        
        nextCell.submitButton.action { [weak self] in
            guard let this = self else { return }
            
            this.tx.gasPrice = contentCell.gasPriceInputTF.text!.gwei
            this.tx.gasLimit = contentCell.gasLimitInputTF.text!
            this.tx.set(fee: this.tx.gasLimit.mul(this.tx.gasPrice), denom: this.tx.feeDenom)
            this.doConfirm()
        }
        
        wk.view.closeButton.action {[weak self] in
            Router.pop(self)
        }
        
        contentCell.tapButton.action{ [weak self] in self?.view.endEditing(true) }
        contentCell.gasLimitNoticeLabel.text = TR("SendToken.Fee.MinimalGasLimit$", tx.gasLimit)
        Observable.combineLatest(limit(contentCell.gasPriceInputTF, 6), limit(contentCell.gasLimitInputTF, 8))
            .subscribe(onNext: { [weak self] t in
                guard let this = self else { return }
                let (gasPrice, gasLimit) = t
                
                contentCell.gasLimitNoticeLabel.isHidden = this.tx.gasLimit.i <= gasLimit.i
                guard gasPrice.f > 0 && gasLimit.f > 0 else {
                    nextCell.submitButton.isEnabled = false
                    nextCell.submitButton.disabledTitle = TR("Next")
                    nextCell.submitButton.disabledTitleColor = HDA(0x999999)
                    return
                }
                
                let coin = this.tx.coin
                let fee = gasPrice.gwei.mul(gasLimit)
                let feeText = fee.div10(coin.feeDecimal).thousandth(4)
                let feeSymbol = this.tx.feeToken
                
                var spend = fee
                if coin.isETH { spend = this.tx.amount.add(fee) }
                
                let exchangeRate = feeSymbol.exchangeRate().value.value
                this.viewS.amountLabel.text = "\(feeText) \(feeSymbol)"
                if !exchangeRate.isUnknown {
                    this.viewS.legalAmountLabel.wk.set(amount: fee.div10(coin.feeDecimal).mul(exchangeRate.value), thousandth: ThisAPP.CurrencyDecimal)
                }

                let isInsufficient = spend.isGreaterThan(decimal: this.tx.balance)
                nextCell.submitButton.isEnabled = !isInsufficient
                if !isInsufficient {
                    nextCell.submitButton.disabledTitle = TR("SendToken.InsufficientBalance")
                    nextCell.submitButton.disabledTitleColor = HDA(0xFA6237)
                    this.listBinder.pop(this.noticeCell)
                } else {
                    
                    var total = TR("SendToken.Fee.Total$$$$", spend.div10(coin.decimal).thousandth(4), feeSymbol, feeText, feeSymbol)
                    let balance = TR("Balance") + ": \(this.tx.balance.div10(coin.decimal).thousandth(4)) \(feeSymbol)"
                    if this.coin.isERC20 {
                        total = TR("SendToken.Fee.Total$$", feeText, feeSymbol)
                    }
                    
                    this.noticeCell.totalLabel.text = "\(total)\n\(balance)"
                    this.noticeCell.balanceLabel.text = balance
                    if this.listBinder.index(of: this.noticeCell) == nil {
                        this.listBinder.push(this.noticeCell)
                        this.listBinder.refresh()
                    }
                }
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
    }
    
    private func bindFxWithdraw() {
        
        let contentCell = listBinder.push(ContentCell.self)
        let nextCell = listBinder.push(SendTokenFeeNextCell.self)
        
        nextCell.submitButton.title = TR("Done")
        nextCell.submitButton.action { [weak self] in
            guard let this = self else { return }
            
            this.tx.f2eETHGasPrice = contentCell.gasPriceInputTF.text!.gwei
            this.tx.f2eETHGasLimit = contentCell.gasLimitInputTF.text!
            Router.pop(to: "SendTokenCrossChainCommitController")
        }
        
        wk.view.closeButton.action {[weak self] in
            Router.pop(self)
        }
        
        contentCell.tapButton.action{ [weak self] in self?.view.endEditing(true) }
        contentCell.gasLimitNoticeLabel.text = TR("SendToken.Fee.MinimalGasLimit$", tx.f2eETHGasLimit)
        Observable.combineLatest(limit(contentCell.gasPriceInputTF, 6), limit(contentCell.gasLimitInputTF, 8))
            .subscribe(onNext: { [weak self] t in
                guard let this = self else { return }
                let (gasPrice, gasLimit) = t
                
                contentCell.gasLimitNoticeLabel.isHidden = this.tx.gasLimit.i <= gasLimit.i
                guard gasPrice.f > 0 && gasLimit.f > 0 else {
                    nextCell.submitButton.isEnabled = false
                    nextCell.submitButton.disabledTitle = TR("Done")
                    nextCell.submitButton.disabledTitleColor = HDA(0x999999)
                    return
                }
                
                let coin = CoinService.current.ethereum
                let fee = gasPrice.gwei.mul(gasLimit)
                let feeText = fee.div10(coin.feeDecimal).thousandth(4)
                let feeSymbol = coin.token
                
                let spend = fee
                let exchangeRate = feeSymbol.exchangeRate().value.value
                this.viewS.amountLabel.text = "\(feeText) \(feeSymbol)"
                if !exchangeRate.isUnknown {
                    this.viewS.legalAmountLabel.wk.set(amount: fee.div10(coin.feeDecimal).mul(exchangeRate.value), thousandth: ThisAPP.CurrencyDecimal)
                } else {
                    this.viewS.legalAmountLabel.text = "$ \(unknownAmount)"
                }

                let isInsufficient = spend.isGreaterThan(decimal: this.tx.f2eETHBalance)
                nextCell.submitButton.isEnabled = !isInsufficient
                if !isInsufficient {
                    nextCell.submitButton.disabledTitle = TR("SendToken.InsufficientBalance")
                    nextCell.submitButton.disabledTitleColor = HDA(0xFA6237)
                    this.listBinder.pop(this.noticeCell)
                } else {
                    
                    var total = TR("SendToken.Fee.Total$$$$", spend.div10(coin.decimal).thousandth(4), feeSymbol, feeText, feeSymbol)
                    let balance = TR("Balance") + ": \(this.tx.f2eETHBalance.div10(coin.decimal).thousandth(4)) \(feeSymbol)"
                    if this.coin.isERC20 {
                        total = TR("SendToken.Fee.Total$$", feeText, feeSymbol)
                    }
                    
                    this.noticeCell.totalLabel.text = "\(total)\n\(balance)"
                    this.noticeCell.balanceLabel.text = balance
                    if this.listBinder.index(of: this.noticeCell) == nil {
                        this.listBinder.push(this.noticeCell)
                        this.listBinder.refresh()
                    }
                }
                this.updateContentHeight()
            }).disposed(by: defaultBag)
        
        contentCell.gasLimitInputTF.reactiveText = tx.f2eETHGasLimit
        contentCell.gasPriceInputTF.reactiveText = tx.f2eETHGasPrice.div10(9, 2)
        
        contentCell.slowGPLabel.text = tx.f2eMutilGasPrice.slow.div10(9, 2)
        contentCell.slowTimeLabel.text = "~\(tx.f2eMutilGasPrice.slowTime) min"
        contentCell.fastGPLabel.text = tx.f2eMutilGasPrice.fast.div10(9, 2)
        contentCell.fastTimeLabel.text = "~\(tx.f2eMutilGasPrice.fastTime) min"
        contentCell.normalGPLabel.text = tx.f2eMutilGasPrice.normal.div10(9, 2)
        contentCell.normalTimeLabel.text = "~\(tx.f2eMutilGasPrice.normalTime) min"
    }
    
    private func doConfirm() {
        
        let isApproveTx = tx.isApprove
        Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: { [weak self](error, result) in

            if let handler = self?.completionHandler {
                handler(error, result)
            } else if WKError.canceled.isEqual(to: error) {
                
                if isApproveTx {
                    
                    if Router.canPop(to: "SendTokenCommitViewController") {
                        Router.pop(to: "SendTokenCommitViewController")
                    } else {
                        Router.popToRoot()
                    }
                } else if result.count == 0 {
                    Router.pop(to: "SendTokenInputViewController")
                } else if Router.canPop(to: "TokenInfoViewController") {
                    Router.pop(to: "TokenInfoViewController")
                } else {
                    Router.popToRoot()
                }
            }
        })
    }
    
    private func bindKeyboard() {
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] note in
                guard let this = self, this.presentedViewController == nil else { return }
                
                let endFrame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = endFrame.height - PopBottom
                this.wk.view.listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: margin), .clear)
                UIView.animate(withDuration: 0.2) {
                    this.wk.view.listView.contentOffset = CGPoint(x: 0, y: margin)
                }
            }).disposed(by: defaultBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: {[weak self] _ in
                self?.wk.view.listView.tableFooterView = nil
                UIView.animate(withDuration: 0.2) {
                    self?.wk.view.listView.contentOffset = .zero
                }
            }).disposed(by: defaultBag)
    }
    
    //MARK: Utils
    private func limit(_ input: UITextField, _ count: Int) -> Observable<String> {
        return input.rx.text.map{ v in
            
            var text = v ?? ""
            if text.count > count {
                text = text.substring(to: count - 1)
                input.text = text
            }
            return text
        }
    }
    
    override var contentHeight: CGFloat { listBinder.estimatedHeight + viewS.amountHeight + navBarHeight }
    override func update(navBarHeight: CGFloat) {}
    
    override func configuration() {
        wk.view.listView.isScrollEnabled = true
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
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        
        let onSuspendBlock:(WKHeroAnimator) ->Void = { a in
            welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
            welf?.wk.view.contentBGView.hero.modifiers = nil
            welf?.wk.view.backgroundIV.hero.modifiers = nil
        }
        
        animators["0"] = WKHeroAnimator({ (a) in
            welf?.setBackgoundOverlayViewImage()
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            
            welf?.wk.view.contentBGView.hero.id = "backgroundView"
            welf?.wk.view.contentBGView.hero.modifiers = [.masksToBounds(true)]
            welf?.wk.view.contentView.hero.modifiers = [.fade, .useOptimizedSnapshot, .translate(x: ScreenWidth)]
        }, onSuspend: onSuspendBlock)
        
        animators["1"] = WKHeroAnimator({ (a) in
            welf?.wk.view.contentBGView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:1000)]
            welf?.wk.view.contentView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y:1000)]
        }, onSuspend: onSuspendBlock)
        
        animators["2"] = WKHeroAnimator({ (a) in
            welf?.wk.view.contentBGView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:1000)]
            welf?.wk.view.contentView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y:1000)]
        }, onSuspend: onSuspendBlock)
    }
    
    func heroWillStartAnimating(transition: HeroTransition) { 
        if let contentBGView = transition.context?.snapshotView(for: wk.view.contentBGView),
           let contentView = transition.context?.snapshotView(for: wk.view.contentView) {
            contentView.frame = CGRect(origin: CGPoint.zero, size: contentView.size)
            contentBGView.layer.masksToBounds = true
            contentBGView.addSubview(contentView) 
        } 
    }
}
