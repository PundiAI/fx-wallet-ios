//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import XChains
import RxSwift
import RxCocoa
import TrustWalletCore

extension TokenListViewController {
    
    class CellViewModel {
        
        init(wallet: Wallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet.wk
            
            self.bind()
        }
        
        let coin: Coin
        let wallet: WKWallet
        
        let rateText = BehaviorRelay<NSAttributedString>(value: NSAttributedString(string: ""))
        let rateImage = BehaviorRelay<UIImage?>(value: nil)
        
        let priceText = BehaviorRelay<String>(value: "$ --")
        lazy var amountText = BehaviorRelay<String>(value: "-- \(coin.symbol)")
        let legalAmountText = BehaviorRelay<String>(value: "$ --")
        let legalAmount = BehaviorRelay<String>(value: "0")
        
        private lazy var bag = DisposeBag()
        private lazy var fetchRate = APIAction(coin.symbol.rate())
        private lazy var fetchAmount = APIAction(fetchBalanceSignal())
         
        func refresh() {
            
            fetchRate.execute()
            fetchAmount.execute()
        }
        
        private func bind() {
            
            if let cacheRate = coin.symbol.rate(onlyAvailable: false) {
                handle(rate: cacheRate)
            }
            
            weak var welf = self
            fetchAmount.elements.subscribe(onNext: { (amount) in
                guard let this = welf, amount.isNotEmpty else { return }

                welf?.amountText.accept("\(amount.thousandth(8)) \(this.coin.symbol)")
            }).disposed(by: bag)
            
            
            fetchRate.elements
                .subscribe(onNext: { welf?.handle(rate: $0) })
                .disposed(by: bag)
            
            Observable.combineLatest(fetchAmount.elements, fetchRate.elements)
                .subscribe(onNext: { (t) in
                    
                    let (amount, rate) = t
                    if amount.isNotEmpty {
                        
                        let legalAmount = amount.mul(rate.value, 2)
                        welf?.legalAmount.accept(legalAmount)
                        welf?.legalAmountText.accept("$ \(legalAmount.thousandth(2))")
                    }
            }).disposed(by: bag)
        }
        
        private func handle(rate: FxRate) {
            
            let isIncrease = rate.dailyChange >= 0
            rateText.accept(NSAttributedString(string: String(format: "%.2f", abs(rate.dailyChange)) + "%",
                                                     attributes: [.foregroundColor: HDA( isIncrease ? 0xB6F23B : 0xFA6237)]))
            rateImage.accept(IMG(isIncrease ? "ic_rate_up" : "ic_rate_down"))
            priceText.accept("$ \(rate.value.dynamicThousandth(4))")
        }
        
        //MARK: Network
        private func fetchBalanceSignal() -> Observable<String> {
            
            let addresses = wallet.addressManager.addresses(forCoin: coin)
            return combine(addresses.map{ coin.balance(of: $0) })
        }
        
        private func combine(_ source: [Observable<String>]) -> Observable<String> {
            
            let combined: Observable<String>
            if source.count == 1 {
                combined = source.first!
            } else {
                combined = Observable.combineLatest(source).map {
                    
                    var result = "0"
                    $0.forEach{ result = result.add($0) }
                    return result
                }
            }
            
            let decimal = coin.decimal.d
            return combined.map {
                return $0.isZero ? "0" : $0.div(pow(10, decimal).s, decimal.i)
            }
        }
    }
    
}


