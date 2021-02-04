//
//  FxRewardsViewController.swift
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
import SwiftyJSON
import FunctionX

extension WKWrapper where Base == FxRewardsViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension FxRewardsViewController {

    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin,
              let wallet = context["wallet"] as? WKWallet,
              let account = context["account"] as? Keypair,
              let validator = context["validator"] as? Validator else { return nil }

        return FxRewardsViewController(wallet: wallet, coin: coin, validator: validator, account: account)
    }
}

class FxRewardsViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, validator: Validator, account: Keypair) {
        self.coin = coin
        self.wallet = wallet
        self.account = account
        self.validator = validator
        super.init(nibName: nil, bundle: nil)
    }

    let coin: Coin
    let wallet: WKWallet
    let account: Keypair
    let validator: Validator
        
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private var validatorCell = FxValidatorTitleCell()
    private var inputCell = FxDelegateTxInputCell()
    private var confirmCell = FxDelegateConfirmTxCell()
    
    private var rewardAmount = ""
    private lazy var balance = wallet.balance(of: account.address, coin: coin)
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindListView()
        bindInput()
        bindConfirm()
        
        fetchData()
    }
    
    private func fetchData() {
        
        fetchReward()
        balance.refreshIfNeed()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("FXDelegator.Rewards"))
    }
    
    private func bindListView() {
        
        inputCell.type = .rewards
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
        inputCell.addressLabel.text = account.address
        inputCell.inputTokenLabel.text = coin.token
        inputCell.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
        inputCell.inputVIew.decimalLimit = coin.decimal
        
        inputCell.balanceLabel.text = validator.delegateAmount.div10(coin.decimal).thousandth() + " \(coin.token)"
        
        inputCell.inputTF.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { v in
                guard let this = welf else { return }
            
                let text = this.inputCell.inputVIew.decimalText
                welf?.confirmCell.enable(text.f > 0)
        }).disposed(by: defaultBag)
    }
    
    private func bindConfirm() {
        
        weak var welf = self
        confirmCell.checkBox.action { welf?.confirmCell.checkBox.isSelected = !(welf?.confirmCell.checkBox.isSelected ?? true) }
        confirmCell.tipButton.isEnabled = false
        confirmCell.tipButton.action {
            Router.showWebViewController(url: ThisAPP.WebURL.termServiceURL)
        }
        confirmCell.submitButton.bind(self, action: #selector(doConfirm), forControlEvents: .touchUpInside)
        listBinder.refresh()
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
        tx.set(amount: rewardAmount, denom: coin.symbol)
        tx.validator = validator.validatorAddress
        tx.delegator = account.address
        tx.balance = self.balance.value.value
        tx.txType = .withdrawDelegatorReward
        tx.coin = coin
        
        let hub = FxHubNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: nil)
        let txMsg = TransactionMessage.withdrawReward(delegator: tx.delegator, validator: tx.validator, fee: "0", denom: coin.symbol, gas: 90000)
        return hub.estimatedFee(ofTx: txMsg).map { [weak self](gas: UInt64, gasPrice: String, fee: String) -> FxTransaction in
            guard let this = self else { return tx }
            
            tx.gasLimit = String(gas)
            tx.gasPrice = gasPrice
            tx.set(fee: fee, denom: this.coin.symbol)
            return tx
        }
    }
    
    private func fetchReward() {
        
        weak var welf = self
        self.hud?.waiting()
        FxAPIManager.fx.fetchDelegateReward(delegateAddress: account.address, validatorAddress: validator.validatorAddress)
            .subscribe { (value) in
                welf?.hud?.hide()
                guard let this = welf else { return }
                
                this.rewardAmount = value["rewardAmount"].string ?? "0"
                welf?.inputCell.inputTF.reactiveText = this.rewardAmount.div10(this.coin.decimal)
        } onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }.disposed(by: defaultBag)
    }
}
