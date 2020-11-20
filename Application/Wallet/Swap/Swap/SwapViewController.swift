
import AloeStackViewimport Web3
import BigInt
import Hero
import RxCocoa
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit
extension WKWrapper where Base == SwapViewController {
    var view: SwapViewController.View { return base.view as! SwapViewController.View }
}

extension SwapViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = SwapViewController(wallet: wallet)
        return vc
    }
}

class SwapViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }

    private let wallet: WKWallet
    fileprivate lazy var viewModel = SwapViewModel(wallet)
    override func loadView() { view = View(frame: ScreenBounds) }
    lazy var contentBinder: SwapViewBinder = {
        SwapViewBinder(stackView: self.wk.view.contentView,
                       view: self.wk.view,
                       viewModel: self.viewModel)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        contentBinder.bind()
    }

    deinit {
        contentBinder.resetDag = DisposeBag()
    }

    override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Swap"))
        navigationBar.action(.left, imageName: "ic_back_60") { [weak self] in
            Router.pop(self)
        }
    }
}

class WKViewModelBinder<T: UIView, M>: NSObject {
    var resetDag = DisposeBag()
    public let stackView: AloeStackView!
    public let view: T!
    public let vModel: M!
    init(stackView: AloeStackView, view: T, viewModel: M) {
        self.view = view
        vModel = viewModel
        self.stackView = stackView
        super.init()
        logWhenDeinit()
    }

    func bind() {}
    deinit {
        resetDag = DisposeBag()
    }
}

extension SwapViewController {
    class SwapViewBinder: WKViewModelBinder<View, SwapViewModel> {
        lazy var rateBinder: RateBoothBinder = {
            let binder = RateBoothBinder(stackView: self.stackView,
                                         view: self.view.pricePanelView,
                                         viewModel: self.vModel)
            binder.topSpaceView = self.view.topSpaceView
            return binder
        }()

        lazy var inputFromBinder: InputFromBinder = {
            let binder = InputFromBinder(stackView: self.stackView,
                                         view: self.view.inputFromView,
                                         viewModel: self.vModel)
            return binder
        }()

        lazy var inputSwitchBinder: InputSwitchBinder = {
            let binder = InputSwitchBinder(stackView: self.stackView,
                                           view: self.view.inputChangeView,
                                           viewModel: self.vModel)
            binder.inputFromBinder = self.inputFromBinder
            binder.inputToBinder = self.inputToBinder
            return binder
        }()

        lazy var inputToBinder: InputToBinder = {
            let binder = InputToBinder(stackView: self.stackView,
                                       view: self.view.inputToView,
                                       viewModel: self.vModel)
            return binder
        }()

        lazy var outputPriceToBinder: OutputPriceBinder = {
            let binder = OutputPriceBinder(stackView: self.stackView,
                                           view: self.view.outputPriceView,
                                           viewModel: self.vModel)
            binder.inputFromBinder = self.inputFromBinder
            return binder
        }()

        lazy var outputInfoToBinder: OutputInfoBinder = {
            let binder = OutputInfoBinder(stackView: self.stackView,
                                          view: self.view.outputInfoView,
                                          viewModel: self.vModel)
            return binder
        }()

        lazy var outputPairPathsBinder: OutputPairPathsBinder = {
            let binder = OutputPairPathsBinder(stackView: self.stackView,
                                               view: self.view.outputPairPathView,
                                               viewModel: self.vModel)
            return binder
        }()

