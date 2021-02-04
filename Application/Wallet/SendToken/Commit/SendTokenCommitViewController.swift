//
//  SendTokenCommitViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/10.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Web3
import WKKit
import BigInt
import RxSwift
import RxCocoa
import XChains
import FunctionX
import SwiftyJSON
import TrustWalletCore
import Hero


extension WKWrapper where Base == SendTokenCommitViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension SendTokenCommitViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let tx = context["tx"] as? FxTransaction,
            let account = context["account"] as? Keypair else { return nil }
        
        return SendTokenCommitViewController(tx: tx, wallet: wallet, account: account)
    }
}

class SendTokenCommitViewController: WKViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction, wallet: WKWallet, account: Keypair) {
        self.tx = tx
        self.wallet = wallet
        self.account = account
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    let tx: FxTransaction
    var coin: Coin { tx.coin }
    let wallet: WKWallet
    let account: Keypair
    
    private lazy var userNameBinder = UserNameListBinder(view: wk.view.searchListView)
    private lazy var recommendReceiverBinder = RecommendReceiverBinder(view: wk.view.mainListView)
    
    private lazy var isValidInput = BehaviorRelay<Bool>(value: false)
    private lazy var crossChainBinder = FxCrossChainBinder(view: wk.view)
    
    override func loadView() { self.view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()

        logWhenDeinit()

        bindCrossChain()
        bindUserNameList()
        bindRecommendList()
        
        bindInput()
        bindConfirm()
        bindKeyboard()
    }
    
