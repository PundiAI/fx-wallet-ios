//
//
//  XWallet
//
//  Created by 梅杰 on 2020/10/13.
//  Copyright © 2020 梅杰 All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON
import AloeStackView
import BigInt
import Web3
import TrustWalletCore
 
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
    }
    func bind() { }
    
    deinit {
        resetDag = DisposeBag()
    }
}

extension SwapViewController {
    struct AmountsValue {
        let token:Coin
        let value:String
        
        var bigValue:BigInt {
            let bValue = value.mul10(token.decimal)
            return BigInt(bValue) ?? BigInt(0)
        }
        
        func bigValue(for text:String) -> BigInt {
            let bValue = text.mul10(token.decimal)
            return BigInt(bValue) ?? BigInt(0)
        }
    }
    
    struct AmountsModel {
        let from:Coin
        let to:Coin
        let path:[String]
        let inputAmount:String
        let outputAmount:String
    }
     
    class SwapViewBinder: WKViewModelBinder<View,SwapViewModel> {
        
        lazy var rateBinder: RateBoothBinder = {
            let binder =  RateBoothBinder(stackView: self.stackView,
                                   view: self.view.pricePanelView,
                                   viewModel: self.vModel)
            binder.topSpaceView = self.view.topSpaceView
            return binder
        }()
        
        lazy var inputFromBinder: InputFromBinder = {
            return InputFromBinder(stackView: self.stackView,
                                   view: self.view.inputFromView,
                                   viewModel: self.vModel)
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
            binder.inputFromBinder = self.inputFromBinder
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
            return binder
        }()
        
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
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
                .flatMap { (isEditing, text) -> Observable<(String, Coin, Coin)> in
                if isEditing , let from = welf?.vModel.fromV.value?.token, let to = welf?.vModel.toV.value?.token {
                    return Observable.just((text ?? "0", from, to))
                }
                return Observable.empty()
            }.flatMap { (amountOut, from, to) -> Observable<AmountsModel> in
                let inputAmount =  amountOut.mul10(from.decimal)
                welf?.inputFromBinder.waitingObserver.accept(true)
                return UniswapV2.Router02.getAmountsOut(amountOut: inputAmount,
                                                        fromToken: from,
                                                        toToken: to)
                    .map { AmountsModel(from: from, to: to, path: $0, inputAmount: amountOut, outputAmount: $1) }
                    .catchErrorJustReturn(AmountsModel(from: from, to: to, path: [], inputAmount: amountOut, outputAmount: "0"))
            }.map { (result) -> (String, String, AmountsModel) in
                welf?.inputFromBinder.waitingObserver.accept(false)
                let result_mul = result.outputAmount.mul(String(1 - 0.005), 0)
                let scl = result_mul.div10(result.to.decimal).isLessThan(decimal: "1") ?  8 : 2
                let value = result.outputAmount.div10(result.to.decimal, scl)
                let minValue = result_mul.div10(result.to.decimal, scl)
                
                return (value, minValue, result)
            }.flatMap { (value, minValue, model) -> Observable<(String, String, AmountsModel)> in
                if welf?.inputToBinder.waitingObserver.value ?? false {
                    return Observable.empty()
                }
                return Observable.just((value, minValue, model))
            }.do(onNext: { (value, minValue, model) in
                welf?.outputPriceToBinder.valueObserver.accept((model.from, model.to, model.inputAmount, value))
                welf?.outputInfoToBinder.miniMumObserver.accept("\(minValue) \(model.to.symbol)")
                welf?.outputPairPathsBinder.valueObserver.accept(model.path)
                welf?.outputActionBinder.valueObserver.accept((model.from, model.to, model.inputAmount, value))
            }).map { $0.0 }.bind(to: inputToBinder.view.inputTF.rx.text).disposed(by: defaultBag)
            
            
            inputToBinder.inputTextObserver
                .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
                .flatMap { (isEditing, text) -> Observable<(String, Coin, Coin)> in
                if isEditing , let from = welf?.vModel.fromV.value?.token, let to = welf?.vModel.toV.value?.token {
                    return Observable.just((text ?? "0", from, to))
                }
                return Observable.empty()
            }.flatMap { (amountOut, from, to) -> Observable<AmountsModel> in
                let inputAmount =  amountOut.mul10(to.decimal)
                welf?.inputToBinder.waitingObserver.accept(true)
                return UniswapV2.Router02.getAmountsIn(amountIn: inputAmount,
                                                        fromToken: from,
                                                        toToken: to)
                    .map { AmountsModel(from: from, to: to, path: $0, inputAmount: amountOut, outputAmount: $1) }
                    .catchErrorJustReturn(AmountsModel(from: from, to: to, path: [], inputAmount: amountOut, outputAmount: "0"))
            }.map { (result) -> (String, String, AmountsModel) in
                welf?.inputToBinder.waitingObserver.accept(false)
                let result_mul = result.outputAmount.mul(String(1 - 0.005), 0)
                let scl = result_mul.div10(result.from.decimal).isLessThan(decimal: "1") ?  8 : 2
                let value = result.outputAmount.div10(result.from.decimal, scl)
                let minValue = result_mul.div10(result.from.decimal, scl)
                
                return (value, minValue, result)
            }.flatMap { (value, minValue, model) -> Observable<(String,String,AmountsModel)> in
                if welf?.inputFromBinder.waitingObserver.value ?? false {
                    return Observable.empty()
                }
                return Observable.just((value, minValue,model))
            }.do(onNext: { (value, minValue, model) in
                welf?.outputPriceToBinder.valueObserver.accept((model.from, model.to, model.inputAmount, value))
                welf?.outputInfoToBinder.miniMumObserver.accept("\(minValue) \(model.from.symbol)")
                welf?.outputPairPathsBinder.valueObserver.accept(model.path)
                welf?.outputActionBinder.valueObserver.accept((model.from, model.to, model.inputAmount, value))
            }).map { $0.0 }.bind(to: inputFromBinder.view.inputTF.rx.text).disposed(by: defaultBag)
            
            
            inputFromBinder.waitingObserver.asDriver().drive(onNext: { (result) in
                if result { welf?.inputToBinder.view.indicatorView.startAnimating() }
                else { welf?.inputToBinder.view.indicatorView.stopAnimating()}
            }).disposed(by: resetDag)
            
