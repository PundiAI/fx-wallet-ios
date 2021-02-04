//
//
//  XWallet
//
//  Created by May on 2020/12/24.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import TrustWalletCore
import Web3
import SwiftyJSON

extension WKWrapper where Base == OxSwapConfirmViewController {
    var view: OxSwapConfirmViewController.View { return base.view as! OxSwapConfirmViewController.View }
}

extension OxSwapConfirmViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let vm = context["vm"] as? OxSwapModel, let amountsModel = context["amountsModel"] as? OxAmountsModel  else { return nil }
        let vc = OxSwapConfirmViewController(wallet: wallet, vm: vm, amountsModel:amountsModel)
        return vc
    }
}

class OxSwapConfirmViewController: WKViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, vm: OxSwapModel, amountsModel: OxAmountsModel) {
        self.wallet = wallet
        self.viewModel = vm
        self.amountsModel = amountsModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let wallet: WKWallet
    private let viewModel: OxSwapModel
    private var amountsModel: OxAmountsModel
    var actionBag: DisposeBag = DisposeBag()
    
    lazy var timerBind: TimeBinder = TimeBinder(view: wk.view.startPanel)
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad() 
        logWhenDeinit()
        timerBind.view.isHidden = true
        getOxQuote()
    }
    
    override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Ox.Order.Title"))
        navigationBar.action(.left, imageName: "ic_back_60") { [weak self] in
            Router.pop(self)
        }
    }
    
    private func bind() {
        actionBag = DisposeBag()
        bindList()
        bindAction()
        timerBind.view.isHidden = false
    }
    
    private func bindList() {
        wk.view.listView.viewModels = { [weak self] section in
            guard let amountsModel = self?.amountsModel else { return section }
            section.push(TokenPanelCell.self, m:amountsModel)
            section.push(FeeCell.self, m: amountsModel)
            return section
        }
        
        wk.view.listView.reloadData()
    }
    
    private func bindAction() {
        wk.view.startPanel.startButton.rx.tap.subscribe(onNext: { [weak self](_) in
            guard let this = self else { return }
            this.wk.view.startPanel.startButton.inactiveAWhile(0.3)
            this.swap()
        }).disposed(by: actionBag)
        
        timerBind.bind()
    }
    
    var abi: String = ""
    var toAddress: String = ""
    
    private func getOxQuote() {
        
       
        
        let from = amountsModel.from.token
        let to = amountsModel.to.token
        
        let fToken =  from.isETH ? from.symbol : from.contract
        let tToken =  to.isETH ? to.symbol : to.contract
        
        var inputAmountBig : String = ""
        var outputAmountBig : String = ""
        
        if viewModel.startFrom {
            inputAmountBig =  amountsModel.from.inputBigValue
            outputAmountBig = "0"
        } else {
            inputAmountBig =  "0"
            outputAmountBig = amountsModel.to.inputBigValue
        }
        
        
        print(viewModel.startFrom, inputAmountBig, outputAmountBig)
        
         
        var slippagePercentage = "0.01"
        
        if let percentage = self.wallet.slippagePercentage {
            slippagePercentage =  "\(percentage.d / 100)"
        }
        
        self.view.hud?.waiting()
        FxAPIManager.fx.oxQuote(fToken, tToken, sellAmount: inputAmountBig, buyAmount: outputAmountBig,
                                takerAddress: amountsModel.from.account.address,
                                slippagePercentage: slippagePercentage).subscribe(onNext: { [weak self] (quote) in
                                    guard let weakself = self else { return }
                                    weakself.view.hud?.hide()
                                    weakself.abi = quote.data
                                    weakself.toAddress = quote.to
                                    weakself.amountsModel.price?.price = quote.price
                                    weakself.amountsModel.quote = quote
                                    weakself.bind()
                                }, onError: { [weak self](error) in
                                    self?.view.hud?.hide()
                                    let _error = error as NSError
                                    if let _rerror = JSON(_error.userInfo)["validationErrors"].array?.get(0) {
                                        print("===", _rerror["code"], _rerror["reason"])
                                        if _rerror["code"].stringValue == "1004" {
                                            self?.view.hud?.error(m: TR("Ox.Insufficient.Liquidity"), d: 2, c: {
                                                
                                                guard let wallet = XWallet.currentWallet else {
                                                    return
                                                }
                                            
                                                Router.pushToSwap(wallet: wallet.wk) { vc in
                                                    Router.setRootController(wallet: wallet, viewControllers: [vc])
                                                }
                                            })
                                            
                                        } else {
                                            guard let wallet = XWallet.currentWallet else {
                                                return
                                            }
                                            
                                            self?.view.hud?.error(m: TR("Ox.Transaction.Invalid"), d: 2, c: {
                                                Router.pushToSwap(wallet: wallet.wk) { vc in
                                                    Router.setRootController(wallet: wallet, viewControllers: [vc])
                                                }
                                            })
                                        }
                                    }
                                    
                                    
                                    
                                }).disposed(by: self.actionBag)
    }
    
    private func send(abi: String, toAddress : String, amountModel: OxAmountsModel) {
        guard let ethPrivateKey = try? EthereumPrivateKey(hexPrivateKey: amountModel.from.account.privateKey.data.hexString) else {
            print("privateKey is invalid")
            return
        }
        
        guard let toETHAddress = EthereumAddress(hexString: toAddress) else {
            print("toAddress is invalid")
            return
        }
        
        guard let wallet = XWallet.currentWallet else {
            return
        }
        
        var amount = BigUInt(0)
        if let  _amount = amountModel.quote?.value {
            amount = BigUInt(_amount)!
        }
        
        self.hud?.waiting()
        
        self.wk.view.islock = true
        
        let tx = FxAPIManager.fx.buildTx(privateKey: ethPrivateKey, to: toETHAddress, amount: amount, abi: abi)
        
        guard let txTran = tx else {
            return
        }
        
        
        let bulidTx  = OxNode.Shared.buildEthTx(txTran, fromCoin: amountModel.from.token, wallet: wallet)
        _ = bulidTx.subscribe(onNext: {[weak self] (tx) in
            self?.hud?.hide()
            tx.is0x = true
            tx.is0xMsg = TR("Ox.Transaction.SubTitle", amountModel.from.inputformatValue.thousandth(), amountModel.from.token.symbol, amountModel.to.inputformatValue.thousandth(), amountModel.to.token.symbol)
            Router.pushToSendTokenFee(tx: tx, account: amountModel.from.account) { (error, json) in
                var value = false
                if json["didRequested"].stringValue == "1" {
                    value = true
                }
                if WKError.canceled.isEqual(to: error) {
                    if value {
                        Router.pushToSwap(wallet: wallet.wk) { vc in
                            Router.setRootController(wallet: wallet, viewControllers: [vc])
                        }
                    } else {
                        self?.getViewController(heroIdentity: "OxSwapConfirmViewController")
                    }
                }
            }
        }, onError: { [weak self] (e) in
            print(e.asWKError().msg)
            self?.hud?.hide()
            self?.hud?.error(m: e.asWKError().msg)
            self?.wk.view.islock = false
        }).disposed(by: actionBag)
    }

    private func swap() {
        if timerBind.view.timerOut {
            getOxQuote()
            return
        }
        
        if checkBalance() {
            send(abi: self.abi, toAddress: self.toAddress, amountModel: self.amountsModel)
        }
    }
    
    private func checkBalance() -> Bool {
        let balance = XWallet.currentWallet?.wk.balance(of: amountsModel.from.account.address, coin: Coin.ethereum) ?? .empty
        let amount = balance.value.value.div10(18).d
        var minValue = 0.0044
        if let quote = amountsModel.quote {
            let fee = quote.gasPrice.mul(quote.gas)
            minValue =  fee.div10(Coin.ethereum.decimal).thousandth(4).d
        }
        
        if amount <= minValue {
            let minValue = "\(minValue) \(Coin.ethereum.symbol)"
            let balance = "\(balance.value.value.div10(18).thousandth(4)) \(Coin.ethereum.symbol)"
            Router.showOxTipAlert(current: (minValue, balance))
            return false
        }
        return true
    }
    
    
    private func getViewController(heroIdentity: String) {
        guard let viewControllers = Router.currentNavigator?.viewControllers, viewControllers.count > 1 else { return }
        if let _vc =  viewControllers.find(condition: { (vc) -> Bool in
            vc.heroIdentity == heroIdentity
        }) {
            if let v  = _vc as? OxSwapConfirmViewController {
                v.wk.view.islock = false
                Router.pop(to: v, animated: true, completion: nil)
            }
      }
    }
}
 
