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

extension SwapViewController {
    class CoinCell: FxTableViewCell {
        
        private var viewModel: SwapViewModel?
        lazy var view = CoinPannel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? SwapViewModel else { return }
            self.viewModel = vm
            weak var welf = self
            
            vm.fromV.subscribe(onNext: { [weak self] (t) in
                guard let token = t?.token, let account = t?.account else {
                    self?.view.fromTokenView.selectedCoin = false
                    self?.view.fromBalance.text = "-"
                    return
                }
                welf?.view.fromTokenView.selectedCoin = true
                welf?.view.fromTokenView.tokenIV.setImage(urlString: token.imgUrl, placeHolderImage: token.imgPlaceholder)
                welf?.view.fromToken.text = token.token
                welf?.view.fromTokenView.doneButton.isHidden = false
                let balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                
                let  scl = balance.value.value.div10(token.decimal).isLessThan(decimal: "1") ?  8 : 2
                
                welf?.view.fromBalance.text = "Balance: \(balance.value.value.div10(token.decimal, scl).thousandth(8, mb: false))"
                vm.balanceAmount.accept((balance.value.value,""))
            }).disposed(by: reuseBag)
            
            vm.toV.subscribe(onNext: { [weak self] (t) in
                guard let token =  t?.token, let account = t?.account else {
                    self?.view.toTokenView.selectedCoin = false
                    self?.view.toBalance.text = "-"
                    return
                }
                welf?.view.toTokenView.selectedCoin = true
                welf?.view.toTokenView.tokenIV.setImage(urlString: token.imgUrl, placeHolderImage: token.imgPlaceholder)
                welf?.view.toToken.text = token.token
                let balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                let  scl = balance.value.value.div10(token.decimal).isLessThan(decimal: "1") ?  8 : 2
                welf?.view.toBalance.text = "Balance: \(balance.value.value.div10(token.decimal, scl).thousandth(8, mb: false))"
            }).disposed(by: reuseBag)
            
            view.fromMax.rx.tap.subscribe(onNext: { (_) in
                guard let token = welf?.viewModel?.fromV.value?.token, let account = welf?.viewModel?.fromV.value?.account else { return}
                let balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: token) ?? .empty
                welf?.view.fromInputTF.text = balance.value.value.div10(token.decimal)
                welf?.viewModel?.changeAmount.accept(balance.value.value.div10(token.decimal))
                welf?.viewModel?.startFrom = true
                welf?.router(event: "Set.Max.Value")
                
            }).disposed(by: reuseBag)
            
            
            view.selectFromToken.rx.tap.subscribe(onNext: { (_) in
                welf?.router(event: "select.From.Coin")
            }).disposed(by: reuseBag)
            
            view.selectToToken.rx.tap.subscribe(onNext: { (_) in
                welf?.router(event: "select.To.Coin")
            }).disposed(by: reuseBag)
            
            view.changeBtn.rx.tap.subscribe(onNext: { (_) in
                welf?.router(event: "Change")
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat {
            return (104 + 56 + 104).auto()
        }
    }
}

extension SwapViewController {
    
    class FeeCell: FxTableViewCell {
            
            private var viewModel: Any?
            lazy var view = FeePannel(frame: ScreenBounds)
            override func getView() -> UIView { view }
            
            override func bind(_ viewModel: Any?) {
                guard let vm = viewModel as? SwapViewModel else { return }
                self.viewModel = vm
                
                weak var welf = self
                
                view.maxSold.titleLabel.text = "Maxmum sold"
                view.priceImpact.titleLabel.text = "Price Impact"
                view.providerFee.titleLabel.text = "Liquidity Provider Fee"
                
                vm.maxSold.asDriver()
                    .drive(onNext: {
                        if $0.isEqual(decimal: "0") { return }
                        welf?.view.maxSold.titleLabel.text = "Maxmum sold"
                        welf?.view.soldValue.text = $0
                    })
                    .disposed(by: reuseBag)
                
                vm.minimumRecived.asDriver()
                    .drive(onNext: {
                        if $0.isEqual(decimal: "0") { return }
                        welf?.view.maxSold.titleLabel.text = "Minimum received"
                        welf?.view.soldValue.text = $0
                    })
                    .disposed(by: reuseBag)
                
                vm.priceImpact.asDriver()
                    .drive(view.priceValue.rx.attributedText)
                    .disposed(by: reuseBag)
                
                vm.fee.asDriver()
                    .drive(view.providerValue.rx.text)
                    .disposed(by: reuseBag)
                
                
                view.soldHelpBtn.rx.tap.subscribe(onNext: { (_) in
                    welf?.router(event: "Sold.Help")
                }).disposed(by: reuseBag)
                
                view.priceHelpBtn.rx.tap.subscribe(onNext: { (_) in
                    welf?.router(event: "Price.Help")
                }).disposed(by: reuseBag)
                
                view.providerHelpBtn.rx.tap.subscribe(onNext: { (_) in
                   welf?.router(event: "Provider.Help")
                }).disposed(by: reuseBag)
 
    //            maxSold.accept("0.038 ETH")
    //            priceImpact.accept(NSAttributedString(string: "<0.3%" ,
    //                                                  attributes: [.font : XWallet.Font(ofSize: 14),
    //                                                               .foregroundColor: HDA(0x71A800)]))
    //            fee.accept("0.00000398 ETH")
    //            price.accept("0.26891 ETH per USDC")
    //            tempexchangeRate.accept(true)
            }
            