        lazy var outputActionBinder: OutputActionBinder = {
            let binder = OutputActionBinder(stackView: self.stackView,
                                            view: self.view.actionView,
                                            viewModel: self.vModel)
            binder.inputFromBinder = self.inputFromBinder
            binder.inputToBinder = self.inputToBinder
            return binder
        }()

        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            inputFromBinder.inputToBinder = inputToBinder
            inputToBinder.inputFromBinder = inputFromBinder
            outputInfoToBinder.inputFromBinder = inputFromBinder
            outputActionBinder.controllerView = view
            Observable.of(stackView.rx.didScroll,
                          inputFromBinder.view.maxButton.rx.tap,
                          rateBinder.view.arrowIV.rx.tap,
                          inputSwitchBinder.view.changeBtn.rx.tap,
                          inputFromBinder.view.selectCoinButton.rx.tap,
                          inputToBinder.view.selectCoinButton.rx.tap)
                .merge()
                .subscribe(onNext: { _ in
                    welf?.endEditing()
                }).disposed(by: resetDag)
            view.contentView.touchBeganOberver.asObserver().subscribe { _ in
                welf?.endEditing()
            }.disposed(by: resetDag)
            rateBinder.bind()
            inputFromBinder.bind()
            inputToBinder.bind()
            inputSwitchBinder.bind()
            outputPriceToBinder.bind()
            outputInfoToBinder.bind()
            outputPairPathsBinder.bind()
            outputActionBinder.bind()
            stackView.hideRows([view.pricePanelView,
                                view.outputPriceView,
                                view.outputInfoView,
                                view.outputPairPathView], animated: false)
            inputFromBinder.inputTextObserver
                .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
                .map { (type, isEditing, text) -> (AmountsType, Bool, String) in
                    let inputText = text != nil ? (text!.count > 0 ? text! : "0") : "0"
                    return (type, isEditing, inputText)
                }
                .distinctUntilChanged { $0.2 == "0" && $1.2 == "0" }
                .flatMap { (type, isEditing, text) -> Observable<(AmountsType, String, Coin, Coin, Keypair, Keypair)> in
                    if isEditing, let from = welf?.vModel.fromV.value?.token,
                        let to = welf?.vModel.toV.value?.token, let fromAccount = welf?.vModel.fromV.value?.account,
                        let toAccount = welf?.vModel.toV.value?.account,
                        (welf?.inputToBinder.isEditingObserver.value ?? false) == false
                    {
                        return Observable.just((type, text, from, to, fromAccount, toAccount))
                    }
                    return Observable.empty()
                }.flatMap { (type, amountOut, from, to, fromAccount, toAccount) -> Observable<AmountsModel> in
                    guard let this = welf else { return Observable.empty() }
                    print("out: ", amountOut)
                    if amountOut.isEmpty { return Observable.empty() }

                    return this.getAmountsFromServer(type: type, from: from, to: to, fromAccount: fromAccount, toAccount: toAccount, inputAmount: amountOut)

                }.flatMap { (model) -> Observable<AmountsModel> in
                    if welf?.inputToBinder.waitingObserver.value ?? false || (welf?.inputToBinder.isEditingObserver.value ?? false) {
                        return Observable.empty()
                    }
                    return Observable.just(model)
                }.do(onNext: { model in
                    welf?.outputPriceToBinder.valueObserver.accept(model)
                    welf?.outputInfoToBinder.valueObserver.accept(model)
                    welf?.outputPairPathsBinder.valueObserver.accept(model.path)
                    welf?.outputActionBinder.valueObserver.accept(model)
                }).map { $0.inputFormatValue }.bind(to: inputToBinder.view.inputTF.rx.text).disposed(by: defaultBag)
            inputToBinder.inputTextObserver.debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
                .map { (type, isEditing, text) -> (AmountsType, Bool, String) in
                    let inputText = text != nil ? (text!.count > 0 ? text! : "0") : "0"
                    return (type, isEditing, inputText)
                }
                .distinctUntilChanged { $0.2 == "0" && $1.2 == "0" }.flatMap { (type, isEditing, text) -> Observable<(AmountsType, String, Coin, Coin, Keypair, Keypair)> in
                    if isEditing, let from = welf?.vModel.fromV.value?.token,
                        let to = welf?.vModel.toV.value?.token, let fromAccount = welf?.vModel.fromV.value?.account,
                        let toAccount = welf?.vModel.toV.value?.account,
                        (welf?.inputFromBinder.isEditingObserver.value ?? false) == false
                    {
                        return Observable.just((type, text, from, to, fromAccount, toAccount))
                    }
                    return Observable.empty()
                }.flatMap { (type, amountOut, from, to, fromAccount, toAccount) -> Observable<AmountsModel> in
                    guard let this = welf else { return Observable.empty() }

                    return this.getAmountsFromServer(type: type, from: from, to: to, fromAccount: fromAccount, toAccount: toAccount, inputAmount: amountOut)

                }.flatMap { (model) -> Observable<AmountsModel> in
                    if welf?.inputToBinder.waitingObserver.value ?? false || (welf?.inputFromBinder.isEditingObserver.value ?? false) {
                        return Observable.empty()
                    }
                    return Observable.just(model)
                }.do(onNext: { model in
                    welf?.outputPriceToBinder.valueObserver.accept(model)
                    welf?.outputInfoToBinder.valueObserver.accept(model)
                    welf?.outputPairPathsBinder.valueObserver.accept(model.path)
                    welf?.outputActionBinder.valueObserver.accept(model)
                }).map { $0.inputFormatValue }.bind(to: inputFromBinder.view.inputTF.rx.text).disposed(by: defaultBag)
            inputFromBinder.waitingObserver.asDriver().drive(onNext: { result in
                if result { welf?.inputFromBinder.view.indicatorView.startAnimating() }
                else { welf?.inputFromBinder.view.indicatorView.stopAnimating() }
            }).disposed(by: resetDag)
            inputToBinder.waitingObserver.asDriver().drive(onNext: { result in
                if result { welf?.inputToBinder.view.indicatorView.startAnimating() }
                else { welf?.inputToBinder.view.indicatorView.stopAnimating() }
            }).disposed(by: resetDag)
            vModel.tokens.flatMap { (value) -> Observable<(Coin, Coin)> in
                if let _value = value {
                    if let fv = _value.0?.token, let tv = _value.1?.token {
                        welf?.vModel.fromV.accept(_value.0)
                        welf?.vModel.toV.accept(_value.1)
                        return Observable.just((fv, tv))
                    } else {
                        welf?.vModel.fromV.accept(_value.0)
                        welf?.vModel.toV.accept(_value.1)
                    }
                }
                return Observable.empty()
            }.flatMap { (from, to) -> Observable<[SwapViewController.Rate]> in
                guard let this = welf else { return Observable.just([]) }
                return this.vModel.getRateList(from: from, to: to).catchErrorJustReturn([])
            }.debug().subscribe(onNext: { items in
                welf?.rateBinder.itemsObserver.accept(items)
            }).disposed(by: resetDag)
            view.approveNotice.viewBtn.rx.tap.subscribe { _ in
                guard let model = welf?.view.approveNotice.model else { return }
                Router.showExplorer(model.coin, path: .hash(model.txHash))
                welf?.view.close()
            }.disposed(by: resetDag)
            view.approveNotice.closeBtn.rx.tap.subscribe { _ in
                welf?.view.close()
            }.disposed(by: resetDag)
        }