            inputToBinder.waitingObserver.asDriver().drive(onNext: { (result) in
                if result { welf?.inputFromBinder.view.indicatorView.startAnimating() }
                else { welf?.inputFromBinder.view.indicatorView.stopAnimating()}
            }).disposed(by: resetDag)
            
            Observable.combineLatest(vModel.fromV, vModel.toV)
                .flatMap { (fvalue, tvalue) -> Observable<(Coin,Coin)> in
                    if let fv = fvalue?.token , let tv = tvalue?.token {
                        return Observable.just( (fv, tv))
                    }
                    return Observable.empty()
                }.flatMap { (from, to) -> Observable<[SwapViewController.Rate]> in
                    return self.vModel.getRateList(from: from, to: to).catchErrorJustReturn([])
                }.subscribe(onNext: { items in
                    welf?.rateBinder.itemsObserver.accept(items)
                }).disposed(by: resetDag)
            
            
            outputActionBinder.view.approveButton.buttonView.rx.tap.subscribe(onNext: {
                if let inputToValue = welf?.inputToBinder.inputTextObserver.value.1,
                   let inputToToken = welf?.inputToBinder.valueObserver?.value?.token {
                    let value = AmountsValue(token: inputToToken, value: inputToValue)
                    welf?.outputActionBinder.approveWaitingObserver.accept((value, true))
                }
            }).disposed(by: resetDag)
            
