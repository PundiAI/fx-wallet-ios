//
//  FxDelegateViewController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/26.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Web3
import WKKit
import XChains
import RxSwift
import RxCocoa
import FunctionX
import SwiftyJSON

extension WKWrapper where Base == FxDelegateViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension FxDelegateViewController {

    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let coin = context["coin"] as? Coin,
              let validator = context["validator"] as? Validator else { return nil }
        
        let account = context["account"] as? Keypair
        return FxDelegateViewController(wallet: wallet, coin: coin, validator: validator, account: account)
    }
}

class FxDelegateViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, validator: Validator, account: Keypair?) {
        self.coin = coin
        self.wallet = wallet
        self.validator = validator
        self.account = BehaviorRelay(value: account ?? .empty)
        super.init(nibName: nil, bundle: nil)
    }

    let coin: Coin
    let wallet: WKWallet
    let validator: Validator
    private let account: BehaviorRelay<Keypair>
        
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private var validatorCell = FxValidatorTitleCell()
    private var inputCell = FxDelegateTxInputCell()
    private var confirmCell = FxDelegateConfirmTxCell()
    
    private var balance = ""
    private var decimalBalance = ""
    private var balanceBag: DisposeBag!
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindListView()
        
        bindInput()
        bindAccount()
        bindConfirm()
        bindKeyboard()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("BroadcastTx.Delegate"))
    }
    
    private func bindListView() {
        
        if !account.value.isEmpty { inputCell.relayoutForUnchangeableAddress() }
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 8.auto()))
        listBinder.push(validatorCell)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(inputCell, vm: inputCell)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 32.auto()))
        listBinder.push(confirmCell)
        
        validatorCell.validatorIV.setImage(urlString: validator.imageURL, placeHolderImage: IMG("Dapp.Placeholder"))
        validatorCell.validatorNameLabel.text = validator.validatorName
        validatorCell.validatorAddressLabel.text = validator.validatorAddress
    }
    
    private func bindInput() {
        
        weak var welf = self
        inputCell.inputTokenLabel.text = coin.token
        inputCell.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
        inputCell.inputVIew.decimalLimit = coin.decimal
        inputCell.percentButtons.forEach{ $0.bind(welf, action: #selector(onClick), forControlEvents: .touchUpInside) }
        
        inputCell.inputTF.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { v in
                guard let this = welf else { return }
            
                let text = this.inputCell.inputVIew.decimalText
                if text.isGreaterThan(decimal: this.decimalBalance) {
                    welf?.inputCell.inputTF.text = this.decimalBalance
                }
                welf?.inputCell.percentButtons.forEach{ $0.isSelected = false }
                welf?.confirmCell.enable(text.f > 0)
        }).disposed(by: defaultBag)
    }
    
    private func bindAccount() {
        
        weak var welf = self
        inputCell.addressActionButton.rx.tap.subscribe(onNext: { value in
            guard let this = welf else { return }
            
            Router.showSelectAccount(wallet: this.wallet, current: nil, filterCoin: this.coin) { (vc, _, account) in
                Router.dismiss(vc, animated: true) {
                    welf?.account.accept(account)
                }
            }
        }).disposed(by: defaultBag)
        
        account.filter{ !$0.isEmpty }
            .subscribe(onNext: { value in
                
                welf?.inputCell.inputTF.reactiveText = ""
                welf?.inputCell.addressLabel.text = value.address
                if welf?.inputCell.addressPlaceHolderLabel.isHidden == false {
                    
                    welf?.inputCell.relayout(hasAddress: true)
                    welf?.listBinder.refresh()
                }
                
                welf?.updateBalance(value)
        }).disposed(by: defaultBag)
    }
    
    private func updateBalance(_ account: Keypair) {
        
        decimalBalance = ""
        balanceBag = DisposeBag()
        inputCell.percentEnable(false)

        let balance = wallet.balance(of: account.address, coin: coin)
        balance.value.subscribe(onNext: { [weak self] value in
            guard let this = self, !value.isUnknownAmount else { return }

            self?.balance = value
            self?.decimalBalance = value.div10(this.coin.decimal)
            self?.inputCell.balanceLabel.text = value.div10(this.coin.decimal).thousandth() + " \(this.coin.token)"
            self?.inputCell.percentEnable(value.isGreaterThan(decimal: "0"))
        }).disposed(by: balanceBag)
    }
    
    @objc private func onClick(_ percent: UIButton) {
        
        if percent == inputCell.p25Button {
            inputCell.inputTF.reactiveText = decimalBalance.mul("0.25")
        } else if percent == inputCell.p50Button {
            inputCell.inputTF.reactiveText = decimalBalance.mul("0.5")
        } else if percent == inputCell.p75Button {
            inputCell.inputTF.reactiveText = decimalBalance.mul("0.75")
        } else {
            inputCell.inputTF.reactiveText = decimalBalance
        }
        percent.isSelected = true
    }
    
    private func bindConfirm() {
        
        weak var welf = self
        confirmCell.checkBox.action { welf?.confirmCell.checkBox.isSelected = !(welf?.confirmCell.checkBox.isSelected ?? true) }
        confirmCell.tipButton.isEnabled = false
        confirmCell.tipButton.action {
            Router.showWebViewController(url: ThisAPP.WebURL.termServiceURL)
        }
        confirmCell.submitButton.bind(self, action: #selector(doConfirm), forControlEvents: .touchUpInside)
    }
    
    @objc private func doConfirm(_ sender: UIButton) {
        
        weak var welf = self
        sender.inactiveAWhile(1)
        self.view.endEditing(true)
        guard confirmCell.checkBox.isSelected else {
            self.hud?.text(m: TR("AgreeToTermsNotice"))
            return
        }
        
        self.hud?.waiting()
        buildTx().subscribe(onNext: { tx in
            welf?.hud?.hide()
            guard let this = welf else { return }
            
            if !tx.balance.isGreaterThan(decimal: tx.fee) {
                welf?.hud?.text(m: "no enough \(tx.feeDenom) to pay fee")
                return
            }
            
            Router.showBroadcastTxAlert(tx: tx, privateKey: this.account.value.privateKey) { (error, result) in
                
                if WKError.canceled.isEqual(to: error) {
                    if Router.canPop(to: "FxMyDelegatesViewController") {
                        Router.pop(to: "FxMyDelegatesViewController")
                    } else {
                        Router.pop(to: "FxValidatorOverviewViewController")
                    }
                }
            }
        }, onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }).disposed(by: defaultBag)
    }
    
    private func buildTx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let amount = inputCell.inputVIew.decimalText.mul10(coin.decimal)
        tx.set(amount: amount, denom: coin.symbol)
        tx.validator = validator.validatorAddress
        tx.delegator = account.value.address
        tx.balance = self.balance
        tx.txType = .delegate
        tx.coin = coin
        
        let hub = FxHubNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: nil)
        let txMsg = TransactionMessage.delegateTx(delegator: tx.delegator, validator: tx.validator, amount: amount, fee: "0", denom: coin.symbol, gas: 90000)
        return hub.estimatedFee(ofTx: txMsg).map { [weak self](gas: UInt64, gasPrice: String, fee: String) -> FxTransaction in
            guard let this = self else { return tx }
            
            tx.gasLimit = String(gas)
            tx.gasPrice = gasPrice
            tx.set(fee: fee, denom: this.coin.symbol)
            tx.adjustMaxAmountIfNeed()
            return tx
        }
    }
    
    var beginEdit = false
    private func bindKeyboard() {
        
        listBinder.scrollViewDidScroll = {[weak self] _ in
            if self?.beginEdit == false { self?.view.endEditing(true) }
        }
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] note in
                guard let this = self, this.presentedViewController == nil else { return }
                
                let endFrame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let compareFrame = this.confirmCell.checkBox.convert(this.confirmCell.checkBox.frame, to: this.view)
                if compareFrame.maxY > endFrame.minY {
                    
                    let margin = compareFrame.maxY - endFrame.minY
                    this.wk.view.listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: margin), .clear)
                    this.beginEdit = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        this.beginEdit = false
                    }
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
}
