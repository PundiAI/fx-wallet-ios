//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankAssetsOverviewViewController {
    
    class ViewModel: RxObject {
        
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            if wallet.coinManager.has(coin) {
                for (idx, account) in wallet.accounts(forCoin: coin).accounts.enumerated() {
                    items.append(CellViewModel(wallet: wallet, coin: coin, account: account, index: idx))
                }
            }
            super.init()
            
            self.bind()
        }
        
        let coin: Coin
        let wallet: WKWallet
        var items: [CellViewModel] = []
        
        lazy var reserveData = AAveReserveData.data(of: coin)
        lazy var exchangeRate = coin.symbol.exchangeRate()
        lazy var legalAvailableLiquidity = BalanceRelay(key: "aave.AL.\(coin.id)_\(coin.chainType.rawValue)")
        
        func refresh() {
            
            reserveData.refreshIfNeed()
            exchangeRate.refreshIfNeed()
            items.forEach{ $0.refresh() }
        }
        
        private func bind() {
            
            weak var welf = self
            Observable.combineLatest(reserveData.value, exchangeRate.value)
                .subscribe(onNext: { (t) in
                    let (reserveData, rate) = t
                    
                    let amount = reserveData.availableLiquidity
                    let coin = welf?.coin ?? .empty
                    if !rate.isUnknown, !amount.isZero {
                        
                        let legalAmount = amount.div10(coin.decimal).mul(rate.value, ThisAPP.CurrencyDecimal)
                        welf?.legalAvailableLiquidity.accept(legalAmount)
                    }
            }).disposed(by: defaultBag)
        }
        
        var apy: String {
            
            var v = reserveData.value.value.liquidityRate
            v = v.isZero ? unknownAmount : String(format: "%.2f", v.div10(18 + 7).d)
            return "\(v)%"
        }
        
        var assetPrice: String {
            return "$\(exchangeRate.value.value.value.thousandth(ThisAPP.CurrencyDecimal))"
        }
        
        var availableLiquidity: String {
            return "\(reserveData.value.value.availableLiquidity.div10(coin.decimal).thousandth()) \(coin.token)"
        }
        
        lazy var headerheight: CGFloat = {
           
            let descHeight = TR("AssetsOverview.Pool").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            let infoHeight = 8.auto() + descHeight + 390.auto()
            let titleHeight = 64.auto() + descHeight
            let listHeight = 58.auto() + CGFloat(items.count * 80.auto())
            let actionHeight: CGFloat = 68.auto()
            return 16.auto() + titleHeight + listHeight + actionHeight
        }()
    }
}