        private func getAmountsFromServer(type: AmountsType, from: Coin, to: Coin, fromAccount: Keypair, toAccount: Keypair, inputAmount: String) -> Observable<AmountsModel> {
            let tradeType = type == .out ? 0 : 1
            var fromContract = from.contract
            var toContract = to.contract
            if from.isETH {
                fromContract = SwapViewController.WETHContract
            }
            if to.isETH {
                toContract = SwapViewController.WETHContract
            }
            if inputAmount == "0" {
                return .just(AmountsModel(type, AmountsInputModel(fromAccount, from, "0", "0"), AmountsInputModel(toAccount, to, inputAmount, "0"), []))
            }
            weak var welf = self
            if type == .out {
                vModel.startFrom = true
                inputToBinder.waitingObserver.accept(true)
            } else {
                vModel.startFrom = false
                inputFromBinder.waitingObserver.accept(true)
            }
            return FxAPIManager.fx.swapBestTrade(amount: inputAmount, currencyInput: fromContract, currencyOut: toContract, tradeType: tradeType).debug()
                .map { (json) -> AmountsModel in
                    if let array = json.array, array.count > 0 {
                        let model = array[0]
                        let amountOut = model["amountOut"].stringValue
                        let amountIn = model["amountIn"].stringValue
                        var paths = [String]()
                        if let pathArray = model["path"].array {
                            for pathJson in pathArray {
                                let path = pathJson["contract"].stringValue
                                paths.append(path)
                            }
                        }
                        let from = SwapViewController.AmountsInputModel(fromAccount, from, amountIn, amountIn.mul10(from.decimal))
                        let to = SwapViewController.AmountsInputModel(toAccount, to, amountOut, amountOut.mul10(to.decimal))
                        var rs = AmountsModel(type, from, to, paths)
                        rs.priceImpact = model["priceImpact"].stringValue
                        rs.liquidityfee = model["liquidityProviderFee"].stringValue
                        print(rs.description)
                        return rs
                    } else {
                        return AmountsModel(type, AmountsInputModel(fromAccount, from, "0", "0"), AmountsInputModel(toAccount, to, inputAmount, "0"), [])
                    }
                }
                .catchError { (error) -> Observable<SwapViewController.AmountsModel> in
                    let _error = error as NSError
                    welf?.view.hud?.error(m: _error.domain)
                    let null = AmountsModel(type, AmountsInputModel(fromAccount, from, "0", "0"), AmountsInputModel(toAccount, to, inputAmount, "0"), [])
                    return .just(null)
                }

                .do(onNext: { _ in
                    welf?.inputFromBinder.waitingObserver.accept(false)
                    welf?.inputToBinder.waitingObserver.accept(false)
                })
        }

        private func getAmounts(type: AmountsType, from: Coin, to: Coin, fromAccount: Keypair, toAccount: Keypair, inputAmount: String) -> Observable<AmountsModel> {
            weak var welf = self
            switch type {
            case .in:
                let inputAmountBig = inputAmount.mul10(to.decimal)
                inputFromBinder.waitingObserver.accept(true)
                return UniswapV2.Router02.getAmountsIn(amountOut: inputAmountBig,
                                                       fromToken: from,
                                                       toToken: to)
                    .map { (path, value) -> ([String], String, String, String) in
                        let result_mul = value.mul(String(1 - 0.005), 0)
                        let scl = result_mul.div10(from.decimal).isLessThan(decimal: "1") ? 8 : 2
                        return (path, value.div10(from.decimal, scl), value, inputAmountBig)
                    }
                    .map {
                        AmountsModel(type, AmountsInputModel(fromAccount, from, $1, $2), AmountsInputModel(toAccount, to, inputAmount, $3), $0)
                    }
                    .catchErrorJustReturn(AmountsModel(type, AmountsInputModel(fromAccount, from, "0", "0"), AmountsInputModel(toAccount, to, inputAmount, inputAmountBig), []))
                    .do(onNext: { _ in
                        welf?.inputFromBinder.waitingObserver.accept(false)
                    })
            case .out:
                let inputAmountBig = inputAmount.mul10(from.decimal)
                inputToBinder.waitingObserver.accept(true)
                return UniswapV2.Router02.getAmountsOut(amountIn: inputAmountBig,
                                                        fromToken: from,
                                                        toToken: to)
                    .map { (path, value) -> ([String], String, String, String) in
                        let result_mul = value.mul(String(1 - 0.005), 0)
                        let scl = result_mul.div10(to.decimal).isLessThan(decimal: "1") ? 8 : 2
                        return (path, value.div10(to.decimal, scl), value, inputAmountBig)
                    }
                    .map { AmountsModel(type, AmountsInputModel(fromAccount, from, inputAmount, $3), AmountsInputModel(toAccount, to, $1, $2), $0) }
                    .catchErrorJustReturn(AmountsModel(type, AmountsInputModel(fromAccount, from, inputAmount, inputAmountBig), AmountsInputModel(toAccount, to, "0", "0"), []))
                    .do(onNext: { _ in
                        welf?.inputToBinder.waitingObserver.accept(false)
                    })
            case .null:
                welf?.inputToBinder.waitingObserver.accept(false)
                welf?.inputFromBinder.waitingObserver.accept(false)
                return Observable.empty()
            }
        }

