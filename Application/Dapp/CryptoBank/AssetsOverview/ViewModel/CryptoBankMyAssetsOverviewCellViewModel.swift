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
    
    class CellViewModel: RxObject {
        
        init(wallet: WKWallet, coin: Coin, account: Keypair, index: Int) {
            self.coin = coin
            self.index = index
            self.wallet = wallet
            self.account = account
            super.init()
            
            self.bind()
        }
        
        let coin: Coin
        let index: Int
        let wallet: WKWallet
        let account: Keypair
        let height: CGFloat = (332 + 24).auto()
        
        lazy var balance = wallet.balance(of: account.address, coin: coin)
        lazy var legalBalance = BalanceRelay(legal: true, coin: coin, address: account.address)
        
        lazy var aTokenBalance = wallet.balance(of: account.address, coin: coin.aToken ?? .empty)
        lazy var aTokenLegalBalance = BalanceRelay(legal: true, coin: coin.aToken ?? .empty, address: account.address)
        private lazy var exchangeRate = coin.symbol.exchangeRate()
         
        func refresh() {
            
            balance.refreshIfNeed()
            aTokenBalance.refreshIfNeed()
            exchangeRate.refreshIfNeed()
        }
        
        private func bind() {
            
            weak var welf = self
            Observable.combineLatest(balance.value, exchangeRate.value)
                .subscribe(onNext: { (t) in
                    if let value = welf?.legalBalance(t) {
                        welf?.legalBalance.accept(value)
                    }
            }).disposed(by: defaultBag)
            
            Observable.combineLatest(aTokenBalance.value, exchangeRate.value)
                .subscribe(onNext: { (t) in
                    if let value = welf?.legalBalance(t) {
                        welf?.aTokenLegalBalance.accept(value)
                    }
            }).disposed(by: defaultBag)
        }
        
        private func legalBalance(_ t: (String, FxExchangeRate)) -> String? {
            
            let (amount, rate) = t
            if !rate.isUnknown, !amount.isUnknownAmount {
                return amount.div10(coin.decimal).mul(rate.value, ThisAPP.CurrencyDecimal)
            }
            return nil
        }
        
    }
}
        
