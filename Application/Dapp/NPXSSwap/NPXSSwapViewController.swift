

import Web3
import WKKit
import RxSwift
import RxCocoa
import XChains
import TrustWalletCore

extension WKWrapper where Base == NPXSSwapViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension NPXSSwapViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let coin = context["coin"] as? Coin else { return nil }
        
        return NPXSSwapViewController(wallet: wallet, coin: coin)
    }
}

class NPXSSwapViewController: WKViewController { 
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        self.coin = coin
        self.wallet = wallet
        self.account = BehaviorRelay(value: .empty)
        super.init(nibName: nil, bundle: nil)
    }

    let coin: Coin
    let wallet: WKWallet
    private let account: BehaviorRelay<Keypair>
        
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private var contentCell = ContentCell()
    private var confirmCell = FxDelegateConfirmTxCell()
    private lazy var confirmEnable = BehaviorRelay<Bool>(value: false)
    
    private var ethBalance = ""
    private var npxsBalance = ""
    private var balanceBag: DisposeBag!
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindListView()
        
        bindAccount()
        bindConfirm()
        
        estimateFee()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("NPXSSwap.Big.Title")) 
    }
    
    private func bindListView() {
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 8.auto()))
        let titleCell = listBinder.push(TitleCell.self)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(contentCell, vm: contentCell)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 32.auto()))
        listBinder.push(confirmCell)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 50.auto()))
        
        titleCell.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
    }
    
    private func bindAccount() {
        
        weak var welf = self
        contentCell.addressActionButton.rx.tap.subscribe(onNext: { value in
            guard let this = welf else { return }
            
            Router.showSelectErc20Account(wallet: this.wallet, current: nil, filter: { c,_ in c.id == this.coin.id }) { (vc, _, account) in
                Router.dismiss(vc, animated: true) {
                    welf?.account.accept(account)
                }
            }
        }).disposed(by: defaultBag)
        
        account.filter{ !$0.isEmpty }
            .subscribe(onNext: { value in
                guard let this = welf else { return }
                
                welf?.contentCell.addressLabel.text = value.address
                if welf?.contentCell.state == .normal {

                    welf?.contentCell.state = .selected
                    welf?.contentCell.tokenIV.setImage(urlString: this.coin.imgUrl, placeHolderImage: this.coin.imgPlaceholder)
                    welf?.listBinder.refresh()
                }
                welf?.updateBalance(value)
        }).disposed(by: defaultBag)
    }
    
    private func updateBalance(_ account: Keypair) {
        
        let token = coin.token
        ethBalance = ""
        npxsBalance = ""
        confirmEnable.accept(false)
        contentCell.ethBalanceLabel.text = "\(unknownAmount) ETH"
        contentCell.npxsBalanceLabel.text = "\(unknownAmount) \(token)"
        contentCell.npxsAmountLabel.text = "\(unknownAmount) \(token)"
        contentCell.xsAmountLabel.text = "\(unknownAmount) \(Coin.FxSwapSymbol)"
        balanceBag = DisposeBag()
        
        self.hud?.waiting()
        let ethBalance = wallet.balance(of: account.address, coin: CoinService.current.ethereum)
        ethBalance.value.subscribe(onNext: { [weak self] value in
            guard !value.isUnknownAmount else { return }

            self?.ethBalance = value
            self?.contentCell.ethBalanceLabel.text = value.div10(18).thousandth() + " ETH"
            self?.checkInput()
        }).disposed(by: balanceBag)
        ethBalance.refreshIfNeed()

        let npxsBalance = wallet.balance(of: account.address, coin: coin)
        npxsBalance.value.subscribe(onNext: { [weak self] value in
            guard !value.isUnknownAmount else { return }
            self?.hud?.hide()

            self?.npxsBalance = value
            self?.contentCell.npxsBalanceLabel.text = value.div10(18).thousandth() + " \(token)"
            self?.contentCell.npxsAmountLabel.text = value.div10(18).thousandth() + " \(token)"
            self?.contentCell.xsAmountLabel.text = value.div10(18 + 3).thousandth() + " \(Coin.FxSwapSymbol)"
            self?.checkInput()
        }).disposed(by: balanceBag)
        npxsBalance.refreshIfNeed()
    }
    
    private func bindConfirm() {
        
        weak var welf = self
        confirmCell.checkBox.action {
            welf?.confirmCell.checkBox.isSelected = !(welf?.confirmCell.checkBox.isSelected ?? true)
            welf?.checkInput()
        }
 
        let checkBox = confirmCell.checkBox
        confirmCell.tipButton.action {
            Router.showAgreementAlert(doneHandler: { ( state ) in
                checkBox.isSelected = state
                return true
            }, state: checkBox.isSelected)
        } 
        confirmCell.submitButton.bind(self, action: #selector(doConfirm), forControlEvents: .touchUpInside)
        confirmEnable.bind(to: confirmCell.submitButton.rx.isEnabled).disposed(by: defaultBag)
    }
    
    private func checkInput() {
        if confirmCell.checkBox.isSelected, npxsBalance.isGreaterThan(decimal: "0") {
            confirmEnable.accept(true)
        } else {
            confirmEnable.accept(false)
        }
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
            
            Router.pushToBroadcastTx(tx: tx, account: this.account.value) { (error, result) in
                if WKError.canceled.isEqual(to: error) {
                    if result.count == 0, Router.canPop(to: "NPXSSwapViewController") {
                        Router.pop(to: "NPXSSwapViewController")
                    } else {
                        Router.popToRoot()
                    }
                }
            }
        }, onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }).disposed(by: defaultBag)
    }
    
    private var swapContract: String { NodeManager.shared.currentEthereumNode.isMainnet ? "0x5AE1b41D1598Ae6c3AD716eCf14f55cf301c3bD0" : "0x32Cac282752d86d260a88aeA596830CdBf12d2D1" }
    private func buildTx() -> Observable<FxTransaction> {
        
        let tx = FxTransaction()
        let amount = BigUInt(npxsBalance)!
        
        let abi = EthereumAbiEncoder.buildFunction(name: "transferAndCall")
        _ = abi?.addParamAddress(val: Data(hex: swapContract), isOutput: false)
        _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
        _ = abi?.addParamBytes(val: Data(hex: "0x00"), isOutput: false)
        let abiData = EthereumAbiEncoder.encode(func_in: abi!)
        var ethTx = EthereumTransaction(gasPrice: nil, gas: nil, from: EthereumAddress(hex: account.value.address), to: EthereumAddress(hex: coin.contract), value: 0, data: EthereumData(bytes: abiData.bytes))
        
        let node = EthereumNode(endpoint: coin.node.url, chainId: coin.node.chainId.i)
        let fetchGasLimit = node.estimatedGas(of: ethTx)
        let fetchGasPrice = APIManager.fx.estimateGasPrice().map { v -> EthereumQuantity in
            tx.mutilGasPrice = v
            return EthereumQuantity(quantity: BigUInt(tx.normalGasPrice) ?? 0 )
        }
        
        let balance = ethBalance
        return Observable.combineLatest(fetchGasPrice, fetchGasLimit)
            .map { [weak self](gasPrice, gas) -> FxTransaction in
                guard let this = self else { return tx }
            
                ethTx.gas = EthereumQuantity(quantity: gas)
                ethTx.gasPrice = gasPrice
                tx.sync(ethTx)
                tx.balance = balance
                tx.needVerify = true
                
                tx.coin = this.coin
                tx.set(amount: amount.description, denom: this.coin.symbol)
                this.contentCell.feeLabel.text = tx.decimalFee + " ETH"
                return tx
        }.take(1)
    }
    
    private func estimateFee() {
        
        let minGas = "172000"
        APIManager.fx.estimateGasPrice().subscribe(onNext: { [weak self] gasPrice in
            self?.contentCell.feeLabel.text = minGas.mul(gasPrice.slow).div10(18) + " ETH"
        }).disposed(by: defaultBag)
    }
}
        
