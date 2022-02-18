//
//
//  XWallet
//
//  Created by May on 2020/12/22.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import Hero
import BigInt
import RxSwift
import RxCocoa
import SwiftyJSON
import AloeStackView
import Web3
import TrustWalletCore

extension WKWrapper where Base == OxSwapViewController {
    var view: OxSwapViewController.View { return base.view as! OxSwapViewController.View }
}

extension OxSwapViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        
        var current: (Coin, Keypair)?
        if let coin = context["currentCoin"] as? Coin,
           let account = context["currentAccount"] as? Keypair {
            current = (coin, account)
        }
        
        let vc = OxSwapViewController(wallet: wallet, current: current)
        return vc
    }
}

class OxSwapViewController: WKViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, current: (Coin, Keypair)?) {
        self.wallet = wallet
        self.viewModel = OxSwapViewModel(wallet, current: current)
        super.init(nibName: nil, bundle: nil)
    }
    
    private let wallet: WKWallet
    var viewModel: OxSwapViewModel
    override func loadView() { view = View(frame: ScreenBounds) }
    
    var hudHidding = BehaviorRelay<Bool>(value: false)
    
    lazy var contentBinder:OxSwapViewBinder = {
        return OxSwapViewBinder(stackView: self.wk.view.contentView,
                                view: self.wk.view,
                                viewModel: self.viewModel)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        contentBinder.bind()
        
        let timer = 3600 * 24
        FxAPIManager.fx.oxTokenList(expired: timer.d).subscribe().disposed(by: defaultBag)
        hudHidding.subscribe(onNext: { [weak self] (b) in
            if b {
                self?.view.hud?.waiting()
            } else {
                self?.view.hud?.hide()
            } 
        }).disposed(by: defaultBag)
        
        OxSwapModel.priceModelsCache.items.removeAll()
    }
    
    deinit {
        contentBinder.resetDag = DisposeBag()
    }
    
    override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Ox.Swap.Title"))
        navigationBar.action(.left, imageName: "ic_back_60") { [weak self] in
            Router.pop(self)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func reload() {
        contentBinder.bind()
        contentBinder.clear()
        
        if let _current = viewModel.current {
            contentBinder.vModel.fromV.accept(TokenModel(token: _current.0, account: _current.1))
        } else {
            let coin = self.wallet.preferredCoin
            let account = wallet.accounts(forCoin: coin).recommend
            
            contentBinder.vModel.fromV.accept(TokenModel(token: self.wallet.preferredCoin, account: account))
        }
    }
}


class WKViewModelBinder<T:UIView, M>: NSObject {
    var resetDag:DisposeBag = DisposeBag()
    public let stackView:AloeStackView!
    public let view:T!
    public let vModel:M!

    init(stackView:AloeStackView, view:T, viewModel:M) {
        self.view = view
        self.vModel = viewModel
        self.stackView = stackView
        super.init()

        logWhenDeinit()
    }
    func bind() { }

    deinit {
        resetDag = DisposeBag()
    }
}


extension OxSwapViewController {
    class OxSwapViewBinder: WKViewModelBinder<View, OxSwapViewModel> {
        
