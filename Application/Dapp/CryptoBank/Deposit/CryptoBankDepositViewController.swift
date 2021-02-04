//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import Web3
import WKKit
import XChains
import RxSwift
import RxCocoa
import SwiftyJSON

extension WKWrapper where Base == CryptoBankDepositViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension CryptoBankDepositViewController {

    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin,
              let wallet = context["wallet"] as? WKWallet,
              let account = context["account"] as? Keypair else { return nil }

        return CryptoBankDepositViewController(wallet: wallet, coin: coin, account: account)
    }
}

class CryptoBankDepositViewController: WKViewController {

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
        
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private var inputCell: CryptoBankTxInputCell!
    private var approveCell: CryptoBankEnableTokenCell!
    private var confirmCell: CryptoBankConfirmTxCell!
    
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
        navigationBar.action(.title, title: TR("CryptoBank.Deposit"))
    }
    
    private func fetchData() {
        
        balance.refreshIfNeed()
        checkAllowance()
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
        inputCell = listBinder.push(CryptoBankTxInputCell.self)
        inputCell.addressTitleLabel.text = TR("CryptoBank.Deposit.$Deposits", coin.token)
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
            welf?.inputCell.maximumLabel.text = TR("CryptoBank.Deposit.MAX$", this.decimalBalance.thousandth()) + " \(this.coin.token)"
        }).disposed(by: defaultBag)
        
        inputCell.inputTF.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { v in
                guard let this = welf else { return }
            
                let text = this.inputCell.inputVIew.decimalText
                if text.isGreaterThan(decimal: this.decimalBalance) {
                    welf?.inputCell.inputTF.text = this.decimalBalance
                }
                welf?.inputCell.percentButtons.forEach{ $0.isSelected = false }
                welf?.confirmCell?.enable(text.f > 0)
        }).disposed(by: defaultBag)
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
        inputCell?.inputTF.reactiveText = ""
        
        weak var welf = self
        listBinder.pop(approveCell, refresh: false)
        confirmCell = listBinder.push(CryptoBankConfirmTxCell.self)
        confirmCell?.checkBox.action { welf?.confirmCell.checkBox.isSelected = !(welf?.confirmCell.checkBox.isSelected ?? true) }
        confirmCell.tipButton.isEnabled = false
        confirmCell?.tipButton.action {
            Router.showWebViewController(url: ThisAPP.WebURL.termServiceURL)
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
        buildDepositTx().subscribe(onNext: { tx in
            welf?.hud?.hide()
            guard let this = welf else { return }
            
            if !tx.balance.isGreaterThan(decimal: tx.fee) {
                welf?.hud?.text(m: "no enough ETH to pay fee")
                return
            }
            
            Router.pushToSendTokenFee(tx: tx, account: this.account) { (error, result) in
                if result["hash"].string != nil { welf?.save(result: result, of: tx) }
                
                if WKError.canceled.isEqual(to: error) {
                    Router.pop(to: "CryptoBankDepositViewController")
                }
            }
        }, onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }).disposed(by: defaultBag)
    }
    
    private func buildDepositTx() -> Observable<FxTransaction> {
        if coin.isETH { return buildDepositETHTx() }
        return buildDepositErc20Tx()
    }
    
    private func buildDepositETHTx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let aave = AAve.current
        let amount = inputCell.inputVIew.decimalText.mul10(coin.decimal)
        
        let rawTx = aave.wETHGateway.buildDepositTx(sender: account.address, amount: BigUInt(amount)!)
        let fetchGasLimit = aave.estimatedGas(of: rawTx)
        let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
            tx.mutilGasPrice = v
            return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
        }

        let balance = wallet.balance(of: account.address, coin: .ethereum).refresh()
        return Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance)
            .map { (gasPrice, gas, balance) -> FxTransaction in
            
                var ethTx = rawTx
                ethTx?.gas = EthereumQuantity(quantity: gas)
                ethTx?.gasPrice = gasPrice
                tx.sync(ethTx)
                tx.balance = balance
                tx.needVerify = true
                tx.isAaveDeposit = true
                tx.adjustMaxAmountIfNeed()
                tx.amountInData = tx.decimalAmount
                return tx
        }.take(1)
    }
    
    private func buildDepositErc20Tx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let aave = AAve.current
        let input = inputCell.inputVIew.decimalText
        let amount = input.mul10(coin.decimal)
        return aave.lendingPool.flatMap{ [weak self] lendingPool -> Observable<FxTransaction> in
            guard let this = self else { return .empty() }
            
            let rawTx = lendingPool.buildDepositTx(erc20: this.coin.contract, sender: this.account.address, amount: BigUInt(amount)!)
            let fetchGasLimit = aave.estimatedGas(of: rawTx)
            let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
                tx.mutilGasPrice = v
                return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
            }

            var balance = this.balance.refresh()
            if this.coin.isERC20 {
                balance = this.wallet.balance(of: this.account.address, coin: .ethereum).refresh()
            }
            
            return Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance)
                .map { (gasPrice, gas, balance) -> FxTransaction in
                
                    var ethTx = rawTx
                    ethTx?.gas = EthereumQuantity(quantity: gas)
                    ethTx?.gasPrice = gasPrice
                    tx.sync(ethTx)
                    tx.coin = this.coin
                    tx.balance = balance
                    tx.needVerify = true
                    tx.amountInData = input
                    tx.isAaveDeposit = true
                    return tx
            }
        }.take(1)
    }
    
    private func bindApprove() {
        
        listBinder.pop(confirmCell, refresh: false)
        approveCell = listBinder.push(CryptoBankEnableTokenCell.self)
        approveCell.view.approveButton.interactor.title = TR("CryptoBank.Deposit.Enable$", coin.token)
//        approveCell.tipLabel.text = TR("CryptoBank.Deposit.Approve$", coin.token)
        approveCell.view.approveButton.interactor.bind(self, action: #selector(doApprove), forControlEvents: .touchUpInside)
        listBinder.refresh()
    }
    
    @objc private func doApprove(_ sender: UIButton) {
        
        weak var welf = self
        sender.inactiveAWhile(1)
        self.view.endEditing(true)
        listBinder.view.isUserInteractionEnabled = false
        
        let actionView = approveCell.view
        actionView.state = .refresh
        buildApproveTx().subscribe(onNext: { tx in
            welf?.listBinder.view.isUserInteractionEnabled = true
            guard let this = welf else { return }
            
            if tx.fee.isGreaterThan(decimal: tx.balance) {
                actionView.state = .disabled
                this.hud?.text(m: "no enough ETH to pay fee")
            } else {
             
                Router.pushToSendTokenFee(tx: tx, account: this.account) { (error, result) in
                    
                    if result["hash"].string != nil {  actionView.state = .completed }
                    if error != nil,  actionView.state != .completed { actionView.state = .normal }
                    
                    if result["hash"].stringValue.length > 0 {
                        welf?.bindConfirm()
                        AAve.current.update(allowance: String(AAve.current.maxApproveAmount), owner: this.account.address, spender: AAve.current.lendingPoolAddress ?? "", tokenContract: this.coin.contract)
                    }
                    
                    if WKError.canceled.isEqual(to: error) {
                        Router.pop(to: "CryptoBankDepositViewController")
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
        let rawTx = AAve.current.buildApproveTx(erc20: coin.contract, owner: account.address, spender: AAve.current.lendingPoolAddress ?? "")
        
        let fetchGasLimit = AAve.current.estimatedGas(of: rawTx)
        let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
            tx.mutilGasPrice = v
            return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
        }

        var balance = self.balance.refresh()
        if coin.isERC20 {
            balance = wallet.balance(of: account.address, coin: .ethereum).refresh()
        }
        
        return Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance)
            .map { (gasPrice, gas, balance) -> FxTransaction in
            
                var ethTx = rawTx
                ethTx?.gas = EthereumQuantity(quantity: gas)
                ethTx?.gasPrice = gasPrice
                tx.sync(ethTx)
                tx.balance = balance
                return tx
        }.take(1)
    }
    
    private func checkAllowance() {
        
        weak var welf = self
        self.hud?.waiting()
        fetchAllowance().subscribe(onNext: { value in
            welf?.hud?.hide()
            
            if (BigUInt(value) ?? 0) < BigUInt("10000".wei)! {
                welf?.bindApprove()
            } else {
                DispatchQueue.main.async {
                    welf?.inputCell?.inputTF.becomeFirstResponder()
                }
            }
        }, onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }).disposed(by: defaultBag)
    }
    
    private func fetchAllowance() -> Observable<String> {
        if coin.isETH { return .just(String(AAve.current.maxApproveAmount)) }
        
        return AAve.current.lendingPool.flatMap{ lendingPool -> Observable<String> in
            return AAve.current.allowance(owner: self.account.address, spender: lendingPool.address, tokenContract: self.coin.contract)
        }
    }
    
    private func save(result: JSON, of tx: FxTransaction) {
        
        let info = CryptoBankTxInfo()
        info.type = .deposit
        info.walletId = wallet.id
        
        info.coin = coin
        info.txHash = result["hash"].stringValue
        info.amount = tx.amountInData
        info.address = account.address
        info.timestamp = result["time"].int64Value / 1000
        _ = CryptoBankTxCache.shared.insertOrReplace([info]).subscribe()
    }
}
        
