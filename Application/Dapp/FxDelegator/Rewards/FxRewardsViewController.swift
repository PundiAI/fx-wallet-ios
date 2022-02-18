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
    private var contentCell = ContentCell()
    private var confirmCell = FxDelegateConfirmTxCell()
    
    private var rewardAmount = ""
    private lazy var balance = wallet.balance(of: account.address, coin: coin)
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindListView()
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
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 8.auto()))
        listBinder.push(contentCell, vm: contentCell)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 32.auto()))
        listBinder.push(confirmCell)
        
        contentCell.validatorIV.setImage(urlString: validator.imageURL, placeHolderImage: IMG("Dapp.Placeholder"))
        contentCell.validatorNameLabel.text = validator.validatorName
        contentCell.validatorAddressLabel.text = validator.validatorAddress
        
        contentCell.fxcRewardsTLabel.text = "\(coin.token) \(TR("FXDelegator.Rewards"))"
        contentCell.fxUSDRewardsTLabel.text = "\(Coin.FxUSDSymbol) \(TR("FXDelegator.Rewards"))"
        setRewards(validator: validator)
    }
        
    private func setRewards(validator: Validator) {
        contentCell.fxcRewardsLabel.text = validator.reward(of: coin.symbol).div10(coin.decimal).thousandth() + " \(coin.token)"
        contentCell.fxUSDRewardsLabel.text = validator.reward(of: Coin.FxUSDSymbol).div10(coin.decimal).thousandth() + " \(Coin.FxUSDSymbol)"
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
        
        let wallet = FxWallet(privateKey: account.privateKey)
        let hub = FxHubNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: wallet)
        return hub.buildWithdrawRewardTx(fromValidator: tx.validator, fee: "1", denom: coin.symbol, gas: 0).flatMap{ txMsg in
            
            return hub.estimatedFee(ofTx: txMsg).map { [weak self](gas: UInt64, gasPrice: String, fee: String) -> FxTransaction in
                guard let this = self else { return tx }

                tx.gasLimit = String(gas)
                tx.gasPrice = gasPrice
                tx.set(fee: fee, denom: this.coin.symbol)
                return tx
            }
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
                welf?.setRewards(validator: Validator(json: value))
                welf?.confirmCell.enable(this.rewardAmount.isGreaterThan(decimal: "0"))
        } onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }.disposed(by: defaultBag)
    }
}
