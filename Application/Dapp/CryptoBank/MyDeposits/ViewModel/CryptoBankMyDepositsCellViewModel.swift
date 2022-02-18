

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankMyDepositsViewController {
    
    class SectionViewModel {
        
        init(wallet: WKWallet, account: Keypair, tokens: [Coin]) {
            self.wallet = wallet
            self.account = account
            
            for token in tokens {
                items.append(CellViewModel(wallet: wallet, account: account, token: token))
            }
            items.last?.isLast = true
        }
        
        let wallet: WKWallet
        let account: Keypair
        
        var items: [CellViewModel] = []
        let height: CGFloat = (24 + 62).auto()
    }
}

extension CryptoBankMyDepositsViewController {
    
    class CellViewModel: RxObject {
        
        init(wallet: WKWallet, account: Keypair, token: Coin) {
            self.token = token
            self.aToken = token.aToken ?? .empty
            self.wallet = wallet
            self.account = account
            super.init()
            
            self.bind()
        }
        
        let token: Coin
        let aToken: Coin
        let wallet: WKWallet
        let account: Keypair
        
        lazy var balance = wallet.balance(of: account.address, coin: aToken)
        lazy var legalBalance = BalanceRelay(legal: true, coin: aToken, address: account.address)
        lazy var reserveData = AAveReserveData.data(of: token)
        private lazy var exchangeRate = token.symbol.exchangeRate()
         
        func refresh() {
            
            balance.refreshIfNeed()
            reserveData.refreshIfNeed()
            exchangeRate.refreshIfNeed()
        }
        
        private func bind() {
            
            weak var welf = self
            let coin = self.token
            Observable.combineLatest(balance.value, exchangeRate.value)
                .subscribe(onNext: { (amount, rate) in
                    
                    if !rate.isUnknown, !amount.isUnknownAmount {
                        welf?.legalBalance.accept(amount.div10(coin.decimal).mul(rate.value, ThisAPP.CurrencyDecimal))
                    }
            }).disposed(by: defaultBag)
        }
        
        var apy: String {
            
            var v = reserveData.value.value.liquidityRate
            v = v.isZero ? unknownAmount : String(format: "%.2f", v.div10(18 + 7).d)
            return "\(v)%"
        }
        
        var isLast = false
        let height: CGFloat = 135.auto()
    }
}
        
