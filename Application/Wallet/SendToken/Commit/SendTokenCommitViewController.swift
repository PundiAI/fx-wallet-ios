
import BigInt
import FunctionX
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit
import XChains
extension WKWrapper where Base == SendTokenCommitViewController {
    var view: SendTokenCommitViewController.View { return base.view as! SendTokenCommitViewController.View }
}

extension SendTokenCommitViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction,
            let account = context["account"] as? Keypair else { return nil }
        return SendTokenCommitViewController(tx: tx, account: account)
    }
}

class SendTokenCommitViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction, account: Keypair) {
        self.tx = tx
        self.account = account
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    let tx: FxTransaction
    var coin: Coin { tx.coin }
    let account: Keypair
    private var wallet: Wallet { XWallet.sharedKeyStore.currentWallet! }
    lazy var userNameBinder = UserNameListBinder(view: wk.view.searchListView)
    lazy var recommendReceiverBinder = RecommendReceiverBinder(view: wk.view.mainListView)
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bindUserNameList()
        bindRecommendList()
        bindInput()
        bindConfirm()
        bindKeyboard()
    }

    override func bindNavBar() {
        navigationBar.isHidden = true
        wk.view.navBar.backButton.action { [weak self] in
            Router.pop(self)
        }
    }

    var receiver: User? {
        didSet {
            guard let user = receiver else { return }
            wk.view.inputTF.reactiveText = user.name.isNotEmpty ? "@\(user.name)" : user.address
        }
    }

    private func bindRecommendList() {
        recommendReceiverBinder.bind(wallet: wallet, coin: coin)
        recommendReceiverBinder.didSeleted = { [weak self] user in
            self?.receiver = user
        }
    }

    private func bindUserNameList() {
        userNameBinder.bind(wallet: wallet, coin: coin, input: wk.view.inputTF)
        userNameBinder.didSeleted = { [weak self] user in
            self?.receiver = user
        }
    }

    private func bindInput() {
        if tx.receiver.address.isNotEmpty { receiver = tx.receiver }
        wk.view.inputTF.delegate = self
        wk.view.scanButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let this = self else { return }
            Router.pushToFxScanQRCode { text in
                let json = text.qrCodeInfo
                Router.pop(Router.currentNavigator?.topViewController, animated: false, completion: nil)
                if json["address"].stringValue.isEmpty {
                    this.hud?.text(m: "Unknown Address")
                } else {
                    let receiver = User(address: json["address"].stringValue)
                    this.receiver = receiver
                }
            }
        }).disposed(by: defaultBag)
    }

    private func bindConfirm() {
        weak var welf = self
        let isValidAddress = wk.view.inputTF.rx.text.map { welf?.isValid(input: $0) ?? false }
        isValidAddress
            .bind(to: wk.view.nextButton.rx.isEnabled)
            .disposed(by: defaultBag)
        wk.view.nextButton.rx.tap.subscribe(onNext: { _ in
            welf?.view.endEditing(true)
            guard let this = welf, let input = this.wk.view.inputTF.text else { return }
            let receiver: User
            let selected = welf?.receiver ?? User()
            if input.hasPrefix("@") {
                let name = input.substring(from: 1)
                receiver = User(address: selected.name == name ? selected.address : "", name: name)
            } else {
                receiver = User(address: input, name: selected.address == input ? selected.name : "")
            }
            this.sendToken(to: receiver)
        }).disposed(by: defaultBag)
    }

    private func bindKeyboard() {
        Observable.merge([wk.view.mainListView.rx.didScroll.asObservable(),
                          wk.view.searchListView.rx.didScroll.asObservable()])
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            }).disposed(by: defaultBag)
    }

    private func sendToken(to receiver: User) {
        wk.view.nextButton.inactiveAWhile()
        weak var welf = self
        hud?.waiting()
        fetchAddress(receiver)
            .flatMap { _ in welf?.fetchFee() ?? .empty() }
            .subscribe(onNext: { t in
                welf?.hud?.hide()
                guard let this = welf else { return }
                let (gas, gasPrice, balance) = t
                this.tx.balance = balance
                this.tx.gasLimit = gas
                this.tx.gasPrice = gasPrice
                this.tx.set(fee: gas.mul(gasPrice), denom: this.coin.feeSymbol)
                this.tx.adjustMaxAmountIfNeed()
                if this.tx.fee.isGreaterThan(decimal: balance) {
                    this.hud?.text(m: "no enough \(this.coin.feeSymbol) to pay fee")
                } else {
                    this.wallet.wk.receivers(forCoin: this.coin).addOrUpdate(receiver)
                    this.wallet.wk.accountRecord.addOrUpdate((this.coin, this.account))
                    Router.pushToSendTokenFee(tx: this.tx, account: this.account)
                }
            }, onError: { e in
                welf?.hud?.hide()
                welf?.hud?.error(m: e.asWKError().msg)
            }).disposed(by: defaultBag)
    }

    private func fetchAddress(_ receiver: User) -> Observable<String> {
        weak var welf = self
        let fetchAddress: Observable<String>
        if receiver.name.isEmpty {
            fetchAddress = .just(receiver.address)
        } else {
            fetchAddress = APIManager.fx.address(of: receiver.name)
                .do(onError: { welf?.inputError($0.asWKError().msg) })
        }
        return fetchAddress.do(onNext: { address in
            guard let this = welf else { return }
            receiver.address = address
            this.tx.receiver = receiver
            this.tx.sender.address = this.account.address
        })
    }

    private func fetchFee() -> Observable<(String, String, String)> {
        let coin = tx.coin
        let amount = tx.amount
        var balance = Observable<String>.just(tx.balance)
        if coin.isFunctionX {
            let node = FxNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: nil)
            let txMsg = TransactionMessage.sendTx(from: tx.from, to: tx.to, amount: amount, fee: "0", denom: coin.symbol, gas: 0)
            return Observable.combineLatest(node.estimatedGas(ofTx: txMsg).map { String($0) }, fxGasPrice(), balance)

        } else if coin.isEthereum {
            let node = EthereumNode(endpoint: coin.node.url, chainId: 0)
            var estimatedGas = Observable<String>.just("21000")
            if coin.isERC20 {
                balance = node.balance(of: account.address)
                estimatedGas = node.estimatedGasOfTx(from: tx.from, to: tx.to, amount: BigUInt(amount)!, tokenContract: coin.contract)
                    .map { $0.d < 60000 ? "60000" : $0 }
            }
            return Observable.combineLatest(estimatedGas, ethGasPrice(), balance)
        }
        return .error(WKError(.default, "fetch fee failed"))
    }

    private func ethGasPrice() -> Observable<String> {
        return APIManager.fx.estimateGasPrice().flatMap { [weak self] (slow, normal, fast) -> Observable<String> in
            self?.tx.slowGasPrice = slow["fee"].stringValue
            self?.tx.slowGasPriceTime = slow["time"].stringValue
            self?.tx.normalGasPrice = normal["fee"].stringValue
            self?.tx.normalGasPriceTime = normal["time"].stringValue
            self?.tx.fastGasPrice = fast["fee"].stringValue
            self?.tx.fastGasPriceTime = fast["time"].stringValue
            return .just(normal["fee"].stringValue)
        }
    }

    private func fxGasPrice() -> Observable<String> {
        let node = FxNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: nil)
        return node.gasPrice().map { [weak self] gasPrice in
            self?.tx.slowGasPrice = gasPrice
            self?.tx.slowGasPriceTime = "2"
            self?.tx.normalGasPrice = gasPrice.mul("1.1", 0)
            self?.tx.normalGasPriceTime = "1"
            self?.tx.fastGasPrice = gasPrice.mul("1.2", 0)
            self?.tx.fastGasPriceTime = "0.5"
            return gasPrice
        }
    }

    private func isValid(input: String?) -> Bool {
        let text = input ?? ""
        var result = text.count > 2 && text.hasPrefix("@")
        if !result {
            if coin.is(.ethereum) {
                result = AnyAddress.isValid(string: text, coin: .ethereum)
            } else if coin.isFunctionX {
                result = FunctionXAddress.isValid(string: text)
            }
        }
        return result
    }

    private func inputError(_ text: String) {
        hud?.text(m: text)
        wk.view.showInputError()
        wk.view.nextButton.isEnabled = false
    }
}