        lazy var inputFromBinder: InputFromBinder = {
            let binder =  InputFromBinder(stackView: self.stackView,
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
        
        lazy var outputActionBinder: OutputActionBinder = {
            let binder = OutputActionBinder(stackView: self.stackView,
                                            view: self.view.actionView,
                                            viewModel: self.vModel)
            binder.inputFromBinder = self.inputFromBinder
            binder.inputToBinder = self.inputToBinder
            return binder
        }()
        
        func clear(){
            inputToBinder.valueObserver?.accept(nil)
            vModel.tokens.accept((vModel.fromV.value, nil))
            inputFromBinder.view.inputTF.text = nil
            inputToBinder.view.inputTF.text = nil
            inputToBinder.inputTextObserver.accept((.null, false, nil))
            inputFromBinder.inputTextObserver.accept((.null, false, nil))
            outputActionBinder.setNeedApprove(approve: false, animate: false)
            outputActionBinder.approveStatusObserver.accept((.first, ""))
            
            
            guard let account = vModel.fromV.value?.account, let token = vModel.fromV.value?.token else {
                return
            }
            
            let model = AmountsModel(.out, AmountsInputModel(account, token, "0", "0"), AmountsInputModel(account, token, "0", "0"), [])
            outputActionBinder.valueObserver.accept(model)
        }
        
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            inputFromBinder.inputToBinder = self.inputToBinder
            inputToBinder.inputFromBinder = self.inputFromBinder
            
            outputActionBinder.controllerView = self.view
            
            Observable.of(stackView.rx.didScroll,
                          inputFromBinder.view.maxButton.rx.tap,
                          inputSwitchBinder.view.changeBtn.rx.tap,
                          inputFromBinder.view.selectCoinButton.rx.tap,
                          inputToBinder.view.selectCoinButton.rx.tap)
                .merge()
                .subscribe(onNext: { (_) in
                    welf?.endEditing()
                }).disposed(by: resetDag)
            
            view.contentView.touchBeganOberver.asObserver().subscribe { (_) in
                welf?.endEditing()
            }.disposed(by: resetDag)
            
            inputFromBinder.bind()
            inputToBinder.bind()
            inputSwitchBinder.bind()
            outputActionBinder.bind()
            inputToBinder.view.helpBtn.rx.tap.subscribe { (_) in
                
                guard let  value = welf?.outputActionBinder.valueObserver.value else { return }
                Router.showOxReceiveInfoToast(amountsMdoel: value)
                
            }.disposed(by: resetDag)
            
            inputFromBinder.inputTextObserver
                .debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
                .map({ (type, isEditing, text) -> (AmountsType, Bool, String) in
                    let inputText = text != nil ? (text!.count > 0 ? text! : "0")  : "0"
                    return (type, isEditing, inputText)
                })
                .distinctUntilChanged { $0.2 == "0" && $1.2 == "0" }
                .flatMap { (type, isEditing, text) -> Observable<(AmountsType, String, Coin, Coin, Keypair, Keypair)> in
                    if isEditing , let from = welf?.vModel.fromV.value?.token,
                       let to = welf?.vModel.toV.value?.token, let fromAccount = welf?.vModel.fromV.value?.account,
                       let toAccount = welf?.vModel.toV.value?.account,
                       (welf?.inputToBinder.isEditingObserver.value ?? false) == false {
                        return Observable.just((type, text, from, to, fromAccount, toAccount))
                    } else {
                        if isEditing {
                            welf?.vModel.startFrom = true
                        }
                    }
                    return Observable.empty()
                }.flatMap { (type, amountOut, from, to, fromAccount, toAccount) -> Observable<AmountsModel> in
                    guard let this = welf else { return Observable.empty() }
                    
                    if amountOut.isEmpty || amountOut == "0" {
                        this.inputToBinder.view.inputTF.text = ""
                        this.inputToBinder.loadStateObserver.accept((.normal, ""))
                        this.outputActionBinder.setNeedApprove(approve: false, animate: false)
                        return Observable.empty()
                    }
                    
                    if let v =  OxSwapModel.priceModelsCache.getFromPriceModel(fromToken: from.token, toToken: to.token, fromAmount: amountOut) {
                        return .just(v.model)
                    }
                    
                    self.outputActionBinder.view.isUserInteractionEnabled = false
                    return this.getPrices(type: type, from: from, to: to, fromAccount: fromAccount, inputAmount: amountOut)
                    
                }.flatMap { (model) -> Observable<AmountsModel> in
                    if welf?.inputToBinder.waitingObserver.value ?? false || (welf?.inputToBinder.isEditingObserver.value ?? false){
                        return Observable.empty()
                    }
                    return Observable.just(model)
                }.do(onNext: { model in
                    
                    welf?.outputActionBinder.valueObserver.accept(model)
                    if let _price = model.price?.price {
                        
                        let scl = _price.isLessThan(decimal: "1") ?  8 : 2
                        let price = "\(_price)".thousandth(decimal: scl)
                        let content = "1 \(model.from.token.symbol) = \(price) \(model.to.token.symbol)"
                        welf?.inputToBinder.loadStateObserver.accept((.completed, content))
                    }
                    
                }).map { $0.inputFormatValue }.bind(to: inputToBinder.view.inputTF.rx.text).disposed(by: defaultBag)
            
            
            inputToBinder.inputTextObserver.debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
                .map({ (type, isEditing, text) -> (AmountsType, Bool, String) in
                    let inputText = text != nil ? (text!.count > 0 ? text! : "0")  : "0"
                    return (type, isEditing, inputText)
                })
                .distinctUntilChanged { $0.2 == "0" && $1.2 == "0" }
                .flatMap { (type, isEditing, text) -> Observable<(AmountsType, String, Coin, Coin, Keypair, Keypair)> in
                    if isEditing , let from = welf?.vModel.fromV.value?.token,
                       let to = welf?.vModel.toV.value?.token, let fromAccount = welf?.vModel.fromV.value?.account,
                       let toAccount = welf?.vModel.toV.value?.account,
                       (welf?.inputFromBinder.isEditingObserver.value ?? false) == false {
                        return Observable.just((type, text, from, to, fromAccount, toAccount))
                    } else {
                        if isEditing {
                            welf?.vModel.startFrom = false
                        }
                    }
                    return Observable.empty()
                }.flatMap { (type, amountOut, from, to, fromAccount, toAccount) -> Observable<AmountsModel> in
                    guard let this = welf else { return Observable.empty() }
                    
                    if amountOut.isEmpty || amountOut == "0" {
                        this.inputFromBinder.view.inputTF.text = ""
                        this.outputActionBinder.setNeedApprove(approve: false, animate: false)
                        return Observable.empty()
                    }
                    
                    if let v =  OxSwapModel.priceModelsCache.getFromPriceModel(fromToken: from.token, toToken: to.token, fromAmount: amountOut) {
                        return .just(v.model)
                    }
                    
                    self.outputActionBinder.view.isUserInteractionEnabled = false
                    return  this.getPrices(type: type, from: from, to: to, fromAccount: fromAccount, inputAmount: amountOut)
                    
                }.flatMap { (model) -> Observable<AmountsModel> in
                    if welf?.inputToBinder.waitingObserver.value ?? false || (welf?.inputFromBinder.isEditingObserver.value ?? false){
                        return Observable.empty()
                    }
                    return Observable.just(model)
                }.do(onNext: { (model) in
                    
                    welf?.outputActionBinder.valueObserver.accept(model)
                    
                    if let price = model.price?.price {
                        let scl = price.isLessThan(decimal: "1") ?  8 : 2
                        let price = "\(price)".thousandth(decimal: scl)
                        let content = "1 \(model.to.token.symbol) = \(price) \(model.from.token.symbol)"
                        welf?.inputToBinder.loadStateObserver.accept((.completed, content))
                    }
                }).map { $0.inputFormatValue }.bind(to: inputFromBinder.view.inputTF.rx.text).disposed(by: defaultBag)
            
            
            inputFromBinder.waitingObserver.asDriver().drive(onNext: { (result) in
                if result { welf?.inputFromBinder.view.indicatorView.startAnimating() }
                else { welf?.inputFromBinder.view.indicatorView.stopAnimating()}
            }).disposed(by: resetDag)
            
            inputToBinder.waitingObserver.asDriver().drive(onNext: { (result) in
                if result { welf?.inputToBinder.view.indicatorView.startAnimating() }
                else { welf?.inputToBinder.view.indicatorView.stopAnimating()}
            }).disposed(by: resetDag)
            
            
            vModel.tokens.subscribe(onNext: { value in
                if let _value = value {
                    if let _ = _value.0?.token , let _ = _value.1?.token {
                        welf?.vModel.fromV.accept(_value.0)
                        welf?.vModel.toV.accept(_value.1)
                        
                        if let token = _value.0?.token, token.isETH {
                            welf?.outputActionBinder.setNeedApprove(approve: false, animate: true)
                            welf?.getETHFee()
                        } else {
                            welf?.inputFromBinder.view.maxButton.isEnabled = true
                        }
                    } else {
                        welf?.vModel.fromV.accept(_value.0)
                        welf?.vModel.toV.accept(_value.1)
                    }
                }
                
            }).disposed(by: resetDag)
            
            self.view.approveNotice.viewBtn.rx.tap.subscribe { (_) in
                guard let model = welf?.view.approveNotice.model else { return }
                Router.showExplorer(model.coin, path: .hash(model.txHash))
                welf?.view.close()
            }.disposed(by: resetDag)
            
            
            self.view.advancedSettings.changeBtn.rx.tap.subscribe { (_) in
                guard let wallet = welf?.vModel.wallet else { return }
                Router.pushToAdvancedSetting(wallet: wallet) { (value) in
                    
                }
            }.disposed(by: resetDag)
            
            self.view.approveNotice.closeBtn.rx.tap.subscribe { (_) in
                welf?.view.close()
            }.disposed(by: resetDag)
        }
        
        var xBag = DisposeBag()
        var xB: Balance?
        
        private func setAllowAmount(account: Keypair, token : Coin, fee: String) {
            
            if token.isETH {
                self.xBag = DisposeBag()
                self.xB = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                self.xB!.value.asDriver()
                    .drive(onNext: { [weak self] (value)  in
                        let scl = value.div10(token.decimal).isLessThan(decimal: "1") ?  8 : 2
                        let balanceTitle = value.div10(token.decimal, scl).thousandth(8, mb: true)
                        var rs =  balanceTitle.sub(fee, scl).thousandth(8, mb: true)
                        if rs.d < 0 {
                            rs = "0"
                        }
                        self?.vModel.maxEthAmount.accept(rs)
                        self?.inputFromBinder.view.balanceLabel.text = TR("Ox.MAX") + " " + rs
                        self?.inputFromBinder.view.maxButton.isEnabled = rs != "0"
                        
                    }).disposed(by: self.xBag)
            }
        }
        
        var feeBag = DisposeBag()
        private func getETHFee() {
            if let from = self.vModel.fromV.value?.token,
               let to = self.vModel.toV.value?.token,
               let fromAccount = self.vModel.fromV.value?.account {
                self.inputFromBinder.view.maxButton.isEnabled = false
                feeBag = DisposeBag()
                getPrices2(type: .out, from: from, to: to, fromAccount: fromAccount, inputAmount: "20")
                    .subscribe(onNext: {  [weak self] (model) in
                        if let price = model.price {
                            let fee = price.gasPrice.mul(price.gas).div10(Coin.ethereum.decimal)
                            self?.setAllowAmount(account: fromAccount, token: from, fee: fee)
                        }
                    }).disposed(by: feeBag)
            }
        }
        
        private func getPrices2(type:AmountsType, from:Coin, to:Coin, fromAccount: Keypair, inputAmount:String) -> Observable<AmountsModel> {
            let inputAmountBig = type == .out ? inputAmount.mul10(from.decimal) : inputAmount.mul10(to.decimal)
            let fToken =  from.isETH ? from.symbol : from.contract
            let tToken =  to.isETH ? to.symbol : to.contract
            
            weak var welf = self
            
            return  FxAPIManager.fx.oxPrice(fToken, tToken, fromType: type == .out ? 0: 1 , amount: inputAmountBig).map { (price) -> AmountsModel in
                if type == .out {
                    
                    let amountIn = price.sellAmount.div10(from.decimal)
                    let amountOut = price.buyAmount.div10(to.decimal)
                    
                    let from = OxSwapViewController.AmountsInputModel(fromAccount, from, amountIn, price.sellAmount )
                    let to = OxSwapViewController.AmountsInputModel(fromAccount, to, amountOut, price.buyAmount )
                    var rs = AmountsModel(type, from, to, [])
                    rs.price = price
                    return rs
                } else {
                    let amountOut = price.sellAmount.div10(from.decimal)
                    let amountIn = price.buyAmount.div10(to.decimal)
                    
                    let from = OxSwapViewController.AmountsInputModel(fromAccount, from, amountIn, price.sellAmount)
                    let to = OxSwapViewController.AmountsInputModel(fromAccount, to, amountOut, price.buyAmount)
                    var rs = AmountsModel(type, from, to, [])
                    rs.price = price
                    return rs
                }
            }.catchError({ (error) -> Observable<OxSwapViewController.AmountsModel> in
                let _error = error as NSError
                if let _rerror = JSON(_error.userInfo)["validationErrors"].array?.get(0) {
                    if _rerror["code"].stringValue == "1004" {
                        welf?.view.hud?.error(m: TR("Ox.Insufficient.Liquidity"))
                    } else {
                        welf?.view.hud?.error(m: TR("Ox.Transaction.Invalid"))
                    }
                }
                
                let null = AmountsModel(type, AmountsInputModel(fromAccount, from, "0", "0"), AmountsInputModel(fromAccount, to, inputAmount, "0"), [])
                return  .just(null)
            })
        }
        
        
        private func getPrices(type:AmountsType, from:Coin, to:Coin, fromAccount: Keypair, inputAmount:String) -> Observable<AmountsModel> {
            let inputAmountBig = type == .out ? inputAmount.mul10(from.decimal) : inputAmount.mul10(to.decimal)
            let fToken =  from.isETH ? from.symbol : from.contract
            let tToken =  to.isETH ? to.symbol : to.contract
            weak var welf = self
            if type == .out {
                self.vModel.startFrom = true
                self.inputToBinder.waitingObserver.accept(true)
            } else {
                self.vModel.startFrom = false
                self.inputFromBinder.waitingObserver.accept(true)
            }
            self.inputToBinder.loadStateObserver.accept((.refresh, TR("Ox.Finding.Price")))
            return  FxAPIManager.fx.oxPrice(fToken, tToken, fromType: type == .out ? 0: 1 , amount: inputAmountBig)
                .flatMap({ (price) -> Observable<Price> in
                    guard let this = welf else {return .error( NSError(0, msg: ""))}
                    let inputBinder = type == .out ? this.inputFromBinder : this.inputToBinder
                    
                    if let inputAmount = inputBinder.inputTextObserver.value.2,
                       let fcoin = inputBinder.vModel.fromV.value?.token, let tcoin = inputBinder.vModel.toV.value?.token {
                        let inputCoin = type == .out ? fcoin : tcoin
                        let gInputAmountStr = type == .out ? price.sellAmount : price.buyAmount
                        let inputAmountStr = inputAmount.mul10(inputCoin.decimal) 
                        if inputAmountStr == gInputAmountStr {
                            return .just(price)
                        }
                    } 
                    return .error( NSError(0, msg: ""))
                })
                .map { (price) -> AmountsModel in
                if type == .out {
                    
                    let amountIn = price.sellAmount.div10(from.decimal)
                    let amountOut = price.buyAmount.div10(to.decimal)
                    
                    let from = OxSwapViewController.AmountsInputModel(fromAccount, from, amountIn, price.sellAmount )
                    let to = OxSwapViewController.AmountsInputModel(fromAccount, to, amountOut, price.buyAmount )
                    var rs = AmountsModel(type, from, to, [])
                    rs.price = price
                    let priceMdoel = PriceModel(fromAmount: amountIn, toAmount: amountOut, fromToken: from.token.symbol, toToken: to.token.symbol, price: price.price, model: rs)
                    OxSwapViewModel.priceModelsCache.addPriceModel(model: priceMdoel)
                    
                    return rs
                } else {
                    let amountOut = price.sellAmount.div10(from.decimal)
                    let amountIn = price.buyAmount.div10(to.decimal)
                    
                    let from = OxSwapViewController.AmountsInputModel(fromAccount, from, amountIn, price.sellAmount)
                    let to = OxSwapViewController.AmountsInputModel(fromAccount, to, amountOut, price.buyAmount)
                    var rs = AmountsModel(type, from, to, [])
                    rs.price = price
                    
                    let priceMdoel = PriceModel(fromAmount: amountIn, toAmount: amountOut, fromToken: from.token.symbol, toToken: to.token.symbol, price: price.price, model: rs)
                    OxSwapViewModel.priceModelsCache.addPriceModel(model: priceMdoel)
                    return rs
                }
            }.catchError({ (error) -> Observable<OxSwapViewController.AmountsModel> in
                            let _error = error as NSError
                            if let _rerror = JSON(_error.userInfo)["validationErrors"].array?.get(0) {
                                if _rerror["code"].stringValue == "1004" {
                                    welf?.view.hud?.error(m: TR("Ox.Insufficient.Liquidity"))
                                } else {
                                    welf?.view.hud?.error(m: TR("Ox.Transaction.Invalid"))
                                }
                            }
                            
                            let null = AmountsModel(type, AmountsInputModel(fromAccount, from, "0", "0"), AmountsInputModel(fromAccount, to, inputAmount, "0"), [])
                            return  .just(null)               })
            .do(onNext: { (_) in
                welf?.inputFromBinder.waitingObserver.accept(false)
                welf?.inputToBinder.waitingObserver.accept(false)
                welf?.outputActionBinder.view.isUserInteractionEnabled = true
            })
        }
        
        private func endEditing() {
            self.inputFromBinder.view.endEditing(true)
            self.inputToBinder.view.endEditing(true)
            self.inputFromBinder.view.inputTF.resignFirstResponder()
            self.inputToBinder.view.inputTF.resignFirstResponder()
        }
    }
    
    
    
