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
    
    class SectionViewModel: RxObject {
        
        init(coin: Coin) {
            self.coin = coin
        }
        
        let coin: Coin
        var items: [CellViewModel] = []
        
        func add(_ item: CellViewModel) {
            items.append(item)
        }
    }
}

extension TokenListViewController {
    
    class CellViewModel: RxObject {
        
        init(wallet: Wallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet.wk
            super.init()
            
            self.bind()
        }
        
        let coin: Coin
        let wallet: WKWallet
        
        lazy var rateText = BehaviorRelay<NSAttributedString?>(value: nil)
//        lazy var priceText = BehaviorRelay<String>(value: "$--")
        
        var refreshBag: DisposeBag!
        lazy var balance = BalanceRelay(coin: coin)
        lazy var legalBalance = BalanceRelay(legal: true, coin: coin)
        
//        private lazy var marketRank = coin.symbol.marketRank()
        private lazy var fetchBalance = APIAction(refreshAccounts())
        private lazy var exchangeRate = coin.symbol.exchangeRate()
         
        func refresh() {
            
            fetchBalance.execute()
//            marketRank.refreshIfNeed()
            exchangeRate.refreshIfNeed()
        }
        
        private func bind() {
            
            weak var welf = self
            let coin = self.coin

//            marketRank.value
//                .subscribe(onNext: { welf?.handle(rank: $0) })
//                .disposed(by: defaultBag)
            
//            exchangeRate.value
//                .subscribe(onNext: { welf?.priceText.accept("$\($0.value.thousandth(ThisAPP.CurrencyDecimal))") })
//                .disposed(by: defaultBag)
            
            if coin.node.isMainnet {
             
                Observable.combineLatest(balance.value, exchangeRate.value)
                    .subscribe(onNext: { (t) in
                        let (amount, rate) = t
                        if !rate.isUnknown, !amount.isUnknownAmount {
                            
                            let legalAmount = amount.div10(coin.decimal).mul(rate.value, ThisAPP.CurrencyDecimal)
                            welf?.legalBalance.accept(legalAmount)
                        }
                }).disposed(by: defaultBag)
            }
        }
        
//        private func handle(rank: FxMarketRank) {
//
//            let isIncrease = rank.dailyChange >= 0
//            let prefix = isIncrease ? "+" : "-"
//            rateText.accept(NSAttributedString(string: String(format: "\(prefix)%.2f", abs(rank.dailyChange)) + "%",
//                                                     attributes: [.foregroundColor: HDA( isIncrease ? 0x71A800 : 0xFA6237)]))
//        }
        
        //MARK: Network
        private func refreshAccounts() -> Observable<AccountList> {
            
            let accounts = Observable<AccountList>.just(wallet.accounts(forCoin: coin))
            return accounts.do(onNext: { [weak self](v) in
                guard let this = self else { return }

                let coin = this.coin
                let result: Observable<[String]>
                if coin.mergeBalanceRequest {
                    
                    let balanceList = this.wallet.balanceList(coin: this.coin)
                    result = balanceList.value.map{ Array($0.values) }
                    balanceList.refreshIfNeed()
                } else {
                    
                    var request: [Balance] = []
                    var signals: [BehaviorRelay<String>] = []
                    for account in v.accounts {
                        
                        let balance = this.wallet.balance(of: account.address, coin: coin)
                        request.append(balance)
                        signals.append(balance.value)
                    }
                    result = Observable.combineLatest(signals)
                    request.forEach{ $0.refreshIfNeed() }
                }
                
                this.refreshBag = DisposeBag()
                result.subscribe(onNext: { (values) in
                    
                    var result = "0"
                    for v in values {
                        if !v.isUnknownAmount { result = result.add(v, coin.decimal) }
                    }
                    self?.balance.accept(result)
                }).disposed(by: this.refreshBag)
            })
        }
    }
    
} 