extension SendTokenCommitViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        wk.view.isEditing = true
    }

    func textFieldDidEndEditing(_: UITextField) {
        wk.view.isEditing = false
    }
}

extension SendTokenCommitViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SendTokenInputViewController", "SendTokenCommitViewController"): return animators["1"]
        case ("SendTokenCommitViewController", "SendTokenFeeViewController"): return animators["0"]
        default: return nil
        }
    }

    private func bindHero() { weak var welf = self
        let onSuspendBlock: (WKHeroAnimator) -> Void = { _ in
            welf?.wk.view.header.hero.id = nil
            welf?.wk.view.header.hero.modifiers = nil
            welf?.wk.view.headerContentView.hero.modifiers = nil
            welf?.wk.view.backgroundView.hero.id = nil
            welf?.wk.view.backgroundView.hero.modifiers = nil
            welf?.wk.view.mainListView.hero.modifiers = nil
            welf?.wk.view.nextButton.titleLabel?.hero.modifiers = nil
        }
        let animator = WKHeroAnimator({ _ in
            welf?.wk.view.nextButton.hero.id = "backgroundView"
            welf?.wk.view.nextButton.titleLabel?.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.nextButton.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.mainListView.hero.modifiers = [.useGlobalCoordinateSpace,
                                                         .useOptimizedSnapshot,
                                                         .translate(y: 1000)]
            welf?.wk.view.header.hero.id = "backgroundView_white" welf?.wk.view.headerContentView.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
        animators["0"] = animator
        let animator1 = WKHeroAnimator({ _ in
            welf?.wk.view.headerContentView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y: -600)]
            welf?.wk.view.header.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y: -600)]
            welf?.wk.view.mainListView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 1000)]
        }, onSuspend: onSuspendBlock)
        animators["1"] = animator1
    }
}