    class InputBinder: WKViewModelBinder<CoinView, OxSwapViewModel> {
        var amountsType:AmountsType { .null }
        var waitingObserver = BehaviorRelay<Bool>(value: false)
        var hasValueObserver = BehaviorRelay<Bool>(value: false)
        var inputTextObserver = BehaviorRelay<(AmountsType, Bool,String?)>(value: (.null, false, nil))
        var valueObserver:BehaviorRelay<TokenModel?>? { return nil }
        let isEditingObserver = BehaviorRelay<Bool>(value: false)
        
        var xBag = DisposeBag()
        var xB: Balance?
        
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            hasValueObserver.bind(to: view.chooseTokenButton.rx.isHidden).disposed(by: resetDag)
            hasValueObserver.map{ $0 == false }.bind(to: view.maxButton.rx.isHidden).disposed(by: resetDag)
            
            
            let textObserver:(String?, Bool)->(AmountsType, Bool, String?) = { text, isEditing in
                let number = NSDecimalNumber(string: text)
                let type = welf?.amountsType ?? .out
                if number == NSDecimalNumber.notANumber {
                    return (type, isEditing, "0")
                }else {
                    return (type, isEditing, number.description)
                }
            }
            
            view.inputTF.rx.observe(String.self, "text").map{ ($0, false) }.map(textObserver).bind(to: inputTextObserver).disposed(by: resetDag)
            view.inputTF.rx.text.orEmpty.changed.map{ ($0, true) }.map(textObserver).bind(to: inputTextObserver).disposed(by: resetDag)
            