        private func endEditing() {
            inputFromBinder.view.endEditing(true)
            inputToBinder.view.endEditing(true)
            inputFromBinder.view.inputTF.resignFirstResponder()
            inputToBinder.view.inputTF.resignFirstResponder()
        }
    }

    class RateBoothBinder: WKViewModelBinder<RateView, SwapViewModel> {
        var topSpaceView: UIView?
        var itemsObserver = BehaviorRelay<[SwapViewController.Rate]>(value: [])
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            view.arrowIV.rx.tap.asDriver().drive(onNext: { [weak self] _ in
                self?.stackView.hideRow(self!.view, animated: true)
            }).disposed(by: defaultBag)
            itemsObserver.map { $0.count < 3 }.bind(to: view.arrowIV.rx.isHidden).disposed(by: resetDag)
            itemsObserver.subscribeOn(MainScheduler.instance)
                .subscribe(onNext: { items in
                    guard let this = welf else { return }
                    if items.count > 0 {
                        if welf?.stackView.isRowHidden(this.view) ?? true {
                            if let topSpaceView = welf?.topSpaceView {
                                welf?.stackView.hideRow(topSpaceView, animated: true)
                            }
                            welf?.stackView.showRow(this.view, animated: true)
                            welf?.stackView.setInset(forRow: this.view, inset: UIEdgeInsets(top: 24.auto(), left: 0, bottom: 24.auto(), right: 0))
                            welf?.stackView.showSeparator(forRow: this.view)
                        }
                    } else {
                        if let topSpaceView = welf?.topSpaceView {
                            welf?.stackView.showRow(topSpaceView, animated: true)
                        }
                        welf?.stackView.hideRow(this.view, animated: true)
                        welf?.stackView.hideSeparator(forRow: this.view)
                    }
                    welf?.refreshItems(items: items)
                }).disposed(by: resetDag)
        }

        private func refreshItems(items: [SwapViewController.Rate]) {
            view.stackView.removeAllRows()
            let cells = items.map { (rate) -> UIView in
                RateItemView().then { view in
                    view.update(model: rate)
                    view.height(constant: 21)
                }
            }
            view.stackView.addRows(cells, animated: true)
            let height = 21.0 * CGFloat(items.count) + 10.0
            let oheight = 21.0 * CGFloat(3) + 10.0
            view.stackView.height(constant: height.auto())
            view.height(constant: 144.auto() - oheight.auto() + height.auto())
            stackView.layoutIfNeeded()
        }
    }

    class InputBinder: WKViewModelBinder<CoinView, SwapViewModel> {
        var amountsType: AmountsType { .null }
        var waitingObserver = BehaviorRelay<Bool>(value: false)
        var hasValueObserver = BehaviorRelay<Bool>(value: false)
        var inputTextObserver = BehaviorRelay<(AmountsType, Bool, String?)>(value: (.null, false, nil))
        var valueObserver: BehaviorRelay<TokenModel?>? { return nil }
        let isEditingObserver = BehaviorRelay<Bool>(value: false)
        var xBag = DisposeBag()
        var xB: Balance?
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            hasValueObserver.bind(to: view.chooseTokenButton.rx.isHidden).disposed(by: resetDag)
            hasValueObserver.map { $0 == false }.bind(to: view.maxButton.rx.isHidden).disposed(by: resetDag)
            let textObserver: (String?, Bool) -> (AmountsType, Bool, String?) = { text, isEditing in
                let number = NSDecimalNumber(string: text)
                let type = welf?.amountsType ?? .out
                if number == NSDecimalNumber.notANumber {
                    return (type, isEditing, "0")
                } else {
                    return (type, isEditing, number.description)
                }
            }
            view.inputTF.rx.observe(String.self, "text").map { ($0, false) }.map(textObserver).bind(to: inputTextObserver).disposed(by: resetDag)
            view.inputTF.rx.text.orEmpty.changed.map { ($0, true) }.map(textObserver).bind(to: inputTextObserver).disposed(by: resetDag)
            valueObserver?.subscribe(onNext: { [weak self] t in
                guard let token = t?.token, let account = t?.account else {
                    self?.hasValueObserver.accept(false)
                    self?.view.balanceLabel.text = "-"
                    return
                }
                self?.hasValueObserver.accept(true)
                self?.view.tokenIV.setImage(urlString: token.imgUrl,
                                            placeHolderImage: token.imgPlaceholder)
                self?.view.tokenLabel.text = token.token
                self?.xBag = DisposeBag()
                self?.xB = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                self?.xB!.value.asDriver()
                    .drive(onNext: { value in
                        let scl = value.div10(token.decimal).isLessThan(decimal: "1") ? 8 : 2
                        let balanceTitle = value.div10(token.decimal, scl).thousandth(8, mb: true)
                        self?.view.balanceLabel.text = TR("Balance: %@", balanceTitle)

                    }).disposed(by: welf!.xBag)
            }).disposed(by: resetDag)
            let inputContentView = view.inputContentView
            let inputTextView = view.inputTF
            view.inputTF.rx.controlEvent([.editingDidBegin])
                .observeOn(MainScheduler.instance)
                .do(afterNext: { _ in
                    inputContentView.borderColor = HDA(0x0552DC)
                    inputContentView.snp.remakeConstraints { make in
                        make.left.equalTo(10.auto())
                        make.bottom.equalToSuperview().offset(-10.auto())
                        make.height.equalTo(39.auto())
                        make.right.equalToSuperview().inset(10.auto())
                    }
                    inputTextView.snp.remakeConstraints { make in
                        make.edges.equalTo(inputContentView).inset(UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12))
                    }
                    UIView.animate(withDuration: 0.25) {
                        welf?.view.layoutIfNeeded()
                    }
                }).map { (_) -> Bool in true }
                .bind(to: isEditingObserver)
                .disposed(by: resetDag)
            view.inputTF.rx.controlEvent([.editingDidEnd])
                .observeOn(MainScheduler.instance)
                .do(afterNext: { _ in
                    inputContentView.borderColor = .clear
                    inputContentView.snp.remakeConstraints { make in
                        make.left.equalTo(10.auto())
                        make.bottom.equalToSuperview().offset(-10.auto())
                        make.height.equalTo(39.auto())
                        make.width.equalToSuperview().multipliedBy(0.4)
                    }
                    inputTextView.snp.remakeConstraints { make in
                        make.edges.equalTo(inputContentView).inset(UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8))
                    }
                    UIView.animate(withDuration: 0.25) {
                        welf?.view.layoutIfNeeded()
                    }
                }).map { (_) -> Bool in false }
                .bind(to: isEditingObserver)
                .disposed(by: resetDag)
        }
    }

    class InputFromBinder: InputBinder {
        let mobilityScale: Double = 0.003
        override var amountsType: SwapViewController.AmountsType { return .out }
        var inputToBinder: InputToBinder?
        override var valueObserver: BehaviorRelay<TokenModel?>? {
            return self.vModel.fromV
        }

        override func bind() {
            super.bind()
            weak var welf = self
            let mobilityScale = self.mobilityScale
            view.maxButton.rx.tap.subscribe(onNext: { _ in
                guard let tmodel = welf?.vModel?.fromV.value,
                    let token = tmodel.token, let account = tmodel.account else { return }
                let balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                let maxValue = balance.value.value.div10(token.decimal)
                let mobilityValue = balance.value.value.mul(String(mobilityScale)).div10(token.decimal, 8)
                let inputValue = maxValue.sub(mobilityValue, 8)
                welf?.view.inputTF.text = inputValue
                welf?.inputTextObserver.accept((.out, true, inputValue))
            }).disposed(by: resetDag)
            vModel.fromV.filterNil().flatMap { (_) -> Observable<(AmountsType, BehaviorRelay<(AmountsType, Bool, String?)>)> in
                if let _ = welf?.vModel.toV.value?.token,
                    let fObserver = welf?.inputTextObserver,
                    let tObserver = welf?.inputToBinder?.inputTextObserver
                {
                    let toInputValue = tObserver.value.2 != nil ? (tObserver.value.2!.count > 0 ? tObserver.value.2! : "0") : "0"
                    if toInputValue != "0" {
                        return Observable.just((.in, tObserver))
                    }
                    return Observable.just((.out, fObserver))
                } else {
                    return Observable.empty()
                }
            }
            .subscribe(onNext: { type, behavior in
                let value = behavior.value
                behavior.accept((type, true, value.2))
            })
            .disposed(by: resetDag)
            view.selectCoinButton.rx.tap.subscribe { _ in
                guard let vmodel = welf?.vModel else { return }
                Router.showSelectAccount(wallet: vmodel.wallet, current: nil,
                                         filter: { (coin, _) -> Bool in

                                             if let currentToken = welf?.vModel.fromV.value?.token {
                                                 return coin.id != currentToken.id
                                             } else {
                                                 return true
                                             }
                                         }) { vc, coin, account in
                    let rs = TokenModel(token: coin, account: account)
                    if let toV = welf?.vModel.toV.value, let toToken = toV.token, let toAccount = toV.account {
                        if toToken.symbol == rs.token!.symbol, toAccount.address == rs.account!.address {
                            welf?.vModel.tokens.accept((rs, welf?.vModel.fromV.value))
                        } else {
                            welf?.vModel.tokens.accept((rs, toV))
                        }
                    } else {
                        welf?.vModel.tokens.accept((rs, welf?.vModel.toV.value))
                    }
                    Router.dismiss(vc)
                }
            }.disposed(by: resetDag)
        }
    }

    class InputToBinder: InputBinder {
        override var amountsType: SwapViewController.AmountsType { return .in }
        var inputFromBinder: InputFromBinder?
        override var valueObserver: BehaviorRelay<TokenModel?>? {
            return self.vModel.toV
        }

        override func bind() {
            super.bind()
            weak var welf = self
            view.selectCoinButton.rx.tap.subscribe { _ in

                guard let vmodel = welf?.vModel else { return }
                Router.showSelectAccount(wallet: vmodel.wallet, current: nil,
                                         filter: { (coin, _) -> Bool in

                                             if let currentToken = welf?.vModel.toV.value?.token {
                                                 return coin.id != currentToken.id
                                             } else {
                                                 return true
                                             }
                                         }) { vc, coin, account in
                    let rs = TokenModel(token: coin, account: account)
                    if let fV = welf?.vModel.fromV.value, let fToken = fV.token, let fAccount = fV.account {
                        if fToken.symbol == rs.token!.symbol, fAccount.address == rs.account!.address {
                            welf?.vModel.tokens.accept((welf?.vModel.toV.value, rs))
                        } else {
                            welf?.vModel.tokens.accept((fV, rs))
                        }
                    } else {
                        welf?.vModel.tokens.accept((welf?.vModel.fromV.value, rs))
                    }
                    Router.dismiss(vc)
                }
            }.disposed(by: resetDag)
            vModel.toV.filterNil().flatMap { (_) -> Observable<(AmountsType, BehaviorRelay<(AmountsType, Bool, String?)>)> in
                if let _ = welf?.vModel.fromV.value?.token,
                    let tObserver = welf?.inputTextObserver,
                    let fObserver = welf?.inputFromBinder?.inputTextObserver
                {
                    let fromInputValue = fObserver.value.2 != nil ? (fObserver.value.2!.count > 0 ? fObserver.value.2! : "0") : "0"
                    if fromInputValue != "0" {
                        return Observable.just((.out, fObserver))
                    }
                    return Observable.just((.in, tObserver))
                } else {
                    return Observable.empty()
                }
            }
            .subscribe(onNext: { type, behavior in
                let value = behavior.value
                behavior.accept((type, true, value.2))
            })
            .disposed(by: resetDag)
        }
    }

    class InputSwitchBinder: WKViewModelBinder<SwapChangeView, SwapViewModel> {
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            view.changeBtn.isEnabled = true
            view.changeBtn.rx.tap.subscribe { _ in
                guard let vmodel = welf?.vModel else { return }
                welf?.vModel.tokens.accept((vmodel.toV.value, vmodel.fromV.value))
                if vmodel.startFrom {
                    let fromInputValue = welf?.inputFromBinder?.view.inputTF.text
                    welf?.inputToBinder?.view.inputTF.text = fromInputValue
                    welf?.inputFromBinder?.view.inputTF.text = ""
                    welf?.inputToBinder?.inputTextObserver.accept((.in, true, fromInputValue))
                } else {
                    let toInputValue = welf?.inputToBinder?.view.inputTF.text
                    welf?.inputFromBinder?.view.inputTF.text = toInputValue
                    welf?.inputToBinder?.view.inputTF.text = ""
                    welf?.inputFromBinder?.inputTextObserver.accept((.out, true, toInputValue))
                }
            }.disposed(by: resetDag)
        }
    }

    class OutputPriceBinder: WKViewModelBinder<PriceView, SwapViewModel> {
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        var valueObserver = BehaviorRelay<AmountsModel?>(value: nil)
        let refershObserver = BehaviorRelay<Bool>(value: false)
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            valueObserver.filterNil().observeOn(MainScheduler.instance)
                .do(onNext: { model in
                    guard let this = welf else { return }
                    if model.from.inputValue == NSDecimalNumber.zero.stringValue || model.to.inputValue == NSDecimalNumber.zero.stringValue {
                        welf?.stackView.hideRow(this.view, animated: true)
                        welf?.stackView.hideSeparator(forRow: this.view)
                    } else {
                        if welf?.stackView.isRowHidden(this.view) ?? true {
                            welf?.stackView.showRow(this.view, animated: true)
                            welf?.stackView.showSeparator(forRow: this.view)
                        }
                    }
                })
                .map { (model) -> String in
                    if model.from.inputValue == NSDecimalNumber.zero.stringValue || model.to.inputValue == NSDecimalNumber.zero.stringValue { return "--" }
                    if welf?.refershObserver.value ?? false {
                        return String(format: "%@ %@ per %@",
                                      model.to.inputValue.div(model.from.inputValue).thousandth(), model.to.token.symbol, model.from.token.symbol)
                    } else {
                        return String(format: "%@ %@ per %@",
                                      model.from.inputValue.div(model.to.inputValue).thousandth(), model.from.token.symbol, model.to.token.symbol)
                    }
                }.bind(to: view.subTitleLabel.rx.text).disposed(by: resetDag)
            view.refeshBtn.rx.tap.asDriver().drive(onNext: { _ in
                let statue = welf?.refershObserver.value ?? false
                welf?.refershObserver.accept(!statue)
                let value = welf?.valueObserver.value
                welf?.valueObserver.accept(value)
            }).disposed(by: resetDag)
        }
    }

    class OutputInfoBinder: WKViewModelBinder<FeePannel, SwapViewModel> {
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        var valueObserver = BehaviorRelay<AmountsModel?>(value: nil)
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            view.maxSold.titleLabel.text = TR("Maxmum sold")
            view.priceImpact.titleLabel.text = TR("Price Impact")
            view.providerFee.titleLabel.text = TR("Liquidity Provider Fee")
            valueObserver.asDriver()
                .filterNil().do(onNext: { model in
                    guard let this = welf else { return }
                    if model.from.inputValue == NSDecimalNumber.zero.stringValue || model.to.inputValue == NSDecimalNumber.zero.stringValue {
                        welf?.stackView.hideRow(this.view, animated: true)
                        welf?.stackView.hideSeparator(forRow: this.view)
                    } else {
                        if welf?.stackView.isRowHidden(this.view) ?? true {
                            welf?.stackView.showRow(this.view, animated: true)
                            welf?.stackView.showSeparator(forRow: this.view)
                        }
                    }
                })
                .drive(onNext: { model in
                    switch model.amountsType {
                    case .in:
                        welf?.view.maxSold.titleLabel.text = TR("Maxmum sold")
                        welf?.view.soldValue.text = "\(model.maxValue.thousandth()) \(model.from.token.symbol)"
                    case .out:
                        welf?.view.maxSold.titleLabel.text = TR("Minimum received")
                        welf?.view.soldValue.text = "\(model.minValue.thousandth()) \(model.to.token.symbol)"
                    case .null:
                        break
                    }
                    welf?.view.priceImpact.subTitleLabel.text = model.priceImpact.thousandth(2) + "%"
                    if model.priceImpact.isLessThan(decimal: "0.01") {
                        welf?.view.priceImpact.subTitleLabel.textColor = RGB(36, 163, 78)
                        welf?.view.priceImpact.subTitleLabel.text = "<0.01%"
                    } else if model.priceImpact.isLessThan(decimal: "3") {
                        welf?.view.priceImpact.subTitleLabel.textColor = UIColor.black
                    } else {
                        welf?.view.priceImpact.subTitleLabel.textColor = RGB(251, 79, 94)
                    }
                    if let mobilityScale = welf?.inputFromBinder?.mobilityScale {
                        let mobilityValue = model.from.inputValue.mul(String(mobilityScale)).div(String(1.0 - mobilityScale), 4)
                        welf?.view.providerValue.text = "\(mobilityValue) \(model.from.token.symbol)"
                    } else {
                        welf?.view.providerValue.text = "--"
                    }
                }).disposed(by: resetDag)
        }
    }

    class OutputPairPathsBinder: WKViewModelBinder<RounterView, SwapViewModel> {
        var valueObserver = BehaviorRelay<[String]>(value: [])
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            valueObserver.asObservable().flatMap { (paths) -> Observable<[RouterModel]> in
                do {
                    let request = try paths.map { (address) -> Observable<RouterModel> in
                        if let eAddress = EthereumAddress(hexString: address) {
                            return UniswapV2Cache.Tokens.select(with: address).flatMap { (token) -> Observable<UniswapV2Token> in
                                if let _token = token { return Observable.just(_token) }
                                return UniswapV2Cache.Tokens.synchronize(token: address).flatMap { (token) -> Observable<UniswapV2Token> in
                                    UniswapV2Cache.Tokens.insertOrReplace([token]).map { (_) -> UniswapV2Token in
                                        token
                                    }.catchErrorJustReturn(token)
                                }
                            }.map { (token) -> RouterModel in
                                RouterModel(address: eAddress, token: token.symbol)
                            }
                        }
                        throw NSError(domain: TR("Swap.Error.Address"), code: 0, userInfo: nil)
                    }
                    return Observable.combineLatest(request)
                } catch {
                    return Observable.empty()
                }
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { paths in
                guard let this = welf else { return }
                if paths.count > 2 {
                    let height = RounterView.height(model: paths)
                    this.view.height(constant: height)
                    welf?.stackView.layoutIfNeeded()
                    welf?.stackView.showRow(this.view, animated: true)
                    welf?.stackView.setInset(forRow: this.view, inset: UIEdgeInsets(top: 24.auto(), left: 0, bottom: 24.auto(), right: 0))
                    welf?.stackView.showSeparator(forRow: this.view)
                } else {
                    welf?.stackView.hideRow(this.view, animated: true)
                    welf?.stackView.hideSeparator(forRow: this.view)
                }
            }).subscribe(onNext: { paths in
                welf?.view.bindRouter(tags: paths)
            }).disposed(by: resetDag)
        }
    }

    class OutputActionBinder: WKViewModelBinder<ApprovePanel, SwapViewModel> {
        var controllerView: View?
        let retryDelay = RxTimeInterval.seconds(2)
        let maxRetryCount: Int = 4
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        let valueObserver = BehaviorRelay<AmountsModel?>(value: nil)
        let approveStatusObserver = BehaviorRelay<(SwapViewModel.ApproveState, String)>(value: (.normal, ""))
        let approveWaitingObserver = BehaviorRelay<(AmountsValue, Bool)?>(value: nil)
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            welf?.setNeedApprove(approve: false, animate: false)
            welf?.view.alpha = 0
            valueObserver.filterNil()
                .observeOn(MainScheduler.instance)
                .do(onNext: { model in
                    let isZero: Bool = (model.from.inputValue == NSDecimalNumber.zero.stringValue || model.to.inputValue == NSDecimalNumber.zero.stringValue)
                    welf?.view.alpha = isZero ? 0 : 1
                })
                .flatMap { (model) -> Observable<AmountsModel> in

                    if let balance = XWallet.currentWallet?.wk.balance(of: model.from.account.address,
                                                                       coin: model.from.token),
                        let mobilityScale = welf?.inputFromBinder?.mobilityScale
                    {
                        let maxValue = balance.value.value.div10(model.from.token.decimal)
                        let mobilityValue = balance.value.value.mul(String(mobilityScale)).div10(model.from.token.decimal, 8)
                        let inputValue = maxValue.sub(mobilityValue, 8)
                        let balanceBigValue = BigInt(inputValue.mul10(model.from.token.decimal)) ?? BigInt(0)
                        let userInputBigValue = BigInt(model.from.inputBigValue) ?? BigInt(0)
                        if userInputBigValue > balanceBigValue {
                            welf?.approveStatusObserver.accept((SwapViewModel.ApproveState.onEnough,
                                                                TR("Swap.Insufficient.Balance", model.from.token.symbol)))
                            return Observable.empty()
                        }
                    }
                    return Observable.just(model)
                }
                .flatMap { (model) -> Observable<(BigInt, BigInt)> in
                    let inputBig = BigInt(model.from.inputBigValue) ?? BigInt(0)
                    let tokenAddress = model.from.token.contract
                    let tokenContract = model.from.account.address
                    if let fromToke = welf?.vModel.fromV.value?.token, fromToke.isETH {
                        return Observable.just((inputBig + AmountsValue(model.amountsInput.token, "100").bigValue, inputBig))
                    }
                    if inputBig == 0 { return Observable.just((BigInt(0), inputBig)) }
                    return UniswapV2.Router02.allowance(tokenContract, tokenAddress).debug().map { (reslut) -> (BigInt, BigInt) in
                        (BigInt(reslut) ?? BigInt(0), inputBig)

                    }.catchErrorJustReturn((BigInt(0), inputBig))
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { reslut, inputBig in
                    guard let _ = welf else { return }
                    let needApprove: Bool = (reslut == 0 || reslut < inputBig)
                    welf?.setNeedApprove(approve: needApprove, animate: true)
                }).map { (reslut, output) -> (SwapViewModel.ApproveState, String) in
                    if output == 0 { return (.disable, "") }
                    if reslut == 0 || reslut < output { return (.normal, "") }
                    else { return (.completed, "") }
                }.map { (reslut, output) -> (SwapViewModel.ApproveState, String) in
                    if let model = welf?.valueObserver.value, model.priceImpact.isGreaterThan(decimal: "15") {
                        return (.slidingPoint, TR("Swap.Sliding"))
                    }
                    return (reslut, output)
                }.bind(to: approveStatusObserver)
                .disposed(by: resetDag)
            approveStatusObserver.asDriver().drive(onNext: { state, message in
                guard let this = welf else { return }
                this.view.approveButton.isHidden = false
                this.view.swapButton.isHidden = false
                this.view.messageButton.isHidden = true
                this.view.approveButton.isUserInteractionEnabled = true
                this.view.approveButton.indexView.setTitle("1", for: .normal)
                this.view.approveButton.indexView.setImage(nil, for: .disabled)
                this.view.isComplated = false
                switch state {
                case .normal:
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.set(title: TR("Button.Approve"), enable: true)
                    this.view.swapButton.set(title: TR("Button.Swap"), enable: false)
                    this.view.layoutSubviews()
                case .refresh:
                    this.stackView.endEditing(false)
                    this.stackView.isUserInteractionEnabled = false
                    this.view.approveButton.set(title: TR("Swap.Button.Approving"), enable: true, waiting: true)
                    this.view.approveButton.isUserInteractionEnabled = false
                    this.view.swapButton.set(title: TR("Button.Swap"), enable: false)
                    this.view.layoutSubviews()
                case .completed:
                    this.view.isComplated = true
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.set(title: TR("Button.Approve"), enable: false)
                    this.view.approveButton.indexView.setTitle("", for: .normal)
                    this.view.approveButton.indexView.setImage(IMG("Swap.Finish"), for: .disabled)
                    this.view.swapButton.set(title: TR("Button.Swap"), enable: true)
                    this.view.layoutSubviews()
                case .disable:
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.set(title: TR("Button.Approve"), enable: false)
                    this.view.swapButton.set(title: TR("Button.Swap"), enable: false)
                    this.view.layoutSubviews()
                case .onEnough:
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.isHidden = true
                    this.view.swapButton.isHidden = true
                    this.view.messageButton.isHidden = false
                    this.view.messageButton.set(title: message, enable: false)
                    this.view.layoutSubviews()
                case .slidingPoint:
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.isHidden = true
                    this.view.swapButton.isHidden = true
                    this.view.messageButton.isHidden = false
                    this.view.messageButton.set(title: message, enable: false)
                    this.view.layoutSubviews()
                }
            }).disposed(by: resetDag)
            let approveMaxRetryCount: Int = maxRetryCount
            let approveRetryDelay: RxTimeInterval = retryDelay
            approveWaitingObserver.filterNil()
                .map { (inputValue, isWaiting) -> (AmountsValue, SwapViewModel.ApproveState) in
                    (inputValue, isWaiting ? .refresh : .normal)
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { _, status in
                    welf?.approveStatusObserver.accept((status, ""))
                })
                .flatMap { (inputValue, status) -> Observable<(Bool, BigInt)> in
                    if status == .refresh {
                        guard let wallet = welf?.vModel.fromV.value,
                            let tokenAddress = wallet.token?.contract,
                            let tokenContract = wallet.account?.address else { return Observable.just((false, BigInt(0))) }
                        return UniswapV2.Router02.allowance(tokenContract, tokenAddress)
                            .timeout(.seconds(30), scheduler: MainScheduler.instance)
                            .flatMap { (reslut) -> Observable<(Bool, BigInt)> in
                                let outputAmount = BigInt(reslut) ?? BigInt(0)
                                if outputAmount >= inputValue.bigValue {
                                    return Observable.just((true, outputAmount))
                                } else {
                                    return Observable.error(NSError(domain: "0", code: 0, userInfo: ["allowance": outputAmount]))
                                }
                            }.retryWhen { (rxError) -> Observable<Int> in
                                rxError.enumerated().flatMap { (index, element) -> Observable<Int> in
                                    if index >= approveMaxRetryCount {
                                        let allowance = (element as NSError).userInfo
                                        return Observable.error(NSError(domain: TR("Swap.Error.Approve.Retry"), code: 0, userInfo: allowance))
                                    }
                                    return Observable.interval(approveRetryDelay, scheduler: MainScheduler.instance)
                                }
                            }
                            .catchError { (error) -> Observable<(Bool, BigInt)> in
                                let allowance = ((error as NSError).userInfo["allowance"] as? BigInt) ?? BigInt(0)
                                return Observable.just((false, allowance))
                            }
                    }
                    return Observable.just((false, BigInt(0)))
                }
                .do(onNext: { _, allowancBig in
                    if allowancBig > 0, let from = welf?.vModel.fromV.value?.token,
                        let superview = welf?.controllerView,
                        let model = welf?.vModel.approvedList.value.get(from.symbol)
                    {
                        let userSetAllowancBig = BigInt(model.amount) ?? BigInt(0)
                        if allowancBig >= userSetAllowancBig {
                            DispatchQueue.main.async {
                                superview.showNotice(model)
                                welf?.vModel.approvedList.value.remove(from.symbol)
                            }
                        }
                    }
                }).subscribe(onNext: { result, _ in
                    welf?.approveStatusObserver.accept((result ? .completed : .normal, ""))
                }).disposed(by: resetDag)
            view.approveButton.buttonView.rx.tap.subscribe(onNext: {
                if let inputFromValue = welf?.inputFromBinder?.inputTextObserver.value.2,
                    let inputFromToken = welf?.inputFromBinder?.valueObserver?.value?.token
                {
                    let value = AmountsValue(inputFromToken, inputFromValue)
                    guard let wallet = welf?.vModel.wallet, let vm = welf?.vModel, let balance = welf?.inputFromBinder?.xB?.value.value else {
                        return
                    }
                    vm.balanceAmount.accept((balance, ""))
                    Router.pushToSwapApprove(wallet: wallet, vm: vm) { rs in guard let _rs = rs else { return }
                        if _rs.isEqual(to: WKError.success) {
                            welf?.approveWaitingObserver.accept((value, true))
                        } else {
                            welf?.approveStatusObserver.accept((.normal, ""))
                        }
                    }
                }
            }).disposed(by: resetDag)
            view.swapButton.buttonView.rx.tap.subscribe(onNext: {
                guard let wallet = welf?.vModel.wallet, let vm = welf?.vModel, let amountsMdoel = welf?.valueObserver.value else {
                    return
                }
                Router.pushToConfirmSwap(wallet: wallet, vm: vm, amountsMdoel: amountsMdoel)
            }).disposed(by: resetDag)
        }

        private func setNeedApprove(approve: Bool, animate: Bool = false) {
            let block = {
                if approve {
                    self.view.approveButton.alpha = 1
                    self.view.swapButton.indexView.alpha = 1
                    self.view.approveButton.snp.remakeConstraints { make in
                        make.left.equalToSuperview().offset(24.auto())
                        make.height.equalTo((28 + 56).auto())
                        make.centerY.equalToSuperview()
                        make.right.equalTo(self.view.snp.centerX).offset(-8.auto())
                    }
                    self.view.swapButton.snp.remakeConstraints { make in
                        make.right.equalToSuperview().offset(-24.auto())
                        make.left.equalTo(self.view.snp.centerX).offset(8.auto())
                        make.height.equalTo((28 + 56).auto())
                        make.centerY.equalToSuperview()
                    }
                } else {
                    self.view.approveButton.alpha = 0
                    self.view.swapButton.indexView.alpha = 0
                    self.view.approveButton.snp.remakeConstraints { make in
                        make.left.equalToSuperview().offset(24.auto())
                        make.height.equalTo((28 + 56).auto())
                        make.centerY.equalToSuperview()
                        make.right.equalTo(self.view.swapButton.snp.right)
                    }
                    self.view.swapButton.snp.remakeConstraints { make in
                        make.left.equalTo(self.view.approveButton.snp.left)
                        make.right.equalToSuperview().offset(-24.auto())
                        make.height.equalTo((28 + 56).auto())
                        make.centerY.equalToSuperview()
                    }
                }
            }
            if animate {
                block()
                UIView.animate(withDuration: 0.45) {
                    self.view.layoutIfNeeded()
                }
            } else {
                block()
            }
        }
    }
}
