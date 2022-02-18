//
//  FxClaimViewController.swift
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

extension WKWrapper where Base == FxClaimViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension FxClaimViewController {

    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin,
              let wallet = context["wallet"] as? WKWallet,
              let account = context["account"] as? Keypair else { return nil }

        return FxClaimViewController(wallet: wallet, coin: coin, account: account)
    }
}

class FxClaimViewController: WKViewController {

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
        navigationBar.action(.title, title: TR("FxStaking.Overview.Claim"))
    }
    
    private func fetchData() {
        
        weak var welf = self
        self.hud?.waiting()
        confirmCell?.enable(false)
        bank.rewardPart(of: account.address).subscribe(onNext: { (unlocked, _) in
            welf?.hud?.hide()
            
            welf?.confirmCell.enable(!unlocked.isZero)
            welf?.decimalBalance = unlocked.div10(18)
            welf?.inputCell.inputTF.text = unlocked.div10(18).thousandth(10, autoTrim: false)
        }, onError: { (_) in
            welf?.hud?.hide()
        }).disposed(by: defaultBag)
    }
    
    private func bind() {
        
        bindInput()
        bindConfirm()
        listBinder.scrollViewDidScroll = { [weak self] _ in
            self?.view.endEditing(true)
        }
    }
    
    private func bindInput() {
        
        inputCell = FxStakingTxInputCell()
        inputCell.type = .disableEdit
        listBinder.push(inputCell, vm: inputCell)
        inputCell.addressTitleLabel.text = "FX \(TR("FxStaking.Overview.Claim"))"
        inputCell.addressLabel.text = account.address
        inputCell.tokenLabel.text = "FX"
        inputCell.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
        inputCell.inputVIew.decimalLimit = coin.decimal
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
        confirmCell?.submitButton.bind(self, action: #selector(doConfirm), forControlEvents: .touchUpInside)
        listBinder.refresh()
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
        let decimalText = decimalBalance
        let amount = decimalText.mul10(coin.decimal)

        let rawTx = bank.buildClaimTx(from: account.address)
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
                tx.amountInData = amount
                tx.coin = coin
                tx.set(amount: amount, denom: Coin.FxRewardSymbol)
                return tx
        }.take(1)
        
        return bank.rewardIsAvailable().flatMap{ v -> Observable<FxTransaction> in
            if !v { return .error(WKError(.default, TR("FxStaking.ClaimIsClosed"))) }
            return buildTx
        }
    }
}