            valueObserver?.subscribe(onNext: { [weak self] (t) in
                guard let token = t?.token, let account = t?.account else {
                    self?.hasValueObserver.accept(false)
                    self?.view.balanceLabel.text = "-"
                    return
                }
                
                self?.hasValueObserver.accept(true)
                self?.view.tokenIV.setImage(urlString: token.imgUrl,
                                            placeHolderImage: token.imgPlaceholder)
                self?.view.tokenLabel.text = token.token
                
                guard let  this = self else { return }
                if !this.view.isReceived {
                    if !token.isETH {
                        this.xBag = DisposeBag()
                        this.xB = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                        this.xB!.value.asDriver()
                            .drive(onNext: { (value)  in
                                let scl = value.div10(token.decimal).isLessThan(decimal: "1") ?  8 : 2
                                let balanceTitle = value.div10(token.decimal, scl).thousandth(8, mb: true)
                                
                                self?.view.balanceLabel.text = TR("Ox.MAX") + " \(balanceTitle)"//TR("Swap.EditPermission.Balance") + ": \(balanceTitle)"
                            }).disposed(by: welf!.xBag)
                    } else {
                        self?.view.balanceLabel.text = TR("Ox.MAX") + " 0"
                    }
                }
            }).disposed(by: resetDag)
            