            override class func height(model: Any?) -> CGFloat {
                return 132.auto()
            }
        }
}
                


extension SwapViewController {
    
    class RefreshCell: FxTableViewCell {
            
            private var viewModel: Any?
            lazy var view = PriceView(frame: ScreenBounds)
            override func getView() -> UIView { view }
            
            override func bind(_ viewModel: Any?) {
                guard let vm = viewModel as? SwapViewModel else { return }
                self.viewModel = vm
                weak var welf = self
                vm.price.asDriver().drive(onNext: { (value) in
                    welf?.view.subTitleLabel.text = value
                }).disposed(by: reuseBag)
                
                view.refeshBtn.rx.tap.subscribe(onNext: { (_) in
                    welf?.router(event: "Refresh")
                }).disposed(by: reuseBag)
            }
            
            override class func height(model: Any?) -> CGFloat {
                return 104.auto()
            }
        }
}

extension SwapViewController {
    class RateViewCell: FxTableViewCell {
            
            private var viewModel: Any?
            lazy var view = RateView(frame: ScreenBounds)
            override func getView() -> UIView { view }
            
            override func bind(_ viewModel: Any?) {
                guard let vm = viewModel as? SwapViewModel else { return }
                self.viewModel = vm
//                weak var welf = self
                view.rate0.update(model: ("", "Binance", "ETH/USDC", "0.28483746"))
                view.rate1.update(model: ("", "Huobi", "ETH/USDC", "0.28483746"))
                view.rate2.update(model: ("", "Kucoin", "ETH/USDC", "0.28483746"))
            }
            
            override class func height(model: Any?) -> CGFloat {
                return (144 + 8).auto()
            }
        }
}

extension SwapViewController {
    class FoldRateViewCell: FxTableViewCell {
            
            private var viewModel: Any?
            lazy var view = FoldRateView(frame: ScreenBounds)
            override func getView() -> UIView { view }
            
            override func bind(_ viewModel: Any?) {
                guard let vm = viewModel as? SwapViewModel else { return }
                self.viewModel = vm
                weak var welf = self
                
                vm.rateList.subscribe(onNext: { (rs) in
                    if rs.count > 0 {
                        welf?.view.reset()
                        for item in rs {
                            welf?.view.updatePriceItem(rate: item)
                        }
                        let temp = Rate()
                        temp.exchange = "huobi"
                        temp.unit = "NPXS"
                        temp.toUnit = "FX"
                        temp.rate = "345632"
                        welf?.view.updatePriceItem(rate: temp)

                        let temp0 = Rate()
                        temp0.exchange = "OK"
                        temp0.unit = "NPXS"
                        temp0.toUnit = "FX"
                        temp0.rate = "234"

                        welf?.view.updatePriceItem(rate: temp0)

                        welf?.view.startPriceLoopIfNeed()
                    }
                }).disposed(by: reuseBag)
            }
            
            override class func height(model: Any?) -> CGFloat {
                return (86 + 8).auto()
            }
        }
}


extension SwapViewController {
    class RouterCell: FxTableViewCell {
            
            private var viewModel: Any?
            lazy var view = RounterView(frame: ScreenBounds)
            override func getView() -> UIView { view }
            
            override func bind(_ viewModel: Any?) {
                guard let vm = viewModel as? SwapViewModel else { return }
                self.viewModel = vm
                
                if vm.routeList.value.count > 0 {
                    self.view.bindRouter(tags: vm.routeList.value)
                }
            }
            
            override class func height(model: Any?) -> CGFloat {
                guard let vm = model as? SwapViewModel else { return 0 }
                var mu = 1
                if vm.routeList.value.count != 0 {
                    let row = vm.routeList.value.count % 3
                    mu = vm.routeList.value.count / 3
                    if row != 0 {
                        mu = mu + 1
                    }
                }
                let contentHeight =  mu * 24 +  (mu - 1) * 14
                return (56 + 24 + contentHeight + 24).auto()
            }
        }
}