    override func bindNavBar() {
        
        navigationBar.isHidden = true
        wk.view.navBar.backButton.action { [weak self] in
            self?.wk.view.showUnlock(false)
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
        
        weak var welf = self
        if tx.receiver.address.isNotEmpty {
            self.receiver = tx.receiver
            wk.view.inputTF.contentOffset = CGPoint(x: 0, y: 10)
        }
        
        wk.view.inputTF.delegate = self
        wk.view.inputTF.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { value in
            
                let text = value ?? ""
                welf?.check(input: text)
                welf?.crossChainBinder.check(address: text)
                welf?.wk.view.relayoutHeaderIfNeed()
        }).disposed(by: defaultBag)
        
        wk.view.scanButton.rx.tap.subscribe(onNext: { [weak self](_) in
            guard let this = self else { return }

            Router.pushToFxScanQRCode { (text) in

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
    
    private func bindCrossChain() {
        
        crossChainBinder.bind(tx: tx, account: account, wallet: wallet)
        crossChainBinder.isValidInput
            .filter{ $0 }
            .take(1).subscribe(onNext: { [weak self]value in
                self?.recommendReceiverBinder.bounces = false
            }).disposed(by: defaultBag)
    }

    private func bindConfirm() {

        weak var welf = self
        isValidInput
            .bind(to: wk.view.nextButton.rx.isEnabled)
            .disposed(by: defaultBag)

        wk.view.nextButton.rx.tap.subscribe(onNext: { (_) in
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
            .subscribe(onNext: { [weak self](_) in
                self?.view.endEditing(true)
        }).disposed(by: defaultBag)
    }
    
    //MARK: Network
    
    private func sendToken(to receiver: User) {
        wk.view.nextButton.inactiveAWhile()
        
        weak var welf = self
        self.hud?.waiting()
        fetchAddress(receiver)
            .flatMap{ _ in welf?.fetchFee() ?? .empty() }
            .subscribe(onNext: { (t) in
                welf?.hud?.hide()
                guard let this = welf else { return }

                let (gas, gasPrice, balance) = t
                this.tx.balance = balance
                if this.coin.isEthereum || this.coin.isFunctionX {
                    this.tx.gasLimit = gas
                    this.tx.gasPrice = gasPrice
                    this.tx.set(fee: gas.mul(gasPrice), denom: this.coin.feeSymbol)
                } else if this.coin.isBTC {
                    this.tx.set(fee: gasPrice, denom: this.coin.feeSymbol)
                }

                this.tx.adjustMaxAmountIfNeed()
                if this.tx.fee.isGreaterThan(decimal: balance) {
                    this.hud?.text(m: "no enough \(this.coin.feeSymbol) to pay fee")
                } else {
                    this.wallet.receivers(forCoin: this.coin).addOrUpdate(receiver)
                    this.wallet.accountRecord.addOrUpdate((this.coin, this.account))
                    this.pushToBroadcastTx()
                }
            }, onError: { e in
                welf?.hud?.hide()
                welf?.hud?.error(m: e.asWKError().msg)
            }).disposed(by: defaultBag)
    }
    
    private func pushToBroadcastTx() {
        if !tx.coin.isBTC {
            Router.pushToSendTokenFee(tx: tx, account: account)
        } else {
            
            Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: { (error, result) in

                if WKError.canceled.isEqual(to: error) {
                    if result.count == 0 {
                        Router.pop(to: "SendTokenInputViewController")
                    } else if Router.canPop(to: "TokenInfoViewController") {
                        Router.pop(to: "TokenInfoViewController")
                    } else {
                        Router.popToRoot()
                    }
                }
            }, completion: { _ in
                if  Router.isExistInNavigator("SendTokenInputViewController") {
                    Router.popAllButTop{ $0?.heroIdentity == "SendTokenInputViewController" }
                }
            })
        }
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
        return fetchAddress.do(onNext: { (address) in
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
            return Observable.combineLatest(node.estimatedGas(ofTx: txMsg).map{ String($0) }, fxGasPrice(), balance)
//            return node.estimatedFee(ofTx: txMsg).map{ (String($0.gas), $0.gasPrice, balance) }
        } else if coin.isEthereum {
            
            let node = EthereumNode(endpoint: coin.node.url, chainId: 0)
            var estimatedGas = Observable<String>.just("21000")
            if coin.isERC20 {
                balance = node.balance(of: account.address)
                estimatedGas = node.estimatedGasOfTx(from: tx.from, to: tx.to, amount: BigUInt(amount)!, tokenContract: coin.contract)
                    .map { $0.d < 60000 ? "60000" : $0 }
            }
            return Observable.combineLatest(estimatedGas, ethGasPrice(), balance)
        } else if coin.isBTC {
            
//            balance = .just("999999999999999999999")
            let estimatedGas = Observable<String>.just("1")
            let fee = Observable<String>.just("10")
            return Observable.combineLatest(estimatedGas, fee, balance)
        }
        return .error(WKError(.default, "fetch fee failed"))
//        return Observable.combineLatest(estimatedGas, Observable<String>.just("20".gwei), balance)
    }
    
    private func ethGasPrice() -> Observable<String> {
        return APIManager.fx.estimateGasPrice().flatMap { [weak self]v -> Observable<String> in
            
            self?.tx.mutilGasPrice = v
            return .just(self?.tx.normalGasPrice ?? "0")
        }
    }
    
    private func fxGasPrice() -> Observable<String> {
        
        let node = FxNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: nil)
        return node.gasPrice().map { [weak self](gasPrice) in
            
            self?.tx.mutilGasPrice = MutilGasPrice(["standard" : gasPrice,
                                                    "standardTime" : 180000,
                                                    "fastTime" : 60000,
                                                    "rapidTime" : 15000,
                                                    "fast" : gasPrice.mul("1.1", 0),
                                                    "rapid" : gasPrice.mul("1.2", 0)])
            return gasPrice
        }
    }
    
    //MARK: Utils
    private func check(input: String?) {
        let text = input ?? ""
        var result = text.count > 2 && text.hasPrefix("@")
        if !result {
            
            if coin.is(.ethereum) {
                result = AnyAddress.isValid(string: text, coin: .ethereum)
            } else if coin.isBTC {
                result = BitcoinAddress.isValid(address: text)
            } else if coin.isFunctionX {
                result = FunctionXAddress.isValid(string: text)
            }
        }
        isValidInput.accept(result)
    }
    
    private func inputError(_ text: String) {
        
        hud?.text(m: text)
        wk.view.showInputError()
        wk.view.nextButton.isEnabled = false
    }
}

//MARK: UITextFieldDelegate
extension SendTokenCommitViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        wk.view.isEditing = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        wk.view.isEditing = false
    }
}

/// hero
extension SendTokenCommitViewController: HeroViewControllerDelegate  {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SendTokenInputViewController", "SendTokenCommitViewController"): return animators["1"]
        case ("SendTokenCommitViewController",  "SendTokenFeeViewController"):  return animators["0"]
        default: return nil
        }
    }
    
    private func onSuspendBlock() {
        wk.view.header.hero.id = nil
        wk.view.header.hero.modifiers = nil
        wk.view.headerContentView.hero.modifiers = nil
        wk.view.backgroundView.hero.id = nil
        wk.view.backgroundView.hero.modifiers = nil
        wk.view.mainListView.hero.modifiers = nil
        wk.view.nextButton.titleLabel?.hero.modifiers = nil
        wk.view.unlockView.hero.modifiers = nil
        wk.view.mainListView.tableHeaderView?.hero.modifiers = nil
        wk.view.navBar.hero.modifiers = nil
    }
    
    private func bindHero() { 
        weak var welf = self
        let onSuspendBlock:(WKHeroAnimator)->Void  = { _ in
            welf?.onSuspendBlock()
        }
        
        let animator = WKHeroAnimator({ (_) in
            welf?.wk.view.nextButton.hero.id = "backgroundView"
            welf?.wk.view.nextButton.titleLabel?.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.nextButton.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.unlockView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.mainListView.hero.modifiers = [.useGlobalCoordinateSpace,
                                                         .useOptimizedSnapshot,
                                                         .translate(y: 1000)]
            
            welf?.wk.view.header.hero.id = "backgroundView_white"  
            welf?.wk.view.headerContentView.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
        animators["0"] = animator
        
        let animator1 = WKHeroAnimator({ (_) in
            welf?.wk.view.unlockView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.navBar.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:-1000)]
            welf?.wk.view.headerContentView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:-1000)]
            welf?.wk.view.header.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:-1000)]
            welf?.wk.view.mainListView.tableHeaderView?.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y:-1000)]
            welf?.wk.view.mainListView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 1000)]
        }, onSuspend: onSuspendBlock)
        animators["1"] = animator1
    }
    
    func heroWillStartAnimatingTo(viewController: UIViewController) {
        if let vc = viewController as? SendTokenFeeViewController, vc.heroType != 0 {
            onSuspendBlock()
        }
    }
    
    func heroWillStartAnimatingFrom(viewController: UIViewController) {
        if let vc = viewController as? SendTokenFeeViewController, vc.heroType != 0 {
            onSuspendBlock()
        }
    }
}