            let inputContentView = view.inputContentView
            let inputTextView = view.inputTF
            let bottomOffset = amountsType == .in ? -50.auto() : -19.auto()
            view.inputTF.rx.controlEvent([.editingDidBegin])
                .observeOn(MainScheduler.instance)
                .do(afterNext: { (_) in
                    inputContentView.borderColor = HDA(0x0552DC)
                    inputContentView.snp.remakeConstraints { (make) in
                        make.left.equalTo(10.auto())
                        make.bottom.equalToSuperview().offset(bottomOffset)
                        make.height.equalTo(39.auto())
                        make.right.equalToSuperview().inset(10.auto())
                    }
                    inputTextView.snp.remakeConstraints { (make) in
                        make.edges.equalTo(inputContentView).inset(UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12) )
                    }
                    UIView.animate(withDuration: 0.25) {
                        welf?.view.layoutIfNeeded()
                    }
                    
                }).map { (_) -> Bool in return true }
                .bind(to: isEditingObserver)
                .disposed(by:resetDag)
            
            view.inputTF.rx.controlEvent([.editingDidEnd])
                .observeOn(MainScheduler.instance)
                .do(afterNext: { (_) in
                    inputContentView.borderColor = .clear
                    inputContentView.snp.remakeConstraints { (make) in
                        make.left.equalTo(10.auto())
                        make.bottom.equalToSuperview().offset(bottomOffset)
                        make.height.equalTo(39.auto())
                        make.width.equalToSuperview().multipliedBy(0.4)
                    }
                    inputTextView.snp.remakeConstraints { (make) in
                        make.edges.equalTo(inputContentView).inset(UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8) )
                    }
                    UIView.animate(withDuration: 0.25) {
                        welf?.view.layoutIfNeeded()
                    }
                }).map { (_) -> Bool in return false }
                .bind(to: isEditingObserver)
                .disposed(by:resetDag)
        }
    }
    
    class InputFromBinder: InputBinder {
        let mobilityScale:Double = 0.003
        override var amountsType: OxSwapViewController.AmountsType { return .out }
        
        var inputToBinder: InputToBinder?
        override var valueObserver: BehaviorRelay<TokenModel?>? {
            return self.vModel.fromV
        }
        
        override func bind() {
            super.bind()
            weak var welf = self
            let mobilityScale = self.mobilityScale
            
            view.maxButton.isEnabled = false
            
            view.maxButton.rx.tap.subscribe(onNext: { (_) in
                guard let tmodel = welf?.vModel?.fromV.value,
                      let token = tmodel.token, let account = tmodel.account else { return }
                let balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                let maxValue = balance.value.value.div10(token.decimal)
                let mobilityValue = balance.value.value.mul(String(mobilityScale)).div10(token.decimal, 8)
                var inputValue = maxValue.sub(mobilityValue, 8)
                if !token.isETH {
                    inputValue = maxValue.sub("0", 8)
                } else {
                    inputValue = welf!.vModel.maxEthAmount.value
                }
                
                welf?.view.inputTF.text = inputValue
                welf?.inputTextObserver.accept((.out, true, inputValue))
            }).disposed(by: resetDag)
            
            vModel.fromV.filterNil().flatMap { (token) -> Observable<(AmountsType,BehaviorRelay<(AmountsType, Bool,String?)>)> in
                if let _ = welf?.vModel.toV.value?.token ,
                   let fObserver = welf?.inputTextObserver,
                   let tObserver = welf?.inputToBinder?.inputTextObserver
                {
                    let _ =  tObserver.value.2 != nil ? (tObserver.value.2!.count > 0 ? tObserver.value.2! : "0")  : "0"
                    
                    guard let type = welf?.vModel.startFrom  else {
                        return Observable.empty()
                    }
                    
                    if type {
                        return Observable.just((.out, fObserver))
                    } else {
                        return Observable.just((.in, tObserver))
                    }
                }else {
                    return Observable.empty()
                }
            }
            .subscribe(onNext: { (type, behavior) in
                let value = behavior.value
                behavior.accept((type, true, value.2))
            })
            .disposed(by: resetDag)
            
            view.selectCoinButton.rx.tap.subscribe { (_) in
                
                guard let vmodel = welf?.vModel  else { return }
                Router.showSelectPayAccount(wallet: vmodel.wallet, current: nil ,
                                            filter: { (coin, _) -> Bool in
                                                if let currentToken = welf?.vModel.tokens.value?.1?.token {
                                                    return coin.symbol != currentToken.symbol
                                                } else {
                                                    return true
                                                }
                                            } ) { (vc, coin, account) in
                    
                    let  rs = TokenModel(token: coin, account: account)
                    if let toV = welf?.vModel.toV.value, let toToken = toV.token, let toAccount = toV.account {
                        
                        if  toToken.symbol == rs.token!.symbol && toAccount.address == rs.account!.address {
                            
                            welf?.vModel.tokens.accept((rs, welf?.vModel.fromV.value))
                        } else {
                            welf?.vModel.tokens.accept((rs, toV))
                        }
                    }  else {
                        welf?.vModel.tokens.accept((rs, welf?.vModel.toV.value))
                    }
                    Router.dismiss(vc)
                }
                
                
            }.disposed(by: resetDag)
        }
    }
    
    class InputToBinder: InputBinder {
        override var amountsType: OxSwapViewController.AmountsType { return .in }
        var inputFromBinder: InputFromBinder?
        let loadStateObserver = BehaviorRelay<(OxSwapViewModel.LoadState, String)>(value: (.normal, ""))
        override var valueObserver: BehaviorRelay<TokenModel?>? {
            return self.vModel.toV
        }
        
        let usdPriceObserver = BehaviorRelay<String?>(value: nil)
        
        override func bind() {
            super.bind()
            weak var welf = self
            loadStateObserver.accept((.normal, ""))
            loadStateObserver.asDriver().drive ( onNext: { (state, message) in
                guard let this = welf else { return }
                switch state {
                case .normal:
                    this.view.helpBtn.isHidden = true
                    this.view.balanceLabel.text = ""
                case .refresh:
                    this.view.balanceLabel.text = message
                    this.view.helpBtn.isHidden = true
                case .completed:
                    this.view.balanceLabel.text = message
                    this.view.helpBtn.isHidden = false
                }
            }).disposed(by: resetDag)
            
            view.selectCoinButton.rx.tap.subscribe { (_) in
                guard let vmodel = welf?.vModel else { return }
                Router.showToSelectCoin(wallet: vmodel.wallet, filterCoin: vmodel.fromV.value?.token) { (coin) in
                    
                    let  rs = TokenModel(token: coin, account: Keypair.empty)
                    if let fV = welf?.vModel.fromV.value, let fToken = fV.token, let _ = fV.account {
                        if  fToken.symbol == rs.token!.symbol {
                            welf?.vModel.tokens.accept((welf?.vModel.toV.value, rs))
                        } else {
                            welf?.vModel.tokens.accept((fV, rs))
                        }
                    }  else {
                        welf?.vModel.tokens.accept((welf?.vModel.fromV.value, rs))
                    }
                }
                
            }.disposed(by: resetDag)
            
            vModel.toV.flatMap { (model) -> Observable<Bool> in
                return .just(model != nil)
            }.bind(to: view.inputTF.rx.isEnabled).disposed(by: resetDag)
            
            vModel.toV.filterNil().flatMap { (token) -> Observable<(AmountsType,BehaviorRelay<(AmountsType, Bool,String?)>)> in
                if let _ = welf?.vModel.fromV.value?.token ,
                   let tObserver = welf?.inputTextObserver,
                   let fObserver = welf?.inputFromBinder?.inputTextObserver {
                    let _ =  fObserver.value.2 != nil ? (fObserver.value.2!.count > 0 ? fObserver.value.2! : "0")  : "0"
                    guard let type = welf?.vModel.startFrom  else {
                        return Observable.empty()
                    }
                    if type {
                        return  Observable.just((.out, fObserver))
                    } else {
                        return  Observable.just((.in, tObserver))
                    }
                }else {
                    return Observable.empty()
                }
            }
            .subscribe(onNext: { (type,behavior) in
                let value = behavior.value
                behavior.accept((type, true, value.2))
            })
            .disposed(by: resetDag)
            
            vModel.toV.flatMap { (model) -> Observable<String?> in
                if let _token = model?.token {
                    return _token.symbol.exchangeRate().value.flatMap { (rate) -> Observable<String?> in
                        if rate.isUnknown == false {
                            return .just("$\(rate.value.formattedDecimal(ThisAPP.CurrencyDecimal))")
                        }
                        return  .just(rate.value)
                    }
                }
                return .just(nil)
            }
            .bind(to: usdPriceObserver)
            .disposed(by: resetDag)
            
            usdPriceObserver.asDriver().drive ( onNext: { value in
                welf?.setHideUsdPrice(isHide: value == nil)
                welf?.oView?.usdPriceLabel.text = value
            }).disposed(by: resetDag)
        }
        
        var oView:OutputCoinView? {
            return self.view as? OutputCoinView
        }
        
        private func setHideUsdPrice(isHide:Bool) {
            if isHide == false {
                self.oView?.usdPriceLabel.isHidden = false
                self.view.inputContentView.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(-50.auto())
                }
                self.view.height(constant: 153.auto())
            }else {
                self.oView?.usdPriceLabel.isHidden = true
                self.view.inputContentView.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(-19.auto())
                }
                self.view.height(constant: 117.auto())
            }
        }
    }
    
    class InputSwitchBinder: WKViewModelBinder<SwapChangeView, OxSwapViewModel> {
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        
        override func bind() {  }
    }
    
    
    class OutputActionBinder: WKViewModelBinder<ApprovePanel, OxSwapViewModel> {
        var controllerView:View?
        let retryDelay: RxTimeInterval = RxTimeInterval.seconds(2)
        let maxRetryCount: Int = 4
        
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        let valueObserver = BehaviorRelay<AmountsModel?>(value: nil)
        let approveStatusObserver = BehaviorRelay<(OxSwapViewModel.ApproveState, String)>(value: (.normal, ""))
        let approveWaitingObserver = BehaviorRelay<(AmountsValue, Bool)?>(value: nil)
        
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            welf?.setNeedApprove(approve: false, animate: false)
            valueObserver.filterNil()
                .observeOn(MainScheduler.instance)
                .do(onNext: { (model) in
                    let isZero:Bool = (model.from.inputValue == NSDecimalNumber.zero.stringValue ||
                                        model.to.inputValue == NSDecimalNumber.zero.stringValue)
                    welf?.inputToBinder?.loadStateObserver.accept((.normal, ""))
                    if isZero {
                        welf?.approveStatusObserver.accept((.first, ""))
                    }
                })
                .flatMap({ (model) -> Observable<AmountsModel> in
                    if let balance = XWallet.currentWallet?.wk.balance(of: model.from.account.address,
                                                                       coin: model.from.token),
                       let _ = welf?.inputFromBinder?.mobilityScale
                    {
                        let maxValue = balance.value.value.div10(model.from.token.decimal)
                        let balanceBigValue:BigInt = BigInt(maxValue.mul10(model.from.token.decimal)) ?? BigInt(0)
                        let userInputBigValue:BigInt = BigInt(model.from.inputBigValue) ?? BigInt(0)
                        if userInputBigValue > balanceBigValue {
                            welf?.approveStatusObserver.accept((OxSwapViewModel.ApproveState.onEnough,
                                                                TR("SendToken.InsufficientBalance", model.from.token.symbol)))
                            return Observable.empty()
                        }
                    }
                    return Observable.just(model)
                })
                .flatMap { (model) -> Observable<(BigInt, BigInt)> in
                    let inputBig:BigInt =  BigInt(model.from.inputBigValue) ?? BigInt(0)
                    let tokenAddress = model.from.token.contract
                    let tokenContract = model.from.account.address
                    
                    if let fromToke = welf?.vModel.fromV.value?.token, fromToke.isETH {
                        return Observable.just((inputBig + AmountsValue(model.amountsInput.token, "100").bigValue, inputBig))
                    }
                    
                    if inputBig == 0 { return Observable.just((BigInt(0), inputBig)) }
                    
                    guard let allowanceTarget =  model.price?.allowanceTarget else {
                        return Observable.just( (BigInt(0), inputBig) )
                    }
                    return  OxNode.Shared.allowance(owner: tokenContract, spender: allowanceTarget, tokenContract: tokenAddress).map { (reslut) -> (BigInt, BigInt) in
                        return (BigInt(reslut) ?? BigInt(0), inputBig)
                    }.catchErrorJustReturn((BigInt(0), inputBig))
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { (reslut, inputBig) in
                    guard let _ = welf else { return }
                    let needApprove:Bool = (reslut == 0 || reslut < inputBig )
                    welf?.setNeedApprove(approve: needApprove, animate: true)
                }).map { (reslut, output) -> (OxSwapViewModel.ApproveState, String) in
                    if output == 0 { return (.disable, "") }
                    
                    if (reslut == 0 || reslut < output ) {
                        
                        return (.normal, "")
                    }
                    else {
                        guard let v = welf?.valueObserver.value else {
                            return (.normal, "")
                        }
                        
                        if v.inputValue == "0" {
                            return (.normal, "")
                        }
                        return (.completed, "")
                    }
                }.map { (reslut, output) -> (OxSwapViewModel.ApproveState, String) in
                    if let model = welf?.valueObserver.value, model.priceImpact.isGreaterThan(decimal: "15") {
                        return (.slidingPoint, TR("Swap.Sliding"))
                    }
                    return (reslut, output)
                }.bind(to: approveStatusObserver)
                .disposed(by: resetDag)
            
            approveStatusObserver.asDriver().drive ( onNext: { (state, message) in
                guard let this = welf else { return }
                
                this.view.approveButton.isUserInteractionEnabled = true
                this.view.isComplated = false
                switch state {
                case .first:
                    this.stackView.isUserInteractionEnabled = true
                    this.view.swapButton.set(title: TR("Ox.Order.Title"), enable: false, waiting: false)
                case .normal:
                    this.view.approveButton.isHidden = false
                    this.stackView.isUserInteractionEnabled = true
                    this.view.setAproveState(state)
                    this.view.layoutSubviews()
                case .refresh:
                    this.stackView.endEditing(false)
                    this.stackView.isUserInteractionEnabled = false
                    this.view.approveButton.isUserInteractionEnabled = false
                    this.view.setAproveState(state)
                    this.view.layoutSubviews()
                case .completed:
                    this.view.isComplated = true
                    this.stackView.isUserInteractionEnabled = true
                    this.view.swapButton.set(title: TR("Ox.Order.Title"), enable: true, waiting: false)
                    this.view.setAproveState(state)
                    this.view.layoutSubviews()
                case .disable:
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.set(title: TR("Button.Approve"), enable: false)
                    this.view.swapButton.set(title: TR("Ox.Button.Receive.Order"), enable: false)
                    this.view.setAproveState(state)
                    this.view.layoutSubviews()
                case .onEnough:
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.isHidden = true
                    this.view.swapStepButton.isHidden = true
                    this.view.swapButton.isHidden = false
                    this.view.swapButton.set(title: message, enable: false)
                    this.view.apporveTip.alpha = 0
                    this.view.layoutSubviews()
                case .slidingPoint:
                    
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.isHidden = true
                    this.view.swapStepButton.isHidden = true
                    this.view.swapButton.isHidden = false
                    this.view.swapButton.set(title: message, enable: false)
                    this.view.layoutSubviews()
                }
            }).disposed(by: resetDag)
            
            
            let approveMaxRetryCount:Int = self.maxRetryCount
            let approveRetryDelay: RxTimeInterval = self.retryDelay
            approveWaitingObserver.filterNil()
                .map { (inputValue, isWaiting) -> (AmountsValue, OxSwapViewModel.ApproveState) in
                    return (inputValue, isWaiting ? .refresh : .normal)
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { (_, status) in
                    welf?.approveStatusObserver.accept((status, ""))
                })
                .flatMap { (inputValue, status) -> Observable<(Bool, BigInt)> in
                    if status == .refresh {
                        guard let wallet = welf?.vModel.fromV.value,
                              let tokenAddress = wallet.token?.contract,
                              let tokenContract = wallet.account?.address,
                              let allowanceTarget = welf?.valueObserver.value?.price?.allowanceTarget else { return Observable.just((false, BigInt(0))) }
                        
                        return OxNode.Shared.allowance(owner: tokenContract, spender: allowanceTarget, tokenContract: tokenAddress)
                            .timeout(.seconds(30), scheduler: MainScheduler.instance)
                            .flatMap { (reslut) -> Observable<(Bool, BigInt)> in
                                let outputAmount = BigInt(reslut) ?? BigInt(0)
                                if outputAmount >= inputValue.bigValue  {
                                    return Observable.just((true, outputAmount))
                                }else {
                                    return Observable.error(NSError(domain: "0", code: 0, userInfo: ["allowance":outputAmount]))
                                }
                            }.retryWhen({ (rxError) -> Observable<Int> in
                                return rxError.enumerated().flatMap({ (index, element) -> Observable<Int> in
                                    if index >= approveMaxRetryCount {
                                        let allowance = (element as NSError).userInfo
                                        return Observable.error(NSError(domain: TR("Swap.Error.Approve.Retry"), code: 0, userInfo: allowance))
                                    }
                                    return Observable.interval(approveRetryDelay, scheduler: MainScheduler.instance)
                                })
                            })
                            .catchError({ (error) -> Observable<(Bool, BigInt)> in
                                let allowance = ((error as NSError).userInfo["allowance"] as? BigInt) ?? BigInt(0)
                                return Observable.just((false, allowance))
                            })
                    }
                    return Observable.just((false, BigInt(0)))
                }
                .do(onNext: { (result, allowancBig) in
                    if allowancBig > 0, let from = welf?.vModel.fromV.value?.token,
                       let superview = welf?.controllerView,
                       let model =  welf?.vModel.approvedList.value.get(from.symbol) {
                        let userSetAllowancBig = BigInt(model.amount) ?? BigInt(0)
                        if allowancBig >= userSetAllowancBig {
                            DispatchQueue.main.async {
                                superview.showNotice(model)
                                welf?.vModel.approvedList.value.remove(from.symbol)
                            }
                        }
                    }
                }).subscribe(onNext: { (result, allowanc) in
                    welf?.approveStatusObserver.accept((result ? .completed : .normal, ""))
                }).disposed(by: resetDag)
            
            view.approveButton.buttonView.rx.tap.subscribe(onNext: {
                welf?.view.approveButton.inactiveAWhile(0.3)
                
                if let inputFromValue = welf?.inputFromBinder?.inputTextObserver.value.2,
                   let inputFromToken = welf?.inputFromBinder?.valueObserver?.value?.token {
                    let value = AmountsValue(inputFromToken, inputFromValue)
                    guard let _ = welf?.vModel.wallet, let _ = welf?.vModel,
                          let _ = welf?.inputFromBinder?.xB?.value.value else {
                        return
                    }
                    welf?.approved(value)
                }
            }).disposed(by: resetDag)
            
            view.swapButton.buttonView.rx.tap.subscribe(onNext: {
                welf?.view.swapButton.inactiveAWhile(0.3)
                guard let wallet = welf?.vModel.wallet, let vm = welf?.vModel, let amountsMdoel = welf?.valueObserver.value else {
                    return
                }
                
                Router.pushToOxConfirmSwap(wallet: wallet, vm: vm, amountsMdoel: amountsMdoel)
            }).disposed(by: resetDag)
            
            view.swapStepButton.buttonView.rx.tap.subscribe(onNext: {
                welf?.view.swapButton.inactiveAWhile(0.3)
                guard let wallet = welf?.vModel.wallet, let vm = welf?.vModel, let amountsMdoel = welf?.valueObserver.value else {
                    return
                }
                Router.pushToOxConfirmSwap(wallet: wallet, vm: vm, amountsMdoel: amountsMdoel)
            }).disposed(by: resetDag)
        }
        
        func setNeedApprove(approve:Bool, animate:Bool = false) {
            weak var welf = self
            let block = {
                self.view.isAprove = approve
                let state: ApproveState = approve ? .normal : .first
                welf?.approveStatusObserver.accept((state, ""))
            }
            
            if animate {
                block()
                UIView.animate(withDuration: 0.45) {
                    self.view.height = approve ? (56 + 32 + 30).auto() : (56 + 32 ).auto()
                    self.view.layoutIfNeeded()
                }
            }else {
                block()
            }
        }
        
        private func approved(_ amountsValue: AmountsValue)  {
            
            guard let model = valueObserver.value, let  allowanceTarget = model.price?.allowanceTarget else { return }
            
            weak var welf = self
            
            let tx:EthereumTransaction? = OxNode.Shared.approveAbi(accountAddress: model.from.account.address, spender: allowanceTarget, token: model.from.token.contract)
            
            guard let txTran = tx else {
                return
            }
            
            
            guard let wallet = XWallet.currentWallet?.wk else {
                return
            }
            
            self.controllerView?.hud?.waiting()
            self.approveStatusObserver.accept((.refresh, ""))
            
            OxNode.Shared.buildEthTx(txTran, fromCoin: model.from.token, wallet: wallet.rawValue)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (tx) in
                    tx.is0xApproved = true
                    tx.fromName = model.from.token.symbol
                    
                    
                    welf?.controllerView?.hud?.hide()
                    Router.pushToSendTokenFee(tx: tx, account: model.from.account) { (error, json) in
                        let hash = json["hash"].stringValue
                        if hash.length > 0 {
                            welf?.vModel.approvedList.value.add(item: ApprovedModel(token: model.from.token.symbol, amount: "115792089237316195423570985008687907853269984665640564039457584007913129639935",
                                                                                    txHash: hash, coin: tx.coin))
                        }
                        
                        var value = false
                        if json["didRequested"].stringValue == "1" {
                            value = true
                        }
                        
                        if WKError.canceled.isEqual(to: error) {
                            if value {
                                welf?.approveWaitingObserver.accept((amountsValue, true))
                            } else {
                                welf?.approveStatusObserver.accept((.normal, ""))
                            }
                            Router.pop(to: "OxSwapViewController")
                        }
                    }
                }, onError: { (e) in
                    welf?.controllerView?.hud?.hide()
                    welf?.approveStatusObserver.accept((.normal, ""))
                    welf?.controllerView?.hud?.error(m: "\(e.asWKError().msg)")
                }).disposed(by: defaultBag)
        }
    }
}
