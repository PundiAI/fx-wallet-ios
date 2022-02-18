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
              let validator = context["validator"] as? Validator,
              let account = context["account"] as? Keypair else { return nil }
        
        return FxDelegateViewController(wallet: wallet, coin: coin, validator: validator, account: account)
    }
}

class FxDelegateViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, validator: Validator, account: Keypair) {
        self.coin = coin
        self.wallet = wallet
        self.validator = validator
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }

    let coin: Coin
    let wallet: WKWallet
    let validator: Validator
    private let account: Keypair
        
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
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
        
        listBinder.push(inputCell, vm: inputCell)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 32.auto()))
        listBinder.push(confirmCell)
        
        inputCell.statusButton.isActive = validator.isActive
        inputCell.validatorIV.setImage(urlString: validator.imageURL, placeHolderImage: IMG("Dapp.Placeholder"))
        inputCell.validatorNameLabel.text = validator.validatorName
        inputCell.validatorAddressLabel.text = validator.validatorAddress
    }
    
    private func bindInput() {
        
        weak var welf = self
        inputCell.inputTokenLabel.text = coin.token
        inputCell.inputVIew.decimalLimit = coin.decimal
        inputCell.percentButtons.forEach{ $0.bind(welf, action: #selector(onClick), forControlEvents: .touchUpInside) }
        
        inputCell.inputTF.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { v in
                guard let this = welf else { return }
                welf?.inputCell.percentButtons.forEach{ $0.isSelected = false }
            
                let text = this.inputCell.inputVIew.decimalText
                if text.isGreaterThan(decimal: this.decimalBalance) {
                    DispatchQueue.main.async {
                        welf?.onClick(this.inputCell.maxButton)
                    }
                }
                welf?.confirmCell.enable(text.f > 0)
        }).disposed(by: defaultBag)
    }
    
    private func bindAccount() {
        
        decimalBalance = ""
        balanceBag = DisposeBag()
        inputCell.percentEnable(false)

        let balance = wallet.balance(of: account.address, coin: coin)
        balance.value.subscribe(onNext: { [weak self] value in
            guard let this = self, !value.isUnknownAmount else { return }

            self?.balance = value
            self?.decimalBalance = value.div10(this.coin.decimal)
            self?.inputCell.maximumLabel.text = value.div10(this.coin.decimal).thousandth() + " \(this.coin.token)"
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
 
        let checkBox = confirmCell.checkBox
        confirmCell.tipButton.action {
            Router.showAgreementAlert(doneHandler: { ( state ) in
                checkBox.isSelected = state
                return true
            }, state: checkBox.isSelected)
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
                welf?.hud?.text(m: TR("Alert.Tip$", tx.feeDenom))
                return
            }
            
            Router.showBroadcastTxAlert(tx: tx, privateKey: this.account.privateKey) { (error, result) in
                
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
        tx.delegator = account.address
        tx.balance = self.balance
        tx.txType = .delegate
        tx.coin = coin
        
        let wallet = FxWallet(privateKey: account.privateKey)
        let hub = FxHubNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: wallet)
        return hub.buildDelegateTx(toValidator: tx.validator, amount: amount.sub("10"), fee: "1", denom: coin.symbol, gas: 0).flatMap{ txMsg in
            
            return hub.estimatedFee(ofTx: txMsg).map { [weak self](gas: UInt64, gasPrice: String, fee: String) -> FxTransaction in
                guard let this = self else { return tx }

                tx.gasLimit = String(gas)
                tx.gasPrice = gasPrice
                tx.set(fee: fee, denom: this.coin.symbol)
                tx.adjustMaxAmountIfNeed()
                return tx
            }
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
