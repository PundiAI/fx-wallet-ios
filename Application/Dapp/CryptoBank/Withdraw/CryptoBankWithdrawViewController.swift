//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import Web3
import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON

extension WKWrapper where Base == CryptoBankWithdrawViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension CryptoBankWithdrawViewController {

    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin,
              let wallet = context["wallet"] as? WKWallet,
              let account = context["account"] as? Keypair else { return nil }

        return CryptoBankWithdrawViewController(wallet: wallet, coin: coin, account: account)
    }
}

class CryptoBankWithdrawViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, account: Keypair) {
        self.token = coin
        self.aToken = coin.aToken ?? .empty
        self.wallet = wallet
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }

    let token: Coin
    let aToken: Coin
    let wallet: WKWallet
    let account: Keypair
        
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private var inputCell: CryptoBankTxInputCell!
    private var approveCell: CryptoBankEnableTokenCell!
    private var confirmCell: CryptoBankConfirmTxCell!
    
    private var decimalBalance = ""
    private lazy var balance = wallet.balance(of: account.address, coin: aToken)
    
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
        navigationBar.action(.title, title: TR("CryptoBank.Withdraw"))
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
        inputCell.addressTitleLabel.text = TR("CryptoBank.Withdraw.$Withdraw", token.token)
        inputCell.addressLabel.text = account.address
        inputCell.tokenLabel.text = aToken.symbol
        inputCell.tokenIV.setImage(urlString: token.imgUrl, placeHolderImage: token.imgPlaceholder)
        inputCell.inputVIew.decimalLimit = token.decimal
        inputCell.percentButtons.forEach{ $0.bind(welf, action: #selector(onClick), forControlEvents: .touchUpInside) }
        
        inputCell.percentEnable(false)
        balance.value.subscribe(onNext: { value in
            guard let this = welf else { return }
            
            this.decimalBalance = value.div10(this.token.decimal)
            welf?.inputCell.percentEnable(value.isGreaterThan(decimal: "0"))
            welf?.inputCell.maximumLabel.text = TR("CryptoBank.Withdraw.MAX$", this.decimalBalance.thousandth()) + " \(this.aToken.symbol)"
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
        confirmCell?.tipButton.action { Router.showWebViewController(url: ThisAPP.WebURL.termServiceURL) }
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
        buildWithdrawTx().subscribe(onNext: { tx in
            welf?.hud?.hide()
            guard let this = welf else { return }
            
            Router.pushToSendTokenFee(tx: tx, account: this.account) { (error, result) in
                if result["hash"].string != nil { welf?.save(result: result, of: tx) }
                
                if WKError.canceled.isEqual(to: error) {
                    Router.pop(to: "CryptoBankWithdrawViewController")
                }
            }
        }, onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }).disposed(by: defaultBag)
    }
    
    private func buildWithdrawTx() -> Observable<FxTransaction> {
        if token.isETH { return buildWithdrawETHTx() }
        return buildWithdrawERC20Tx()
    }
    
    private func buildWithdrawETHTx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let aave = AAve.current
        let input = inputCell.inputVIew.decimalText
        let amount = input.mul10(token.decimal)
        let entire = inputCell?.maxButton.isSelected == true
        let rawTx = aave.wETHGateway.buildWithdrawTx(sender: account.address, amount: BigUInt(amount)!, entire: entire)
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
                tx.amountInData = input
                tx.isAaveWithdraw = true
                return tx
        }.take(1)
    }
    
    private func buildWithdrawERC20Tx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let aave = AAve.current
        let input = inputCell.inputVIew.decimalText
        let amount = input.mul10(token.decimal)
        return aave.lendingPool.flatMap{ [weak self] lendingPool -> Observable<FxTransaction> in
            guard let this = self else { return .empty() }
            
            let entire = this.inputCell?.maxButton.isSelected == true
            let rawTx = lendingPool.buildWithdrawTx(erc20: this.token.contract, sender: this.account.address, amount: BigUInt(amount)!, entire: entire)
            let fetchGasLimit = aave.estimatedGas(of: rawTx)
            let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
                tx.mutilGasPrice = v
                return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
            }
            
            var balance = this.balance.refresh()
            if this.token.isERC20 {
                balance = this.wallet.balance(of: this.account.address, coin: .ethereum).refresh()
            }
            
            return Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance)
                .map { (gasPrice, gas, balance) -> FxTransaction in
                
                    var ethTx = rawTx
                    ethTx?.gas = EthereumQuantity(quantity: gas)
                    ethTx?.gasPrice = gasPrice
                    tx.sync(ethTx)
                    tx.coin = this.token
                    tx.balance = balance
                    tx.needVerify = true
                    tx.amountInData = input
                    tx.isAaveWithdraw = true
                    return tx
            }
        }.take(1)
    }
    
    private func bindApprove() {
        
        listBinder.pop(confirmCell, refresh: false)
        approveCell = listBinder.push(CryptoBankEnableTokenCell.self)
        approveCell.view.approveButton.interactor.title = TR("CryptoBank.Deposit.Enable$", token.token)
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
            
            Router.pushToSendTokenFee(tx: tx, account: this.account) { (error, result) in
                
                if result["hash"].string != nil {  actionView.state = .completed }
                if error != nil,  actionView.state != .completed { actionView.state = .normal }
                
                if result["hash"].stringValue.length > 0 {
                    welf?.bindConfirm()
                    AAve.current.update(allowance: String(AAve.current.maxApproveAmount), owner: this.account.address, spender: this.approveSpender, tokenContract: this.approveToken)
                }
                
                if WKError.canceled.isEqual(to: error) {
                    Router.pop(to: "CryptoBankWithdrawViewController")
                }
            }
        }, onError: { (e) in
            welf?.listBinder.view.isUserInteractionEnabled = true
            welf?.hud?.text(m: e.asWKError().msg)
            actionView.state = .normal
        }).disposed(by: defaultBag)
    }
    
    var approveToken: String { return token.isETH ? aToken.contract : token.contract }
    var approveSpender: String { return token.isETH ? AAve.current.wETHGateway.address : AAve.current.lendingPoolAddress ?? "" }
    private func buildApproveTx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let rawTx = AAve.current.buildApproveTx(erc20: approveToken, owner: account.address, spender: approveSpender)
        
        let fetchGasLimit = AAve.current.estimatedGas(of: rawTx)
        let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
            tx.mutilGasPrice = v
            return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
        }
        
//        let fetchGasPrice = Observable.just((JSON(["fee": "500".gwei, "time": 1.0]), JSON(["fee": "500".gwei, "time": 2.0]), JSON(["fee": "500".gwei, "time": 3.0]))).map { t -> EthereumQuantity in
//            tx.setGasPrice(t)
//            return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
//        }
        
        var balance = wallet.balance(of: account.address, coin: token).refresh()
        if token.isERC20 {
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
        
        if token.isETH {
            return AAve.current.allowance(owner: self.account.address, spender: self.approveSpender, tokenContract: self.approveToken)
        } else {
            return AAve.current.lendingPool.flatMap{ lendingPool -> Observable<String> in
                return AAve.current.allowance(owner: self.account.address, spender: lendingPool.address, tokenContract: self.approveToken)
            }
        }
    }
    
    private func save(result: JSON, of tx: FxTransaction) {
        
        let info = CryptoBankTxInfo()
        info.type = .withdraw
        info.walletId = wallet.id
        
        info.coin = token
        info.txHash = result["hash"].stringValue
        info.amount = tx.amountInData
        info.address = account.address
        info.timestamp = result["time"].int64Value / 1000
        _ = CryptoBankTxCache.shared.insertOrReplace([info]).subscribe()
    }
}
        
