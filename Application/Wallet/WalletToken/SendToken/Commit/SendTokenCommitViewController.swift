//
//  SendTokenCommitViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/10.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Hero
import Web3
import WKKit
import BigInt
import RxSwift
import RxCocoa
import XChains
import FunctionX
import SwiftyJSON
import TrustWalletCore

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
    private lazy var pagerCell = PageCell(pageBinder.view)
    private lazy var pageBinder = SendTokenCommitPageViewController(wallet: wallet, coin: coin)
    
    private lazy var isValidInput = BehaviorRelay<Bool>(value: false)
    private lazy var crossChainBinder = FxCrossChainBinder(view: wk.view)
    
    override func loadView() { self.view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()

        logWhenDeinit()

        bindListView()
        bindCrossChain()
        bindUserAddress()
        bindUserNameList()

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
    
    private func bindUserNameList() {
        
        userNameBinder.bind(wallet: wallet, coin: coin, input: wk.view.inputTF)
        userNameBinder.didSeleted = { [weak self] user in
            self?.receiver = user
        }
    }
    
    private func bindUserAddress() {
        
        weak var welf = self
        let didSeletedUser: (User) -> Void = { user in
            welf?.switchScrollResponder(toMainList: true)
            welf?.wk.view.mainListView.contentOffset = .zero
            welf?.receiver = user
        }
        
        pageBinder.mineList.didSeleted = didSeletedUser
        pageBinder.recentList.didSeleted = didSeletedUser
    }
    
    private func bindInput() {
        
        weak var welf = self
        if tx.receiver.address.isNotEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.receiver = self.tx.receiver
                self.wk.view.inputTF.contentOffset = CGPoint(x: 0, y: 10)
            }
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
                    this.hud?.text(m: TR("Alert.Unknown.Address"))
                } else {

                    let receiver = User(address: json["address"].stringValue)
                    this.receiver = receiver
                }
            }
        }).disposed(by: defaultBag)
    }
    
    private func bindCrossChain() {
        
        crossChainBinder.bind(tx: tx, account: account, wallet: wallet)
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
        fetchAddress(of: receiver)
            .flatMap{ _ in welf?.setTxFee() ?? .empty() }
            .subscribe(onNext: { (gas, gasPrice, balance) in
                welf?.hud?.hide()
                guard let this = welf else { return }

                this.tx.balance = balance
                this.tx.adjustMaxAmountIfNeed()
                if this.tx.fee.isGreaterThan(decimal: balance) {
                    this.hud?.text(m: TR("Alert.Tip$", this.tx.feeDenom))
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
        if tx.mutilGasPrice.isValid {
            Router.pushToSendTokenFee(tx: tx, account: account)
        } else {
            
            Router.showBroadcastTxAlert(tx: tx, privateKey: account.privateKey, completionHandler: { (error, result) in

                if WKError.canceled.isEqual(to: error) {
                    if result.count == 0 {
                        Router.pop(to: "SendTokenInputViewController", elseToPreviousOrRoot: false)
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
    
    private func fetchAddress(of receiver: User) -> Observable<String> {
        
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
 
    private func setTxFee() -> Observable<(String, String, String)> {
        
        if tx.coin.isBSC { return setBSCTxFee() }
        if tx.coin.isBTC { return setBitcoinTxFee() }
        if tx.coin.isBinance { return setBinanceTxFee() }
        if tx.coin.isEthereum { return setEthereumTxFee() }
        if tx.coin.isFunctionX { return setFunctionXTxFee() }
        return .error(WKError(.default, "fetch tx fee failed"))
    }
    
    private func setEthereumTxFee() -> Observable<(String, String, String)> {
        
        let coin = tx.coin
        let node = EthereumNode(endpoint: coin.node.url, chainId: 0)
        let gasPrice = APIManager.fx.estimateGasPrice().catchError { (_)  in
            return node.gasPrice().map{ price in
                
                let mutilGasPrice = MutilGasPrice([:])
                mutilGasPrice.normal = String(price)
                return mutilGasPrice
            }
        }.flatMap { [weak self]v -> Observable<String> in
            
            if v.isValid { self?.tx.mutilGasPrice = v }
            return .just(v.normal)
        }
        
        let amount = tx.amount
        var balance = Observable<String>.just(tx.balance)
        var estimatedGas = node.estimatedGasOfTx(from: tx.from, to: tx.to, value: BigUInt(amount)!).map { String($0 < 21000 ? 21000 : $0) }
        if coin.isERC20 {
            balance = node.balance(of: account.address)
            estimatedGas = node.estimatedGasOfTx(from: tx.from, to: tx.to, amount: BigUInt(amount)!, tokenContract: coin.contract)
        }
        return Observable.combineLatest(estimatedGas, gasPrice, balance).do(onNext: { [weak self](gas, gasPrice, _) in
            
            self?.tx.gasLimit = gas
            self?.tx.gasPrice = gasPrice
            self?.tx.set(fee: gas.mul(gasPrice), denom: coin.feeSymbol)
        })
    }
    
    private func setFunctionXTxFee() -> Observable<(String, String, String)> {
        
        let coin = tx.coin
        var feeCoin = coin
        let node = FxNode(endpoints: FxNode.Endpoints(rpc: coin.node.url), wallet: FxWallet(privateKey: account.privateKey, chain: coin.fxChain))
        var balance = Observable<String>.just(tx.balance)
        if coin.isFxCore {
            if !coin.isFXC {
                feeCoin = CoinService.current.fxCore
                balance = wallet.balance(of: account.address, coin: feeCoin).refresh().take(1)
            }
        } else if coin.isFxPayment {
            if !coin.isPAYC {
                feeCoin = CoinService.current.payc
                balance = wallet.balance(of: account.address, coin: feeCoin).refresh().take(1)
            }
        } else {
            return .error(WKError(.default, "estimatedGas failure"))
        }
        
        let gasPrice = node.gasPrice(of: feeCoin.symbol)
        let estimatedGas = node.buildTransferTx(to: tx.to, amount: tx.amount.sub("10"), denom: coin.symbol, fee: "1", feeDenom: feeCoin.symbol, gas: 0).flatMap{ tx in
            node.estimatedGas(ofTx: tx).map{ String($0) }
        }
        return Observable.combineLatest(estimatedGas, gasPrice, balance).do(onNext: { [weak self](gas, gasPrice, _) in
            
            self?.tx.gasLimit = gas
            self?.tx.gasPrice = gasPrice
            self?.tx.set(fee: gas.mul(gasPrice), denom: feeCoin.symbol)
        })
    }
    
    private func setBitcoinTxFee() -> Observable<(String, String, String)> {
        
        let coin = tx.coin
        let node = BitcoinNode(.blockcypher(host: coin.node.url, token: coin.node.apiToken))
        let fetchUTXOs = node.fetchUTXOs(of: tx.from)
        let fetchSatPerByte = APIManager.fx.estimateSatPerByte()
        return Observable.combineLatest(fetchUTXOs, fetchSatPerByte).flatMap{ [weak self](utxos, mSat) -> Observable<(String, String, String)> in
            guard let this = self else { return .empty() }
            
            self?.tx.utxos = utxos
            self?.tx.mutilGasPrice = mSat
            return node.sign(with: (utxos, this.account.privateKey), toAddress: this.tx.to, changeAddress: this.tx.from, amount: Int64(this.tx.amount) ?? 0, fee: 0).map { (output, plan) in
                
                //fee = input*148 + 34*out + 10
                let fee = (output.transaction.inputs.count * 148) + (output.transaction.outputs.count * 34) + 10
                let (vBytes, satPerByte) = (String(fee), mSat.normal)
                this.tx.vBytes = vBytes
                this.tx.satPerByte = satPerByte
                this.tx.set(fee: satPerByte.mul(vBytes), denom: this.coin.feeSymbol)
                return (vBytes, satPerByte, this.tx.balance)
            }
        }
    }
    
    private func setBinanceTxFee() -> Observable<(String, String, String)> {
        
        var balance = Observable<String>.just(tx.balance)
        if !coin.isBNB {
            balance = wallet.balance(of: account.address, coin: CoinService.current.bnb ?? .empty).refresh().take(1)
        }
        return Observable.combineLatest(BinanceChain.current.fee(), balance).map({ [weak self](fee, balance) in
            
            self?.tx.set(fee: fee, denom: "BNB")
            return ("1", fee, balance)
        })
    }
    
    private func setBSCTxFee() -> Observable<(String, String, String)> {
        
        let coin = tx.coin
        let node = BSCNode(endpoint: coin.node.url, chainId: 0)
        
        let amount = tx.amount
        var balance = Observable<String>.just(tx.balance)
        let gasPrice = node.gasPrice().map{ $0.description }
        var estimatedGas = node.estimatedGasOfTx(from: tx.from, to: tx.to, value: BigUInt(amount)!).map { String($0 < 21000 ? 21000 : $0) }
        if coin.isBEP20 {
            balance = node.balance(of: account.address)
            estimatedGas = node.estimatedGasOfTx(from: tx.from, to: tx.to, amount: BigUInt(amount)!, tokenContract: coin.contract)
                .map { $0.d < 60000 ? "60000" : $0 }
        }
        return Observable.combineLatest(estimatedGas, gasPrice, balance).do(onNext: { [weak self](gas, gasPrice, _) in
            
            self?.tx.gasLimit = gas
            self?.tx.gasPrice = gasPrice
            self?.tx.set(fee: gas.mul(gasPrice), denom: coin.feeSymbol)
        })
    }
    
    //MARK: Utils
    private func check(input: String?) {

        let text = input ?? ""
        var isValid = false
        if text.count > 2 && text.hasPrefix("@") { //input name
            isValid = userNameBinder.support(coin: coin)
        } else if text.count >= 12 { //input address

            if coin.is(.ethereum) || coin.isBSC {
                isValid = AnyAddress.isValid(string: text, coin: .ethereum)
            } else if coin.isBTC {
                isValid = BitcoinAddress.isValid(address: text)
            } else if coin.isFunctionX || coin.isBinance {
//                result = FunctionXAddress.isValid(string: text)
                let (hrp, _) = FunctionXAddress.decode(address: text) ?? ("", Data())
                isValid = hrp == coin.hrp
            }
        }
        isValidInput.accept(isValid)
    }
    
    private func inputError(_ text: String) {
        
        hud?.text(m: text)
        wk.view.showInputError()
        wk.view.nextButton.isEnabled = false
    }
}

extension SendTokenCommitViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func bindListView() {
        
        wk.view.mainListView.bounces = false
        wk.view.mainListView.delegate = self
        wk.view.mainListView.dataSource = self
        bindListResponder()
    }
    
    //MARK: ListResponder
    private func bindListResponder() {
        let source = pageBinder.listControllers.map{ $0.contentOffset.asObservable() }
        Observable.merge(source).subscribe(onNext: { [weak self] (offset) in
            guard let this = self, let offset = offset else { return }
            if !this.wk.view.mainListView.isFirstScrollResponder && offset.y <= 0 {
                this.switchScrollResponder(toMainList: true)
            }
        }).disposed(by: defaultBag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let listView = wk.view.mainListView
        let maxOffsetY = wk.view.headerHeight - FullNavBarHeight
        
        if listView.contentOffset.y >= maxOffsetY && listView.isFirstScrollResponder {
            switchScrollResponder(toMainList: false)
        }

        if listView.contentOffset.y >= maxOffsetY || !listView.isFirstScrollResponder {
            listView.contentOffset = CGPoint(x: 0, y: maxOffsetY)
        }
        
        wk.view.relayoutNavBar(showCorners: listView.contentOffset.y >= (maxOffsetY - 80))
    }
    
    //MARK: UITableViewDelegate && DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0.0 }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 0.0 }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? wk.view.headerHeight : pagerCell.estimatedHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return indexPath.row == 0 ? wk.view.headerCell : pagerCell
    }
    
    private func switchScrollResponder(toMainList: Bool) {
        wk.view.mainListView.isFirstScrollResponder = toMainList
        for vc in pageBinder.listControllers {
            
            vc.listView.isFirstScrollResponder = !toMainList
            if toMainList, vc.listView.contentOffset != .zero {
                DispatchQueue.main.async {
                    vc.listView.contentOffset = .zero
                }
            }
        }
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
        wk.view.headerBGView.hero.id = nil
        wk.view.headerBGView.hero.modifiers = nil
        wk.view.headerContentView.hero.modifiers = nil
        wk.view.backgroundView.hero.id = nil
        wk.view.backgroundView.hero.modifiers = nil
        wk.view.mainListView.hero.modifiers = nil
        
        wk.view.unlockView.hero.modifiers = nil
        wk.view.mainListView.tableHeaderView?.hero.modifiers = nil
        wk.view.navBar.hero.modifiers = nil
        wk.view.mainListTopSpaceView.hero.modifiers = nil
        
        wk.view.nextButton.hero.id = nil
        wk.view.nextButton.hero.modifiers = nil
        wk.view.nextButton.titleLabel?.hero.modifiers = nil
        wk.view.unlockView.actionView.submitButton.hero.id = nil
        wk.view.unlockView.actionView.submitButton.hero.modifiers = nil
        wk.view.unlockView.actionView.submitButton.titleLabel?.hero.modifiers = nil
    }
    
    private func sendButton() ->UIButton {
        let nextButton = wk.view.nextButton
        let sendButton = wk.view.unlockView.actionView.submitButton 
        return wk.view.unlockView.isHidden == false ? sendButton : nextButton
    }
    
    
    private func bindHero() { 
        weak var welf = self
        let onSuspendBlock:(WKHeroAnimator)->Void  = { _ in
            welf?.onSuspendBlock()
        }
        
        let animator = WKHeroAnimator({ (_) in
            welf?.sendButton().hero.id = "backgroundView"
            welf?.sendButton().titleLabel?.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.sendButton().hero.modifiers = [.resizableCap(UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28), .stretch),
                                                 .useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.unlockView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .fade]
             
            welf?.wk.view.mainListView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 1000)]
            welf?.wk.view.mainListTopSpaceView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 1000)]
            welf?.wk.view.headerContentView.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.navBar.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
        animators["0"] = animator
        
        let animator1 = WKHeroAnimator({ (_) in
            welf?.wk.view.unlockView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.navBar.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:-1000)]
            welf?.wk.view.headerContentView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:-1000)]
            welf?.wk.view.headerBGView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:-1000)]
            welf?.wk.view.mainListView.tableHeaderView?.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y:-1000)]
            welf?.wk.view.mainListView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 1000)]
        }, onSuspend: onSuspendBlock)
        animators["1"] = animator1
    } 
}
