//
//  FxStakeViewController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/8.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Web3
import WKKit
import XChains
import RxSwift
import RxCocoa
import SwiftyJSON

extension WKWrapper where Base == FxStakeViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension FxStakeViewController {

    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin,
              let wallet = context["wallet"] as? WKWallet,
              let account = context["account"] as? Keypair else { return nil }

        return FxStakeViewController(wallet: wallet, coin: coin, account: account)
    }
}

class FxStakeViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, account: Keypair) {
        self.coin = coin
        self.wallet = wallet
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }

    let coin: Coin
    let wallet: WKWallet
    let account: Keypair
    var bank: FxStaking.Bank { FxStaking.current.bank(of: coin) }
        
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private var inputCell: FxStakingTxInputCell!
    private var confirmCell: FxStakingConfirmTxCell!
    
    private var decimalBalance = ""
    private lazy var balance = wallet.balance(of: account.address, coin: coin)
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bind()
        
        fetchData()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("FxStaking.Overview.Stake"))
    }
    
    private func fetchData() {
        checkAllowance()
        balance.refreshIfNeed()
    }
    
    private func bind() {
        
        bindInput()
        bindConfirm()
        listBinder.scrollViewDidScroll = { [weak self] _ in
            self?.view.endEditing(true)
        }
    }
    
    private func bindInput() {
        
        weak var welf = self
        inputCell = listBinder.push(FxStakingTxInputCell.self)
        inputCell.addressTitleLabel.text = "\(coin.token) \(TR("FxStaking.Overview.Stake"))"
        inputCell.addressLabel.text = account.address
        inputCell.tokenLabel.text = coin.token
        inputCell.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
        inputCell.inputVIew.decimalLimit = coin.decimal
        inputCell.percentButtons.forEach{ $0.bind(welf, action: #selector(onClick), forControlEvents: .touchUpInside) }
        
        inputCell.percentEnable(false)
        balance.value.subscribe(onNext: { value in
            guard let this = welf else { return }
            
            this.decimalBalance = value.div10(this.coin.decimal)
            welf?.inputCell.percentEnable(value.isGreaterThan(decimal: "0"))
            welf?.inputCell.maximumLabel.text = this.decimalBalance.thousandth(this.coin.decimal, autoTrim: false) + " \(this.coin.token)"
        }).disposed(by: defaultBag)
        
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
                
                if welf?.confirmCell?.actionView.isApproved == true {
                    welf?.confirmCell?.enable(text.f > 0)
                }
        }).disposed(by: defaultBag)
    }
    
    private func bindConfirm() {
        
        weak var welf = self
        confirmCell = listBinder.push(FxStakingConfirmTxCell.self)
        confirmCell?.checkBox.action { welf?.confirmCell.checkBox.isSelected = !(welf?.confirmCell.checkBox.isSelected ?? true) }
        let checkBox = confirmCell.checkBox
        confirmCell?.tipButton.action {
            Router.showAgreementAlert(doneHandler: { ( state ) in
                checkBox.isSelected = state
                return true
            }, state: checkBox.isSelected) 
        }
        confirmCell?.actionView.approveButton.interactor.bind(self, action: #selector(doApprove), forControlEvents: .touchUpInside)
        confirmCell?.actionView.step2Button.interactor.bind(self, action: #selector(doConfirm), forControlEvents: .touchUpInside)
        confirmCell?.submitButton.bind(self, action: #selector(doConfirm), forControlEvents: .touchUpInside)
        listBinder.refresh()
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
    
    @objc private func doConfirm(_ sender: UIButton) {
        
        weak var welf = self
        sender.inactiveAWhile(1)
        self.view.endEditing(true)
        guard (confirmCell?.checkBox.isSelected ?? false) else {
            self.hud?.text(m: TR("AgreeToTermsNotice"))
            return
        }
        
        self.hud?.waiting()
        buildTx().subscribe(onNext: { tx in
            welf?.hud?.hide()
            guard let this = welf else { return }
            
            if !tx.balance.isGreaterThan(decimal: tx.fee) {
                welf?.hud?.text(m: TR("Alert.Tip$", "ETH"))
                return
            }
            
            Router.pushToSendTokenFee(tx: tx, account: this.account) { (error, result) in
                
                if WKError.canceled.isEqual(to: error) {
                    Router.pop(to: "FxStakingOverviewViewController")
                }
            }
        }, onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }).disposed(by: defaultBag)
    }
    
    private func buildTx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let decimalText = inputCell.maxButton.isSelected ? decimalBalance : inputCell.inputVIew.decimalText
        let amount = decimalText.mul10(coin.decimal)

        let rawTx = bank.buildDepositTx(from: account.address, amount: BigUInt(amount)!)
        let fetchGasLimit = bank.estimatedGas(of: rawTx)
        let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
            tx.mutilGasPrice = v
            return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
        }
        
        let coin = self.coin
        let balance = wallet.balance(of: account.address, coin: .ethereum).refresh()
        let buildTx = Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance)
            .map { (gasPrice, gas, balance) -> FxTransaction in

                var ethTx = rawTx
                ethTx?.gas = EthereumQuantity(quantity: gas)
                ethTx?.gasPrice = gasPrice
                tx.sync(ethTx)
                tx.coin = coin
                tx.balance = balance
                tx.needVerify = true
                
                tx.coin = coin
                tx.set(amount: amount, denom: coin.symbol)
                return tx
        }.take(1)
        return stakeIsAvailable().flatMap{ _ in
            return buildTx
        }
    }
    
    @objc private func doApprove(_ sender: UIButton) {
        
        weak var welf = self
        sender.inactiveAWhile(1)
        self.view.endEditing(true)
        listBinder.view.isUserInteractionEnabled = false
        allowanceIsEnough?.cancel()
        
        let actionView = confirmCell.actionView
        actionView.state = .refresh
        buildApproveTx().subscribe(onNext: { tx in
            welf?.listBinder.view.isUserInteractionEnabled = true
            guard let this = welf else { return }
            
            if tx.fee.isGreaterThan(decimal: tx.balance) {
                actionView.state = .disabled
                this.hud?.text(m: TR("Alert.Tip$", "ETH"))
            } else {
             
                Router.pushToSendTokenFee(tx: tx, account: this.account) { (error, result) in
                    
                    if error != nil, result.isEmpty { actionView.state = .normal }
                    if result["hash"].string != nil { this.pollingCheckAllowance() }
                    
                    if WKError.canceled.isEqual(to: error) {
                        Router.pop(to: "FxStakeViewController")
                    }
                }
            }
        }, onError: { (e) in
            welf?.listBinder.view.isUserInteractionEnabled = true
            welf?.hud?.text(m: e.asWKError().msg)
            actionView.state = .normal
        }).disposed(by: defaultBag)
    }
    
    private func buildApproveTx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let rawTx = FxStaking.current.buildApproveTx(erc20: coin.contract, owner: account.address, spender: bank.address)
        
        let fetchGasLimit = FxStaking.current.estimatedGas(of: rawTx)
        let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
            tx.mutilGasPrice = v
            return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
        }

        let balance = wallet.balance(of: account.address, coin: .ethereum).refresh()
        let buildTx = Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance)
            .map { (gasPrice, gas, balance) -> FxTransaction in
            
                var ethTx = rawTx
                ethTx?.gas = EthereumQuantity(quantity: gas)
                ethTx?.gasPrice = gasPrice
                tx.sync(ethTx)
                tx.balance = balance
                return tx
        }.take(1)
        return stakeIsAvailable().flatMap{ _ in
            return buildTx
        }
    }
    
    var allowanceIsEnough: PollingTask<String>?
    private func pollingCheckAllowance() {
        
        weak var welf = self
        let task = PollingTask<String>(workFactory: { return welf?.fetchAllowance() ?? .error(WKError.timeout) },
                                       takeUtil: { $0.isGreaterThan(decimal: "10000".wei) })
        task.run().subscribe(onNext: { (value, e) in
            if value != nil {
                welf?.confirmCell.actionView.state = .completed
                welf?.inputCell.inputTF.sendActions(for: .allEditingEvents)
            } else if WKError.canceled.isEqual(to: e?.asWKError()) {
                welf?.confirmCell.actionView.state = .disabled
            }
        }).disposed(by: defaultBag)
        self.allowanceIsEnough = task
    }
    
    private func checkAllowance() {
        
        weak var welf = self
        self.hud?.waiting()
        fetchAllowance().subscribe(onNext: { value in
            welf?.hud?.hide()

            if (BigUInt(value) ?? 0) > BigUInt("10000".wei)! {
                welf?.confirmCell.actionView.mode = .multiStep
                
                welf?.listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 16.auto()))
                welf?.listBinder.push(ApproveTipCell.self)
                welf?.listBinder.refresh()
            }
        }, onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }).disposed(by: defaultBag)
        
//        confirmCell.actionView.mode = .multiStep
//        confirmCell.actionView.state = .completed
    }
    
    private func fetchAllowance() -> Observable<String> {
        bank.allowance(owner: account.address, spender: bank.address, tokenContract: coin.contract)
    }
    
    private func stakeIsAvailable() -> Observable<Bool> {
        return bank.stakeIsAvailable().flatMap{ v -> Observable<Bool> in
            if !v { return .error(WKError(.default, TR("FxStaking.StakeIsClosed"))) }
            
            return .just(v)
        }
    }
}