            outputActionBinder.view.swapButton.buttonView.rx.tap.subscribe(onNext: {
                print("----- swapButton")
            }).disposed(by: resetDag)
        }
    }
    
    class RateBoothBinder: WKViewModelBinder<RateView, SwapViewModel> {
        var topSpaceView:UIView?
        var itemsObserver = BehaviorRelay<[SwapViewController.Rate]>(value: [])
        
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            view.arrowIV.rx.tap.asDriver().drive(onNext: {[weak self] (_) in
                self?.stackView.hideRow(self!.view, animated: true)
            }).disposed(by: defaultBag)
            
            itemsObserver.map { $0.count < 3 }.bind(to: view.arrowIV.rx.isHidden).disposed(by: resetDag) 
            itemsObserver.subscribeOn(MainScheduler.instance)
                .subscribe(onNext: { (items) in
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
                }else {
                    if let topSpaceView = welf?.topSpaceView {
                        welf?.stackView.showRow(topSpaceView, animated: true)
                    }
                    welf?.stackView.hideRow(this.view, animated: true)
                    welf?.stackView.hideSeparator(forRow: this.view)
                }
                welf?.refreshItems(items: items)
            }).disposed(by: resetDag)
        }
        
        private func refreshItems(items:[SwapViewController.Rate]) {
            view.stackView.removeAllRows()
            let cells = items.map { (rate) -> UIView in
                return RateItemView().then { (view) in
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
        var waitingObserver = BehaviorRelay<Bool>(value: false)
        var hasValueObserver = BehaviorRelay<Bool>(value: false)
        var inputTextObserver = BehaviorRelay<(Bool,String?)>(value: (false,nil))
        var valueObserver:BehaviorRelay<TokenModel?>? { return nil }
        
        override func bind() {
            resetDag = DisposeBag()
            hasValueObserver.bind(to: view.chooseTokenButton.rx.isHidden).disposed(by: resetDag)
            hasValueObserver.map{ $0 == false }.bind(to: view.maxButton.rx.isHidden).disposed(by: resetDag)
             
            view.inputTF.rx.observe(String.self, "text").map{ (false, $0) }
                .bind(to: inputTextObserver).disposed(by: resetDag)
            view.inputTF.rx.text.orEmpty.changed.map{ (true, $0) }
                .bind(to: inputTextObserver).disposed(by: resetDag)
            
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
                let balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                let scl = balance.value.value.div10(token.decimal).isLessThan(decimal: "1") ?  8 : 2
                self?.view.balanceLabel.text = TR("Balance: %@", balance.value.value.div10(token.decimal, scl).thousandth(8, mb: false))
            }).disposed(by: resetDag)
        }
    }
    
    class InputFromBinder: InputBinder {
        override var valueObserver: BehaviorRelay<TokenModel?>? {
            return self.vModel.fromV
        }
        
        override func bind() {
            super.bind()
            weak var welf = self
            view.maxButton.rx.tap.subscribe(onNext: { (_) in
                guard let tmodel = welf?.vModel?.fromV.value,
                      let token = tmodel.token, let account = tmodel.account else { return }
                let balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                let text = balance.value.value.div10(token.decimal)
                welf?.view.inputTF.text = text
                welf?.inputTextObserver.accept((true, text))
            }).disposed(by: resetDag)
            
            vModel.fromV.filterNil().flatMap { (token) -> Observable<(Bool,String?)> in
                if let _ = welf?.vModel.toV.value?.token,
                   let observer = welf?.inputTextObserver,
                   let fValue = observer.value.1, fValue.count > 0 {
                    return Observable.just(observer.value)
                }else {
                    return Observable.empty()
                }
            }.bind(to:inputTextObserver).disposed(by: resetDag)
            
            view.selectCoinButton.rx.tap.subscribe { (_) in
                guard let vmodel = welf?.vModel, let currentToken = welf?.vModel.fromV.value?.token else { return }
                Router.showSelectAccount(wallet: vmodel.wallet.wk, current: nil ,
                                         filter: { (coin, _) -> Bool in
                                            if coin.id == currentToken.id && vmodel.wallet.wk.accounts(forCoin: currentToken).addresses.count > 1 {
                                                return true
                                            }
                                            
                                            if let toToken = vmodel.toV.value?.token {
                                                return coin.id != toToken.id && coin.id != currentToken.id
                                            }
                                            
                                            return coin.id != currentToken.id
                                         } ) { (vc, coin, account) in
                    welf?.vModel.fromV.accept(TokenModel(token: coin, account: account))
                    Router.dismiss(vc)
                }
            }.disposed(by: resetDag)
        }
    }
    
    class InputToBinder: InputBinder {
        var inputFromBinder: InputFromBinder?
        
        override var valueObserver: BehaviorRelay<TokenModel?>? {
            return self.vModel.toV
        }
        
        override func bind() {
            super.bind()
            weak var welf = self
            view.selectCoinButton.rx.tap.subscribe { (_) in
                guard let vmodel = welf?.vModel, let fToken = vmodel.fromV.value?.token else { return }
                Router.showSelectAccount(wallet: vmodel.wallet.wk, current: nil ,
                                         filter: { (coin, _) -> Bool in
                                            
                                            if let tToken = welf?.vModel.toV.value?.token {
                                                return coin.id != fToken.id && coin.id != tToken.id
                                            }
                                            
                                            return coin.id != fToken.id
                                         } ) { (vc, coin, account) in
                    welf?.vModel.toV.accept(TokenModel(token: coin, account: account))
                    Router.dismiss(vc)
                }
                
            }.disposed(by: resetDag)
            
            if let inputFromBinder = self.inputFromBinder {
                vModel.toV.filterNil().flatMap { (token) -> Observable<(Bool,String?)> in
                    if let _ = welf?.vModel.fromV.value?.token,
                       let fValue = inputFromBinder.inputTextObserver.value.1, fValue.count > 0 {
                        return Observable.just(inputFromBinder.inputTextObserver.value)
                    }else {
                        return Observable.empty()
                    }
                }.bind(to: inputFromBinder.inputTextObserver).disposed(by: resetDag)
            }
        }
    }
    
    class InputSwitchBinder: WKViewModelBinder<SwapChangeView, SwapViewModel> {
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            view.changeBtn.isEnabled = false
            if let fromObserver = vModel?.fromV, let toObserver = vModel?.toV {
                Observable.combineLatest(fromObserver, toObserver).map { (fValue, tValue) -> Bool in
                    return fValue != nil && tValue != nil
                }.bind(to: view.changeBtn.rx.isEnabled).disposed(by: resetDag)
            }
             
            view.changeBtn.rx.tap.subscribe { (_) in
                guard let vmodel = welf?.vModel,
                      let fromValue = vmodel.fromV.value,
                      let toValue = vmodel.toV.value else { return }
                 
                welf?.vModel?.fromV.accept(toValue)
                welf?.vModel?.toV.accept(fromValue)
                
                let fromInputValue = welf?.inputFromBinder?.view.inputTF.text
                let toInputValue = welf?.inputToBinder?.view.inputTF.text

                welf?.inputFromBinder?.view.inputTF.text = toInputValue
                welf?.inputToBinder?.view.inputTF.text = fromInputValue
            }.disposed(by: resetDag)
        }
    }
    
    class OutputPriceBinder: WKViewModelBinder<PriceView, SwapViewModel> {
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        var valueObserver = BehaviorRelay<(from:Coin, to:Coin, inputAmount:String, outputAmount:String)?>(value: nil)
        let refershObserver:BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
 
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            
            valueObserver.asDriver()
                .filterNil()
                .map { (from, to, inputAmount, outputAmount) -> String in
                if  inputAmount == NSDecimalNumber.zero.stringValue || outputAmount == NSDecimalNumber.zero.stringValue { return "--"}
                if welf?.refershObserver.value ?? false {
                    return String(format: "%@ %@ per %@",inputAmount.div(outputAmount).thousandth(), to.symbol, from.symbol)
                }else { 
                    return String(format: "%@ %@ per %@",
                                  outputAmount.div(inputAmount).thousandth(),  from.symbol, to.symbol)
                }
                
            }.drive(onNext: { (value) in
                guard let this = welf else { return }
                welf?.view.subTitleLabel.text = value
                if welf?.stackView.isRowHidden(this.view) ?? true {
                    welf?.stackView.showRow(this.view, animated: true)
                    welf?.stackView.showSeparator(forRow: this.view)
                }
            }).disposed(by: resetDag)
            
            view.refeshBtn.rx.tap.asDriver().drive (onNext: { (_) in
                let statue = welf?.refershObserver.value ?? false
                welf?.refershObserver.accept( !statue )
                let value = welf?.valueObserver.value
                welf?.valueObserver.accept(value)
            }).disposed(by: resetDag)
        }
    }
    
    class OutputInfoBinder: WKViewModelBinder<FeePannel, SwapViewModel> {
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        let miniMumObserver = BehaviorRelay<String>(value: "")
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            view.maxSold.titleLabel.text = TR("Maxmum sold")
            view.priceImpact.titleLabel.text = TR("Price Impact")
            view.providerFee.titleLabel.text = TR("Liquidity Provider Fee")
            
            miniMumObserver.observeOn(MainScheduler.instance)
                .filterEmpty() 
                .do(onNext: { (text) in
                    guard let this = welf else { return }
                    if welf?.stackView.isRowHidden(this.view) ?? true {
                        welf?.stackView.showRow(this.view, animated: true)
                        welf?.stackView.showSeparator(forRow: this.view)
                    }
                }).bind(to: view.soldValue.rx.text).disposed(by: resetDag)
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
                                    return UniswapV2Cache.Tokens.insertOrReplace([token]).map { (_) -> UniswapV2Token in
                                        return token
                                    }.catchErrorJustReturn(token)
                                }
                            }.map { (token) -> RouterModel in
                                return RouterModel(address: eAddress, token: token.symbol)
                            }
                        }
                        throw NSError(domain: "地址错误", code: 0, userInfo: nil)
                    }
                    return Observable.combineLatest(request)
                } catch {
                    return Observable.empty()
                }
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { (paths) in
                guard let this = welf else { return }
                if paths.count > 0 , welf?.stackView.isRowHidden(this.view) ?? true {
                    let height = RounterView.height(model: paths)
                    this.view.height(constant: height)
                    welf?.stackView.layoutIfNeeded()
                    welf?.stackView.showRow(this.view, animated: true)
                    welf?.stackView.setInset(forRow: this.view, inset: UIEdgeInsets(top: 24.auto(), left: 0, bottom: 24.auto(), right: 0))
                    welf?.stackView.showSeparator(forRow: this.view)
                }
                
                if paths.count == 0 {
                    welf?.stackView.hideRow(this.view, animated: true)
                    welf?.stackView.hideSeparator(forRow: this.view)
                }
            }).subscribe(onNext:{ paths in
                welf?.view.bindRouter(tags: paths)
            }).disposed(by: resetDag)
        }
    }
    
    class OutputActionBinder: WKViewModelBinder<ApprovePanel, SwapViewModel> {
        let retryDelay: RxTimeInterval = RxTimeInterval.seconds(2)
        let maxRetryCount: Int = 4
        
        var inputFromBinder: InputFromBinder?
        var inputToBinder: InputToBinder?
        let valueObserver = BehaviorRelay<(from:Coin, to:Coin, inputAmount:String, outputAmount:String)?>(value: nil)
        let approveStatusObserver = BehaviorRelay<SwapViewModel.ApproveState>(value: .normal)
        let approveWaitingObserver = BehaviorRelay<(AmountsValue, Bool)?>(value: nil)
        
        override func bind() {
            weak var welf = self
            resetDag = DisposeBag()
            
            welf?.setNeedApprove(approve: false, animate: false)
            valueObserver.filterNil().flatMap { (from, to, input, output) -> Observable<(BigInt, BigInt)> in
                let outputBig:BigInt = BigInt(output) ?? BigInt(0)
                guard let wallet = welf?.vModel.fromV.value,
                      let tokenAddress = wallet.token?.contract,
                      let tokenContract = wallet.account?.address else { return Observable.just((BigInt(0), outputBig)) }
                if from.isETH { return Observable.just((outputBig + 100, outputBig)) }
                return UniswapV2.Router02.allowance(tokenContract, tokenAddress).map { (reslut) -> (BigInt, BigInt) in
                    return(BigInt(reslut) ?? BigInt(0), outputBig)
                }.catchErrorJustReturn((BigInt(0), outputBig))
            }.observeOn(MainScheduler.instance)
            .do(onNext: { (reslut, output) in
                guard let _ = welf else { return }
                welf?.view.transform = CGAffineTransform.identity
                //UIView.animate(withDuration: 0.5) {
                    welf?.view.layoutIfNeeded()
               // }
                let needApprove:Bool = (reslut == 0 || reslut < output )
                welf?.setNeedApprove(approve: needApprove, animate: true)
            }).map { (reslut, output) -> SwapViewModel.ApproveState in
                if (reslut == 0 || reslut < output ) { return .normal }
                else { return .completed }
            }.bind(to: approveStatusObserver)
            .disposed(by: resetDag)
            
            approveStatusObserver.asDriver().drive ( onNext: { (state) in
                guard let this = welf else { return }
                switch state {
                case .normal:
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.set(title: TR("Button.Approve"), enable: true)
                    this.view.swapButton.set(title: TR("Button.Swap"), enable: false)
                case .refresh:
                    this.stackView.endEditing(false)
                    this.stackView.isUserInteractionEnabled = false
                    this.view.approveButton.set(title: "Pinding", enable: false, waiting: true)
                    this.view.swapButton.set(title: TR("Button.Swap"), enable: false)
                case .completed:
                    this.stackView.endEditing(false)
                    this.stackView.isUserInteractionEnabled = true
                    this.view.approveButton.set(title: TR("Button.Approve"), enable: false)
                    this.view.swapButton.set(title: TR("Button.Swap"), enable: true)
                }
            }).disposed(by: resetDag)
            
             
            let approveMaxRetryCount:Int = self.maxRetryCount
            let approveRetryDelay: RxTimeInterval = self.retryDelay
            approveWaitingObserver.filterNil()
                .map { (inputValue, isWaiting) -> (AmountsValue,SwapViewModel.ApproveState) in
                return (inputValue, isWaiting ? .refresh : .normal)
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { (_, status) in
                welf?.approveStatusObserver.accept(status)
            })
            .flatMap { (inputValue, status) -> Observable<Bool> in
                if status == .refresh {
                    guard let wallet = welf?.vModel.fromV.value,
                          let tokenAddress = wallet.token?.contract,
                          let tokenContract = wallet.account?.address else { return Observable.just(false) }
                    return UniswapV2.Router02.allowance(tokenContract, tokenAddress)
                        .flatMap { (reslut) -> Observable<Bool> in
                        if let outputAmount = BigInt(reslut), outputAmount >= inputValue.bigValue  {
                            return Observable.just(true)
                        }else {
                            return Observable.error(NSError(domain: "0", code: 0, userInfo: nil))
                        }
                    }.retryWhen({ (rxError) -> Observable<Int> in
                        return rxError.enumerated().flatMap({ (index, element) -> Observable<Int> in
                            if index >= approveMaxRetryCount {
                                return Observable.error(NSError(domain: "Retry Too Many Times", code: 0, userInfo: nil))
                            }
                            return Observable.interval(approveRetryDelay, scheduler: MainScheduler.instance)
                        })
                    }).catchErrorJustReturn(false)
                }
                return Observable.just(false)
            }.do(onNext: { (result) in
                welf?.approveStatusObserver.accept(result ? .completed : .normal)
            }).subscribe(onNext: { ( result ) in
                print("----- 这里", result)
            }).disposed(by: resetDag)
        }
         
        private func setNeedApprove(approve:Bool, animate:Bool = false) {
            let block = {
                if approve {
                    self.view.approveButton.alpha = 1
                    self.view.swapButton.indexView.alpha = 1
                    self.view.approveButton.snp.remakeConstraints { (make) in
                        make.left.equalToSuperview().offset(24.auto())
                        make.height.equalTo(56.auto())
                        make.bottom.equalTo(self.view.safeAreaLayout.bottom).offset(-25.auto())
                        make.right.equalTo(self.view.snp.centerX).offset(-8.auto())
                    }
                    self.view.swapButton.snp.remakeConstraints { (make) in
                        make.right.equalToSuperview().offset(-24.auto())
                        make.left.equalTo(self.view.snp.centerX).offset(8.auto())
                        make.height.equalTo(56.auto())
                        make.bottom.equalTo(self.view.safeAreaLayout.bottom).offset(-25.auto())
                    }
                }else {
                    self.view.approveButton.alpha = 0
                    self.view.swapButton.indexView.alpha = 0
                    self.view.approveButton.snp.remakeConstraints { (make) in
                        make.left.equalToSuperview().offset(24.auto())
                        make.height.equalTo(56.auto())
                        make.bottom.equalTo(self.view.safeAreaLayout.bottom).offset(-25.auto())
                        make.right.equalTo(self.view.swapButton.snp.right)
                    }
                    self.view.swapButton.snp.remakeConstraints { (make) in
                        make.left.equalTo(self.view.approveButton.snp.left)
                        make.right.equalToSuperview().offset(-24.auto()) 
                        make.height.equalTo(56.auto())
                        make.bottom.equalTo(self.view.safeAreaLayout.bottom).offset(-25.auto())
                    }
                }
            }
            
            if animate {
                block()
                UIView.animate(withDuration: 0.45) {
                    self.view.layoutIfNeeded()
                }
            }else {
                block()
            }
        }
    }
}
