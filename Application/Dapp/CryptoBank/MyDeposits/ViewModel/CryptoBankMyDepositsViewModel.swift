

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankMyDepositsViewController {
    
    class ViewModel: RxObject {
        
        init(wallet: WKWallet) {
            self.wallet = wallet
            super.init()
            
            self.load()
            self.bind()
        }
        
        let wallet: WKWallet
        var items: [SectionViewModel] = []
        lazy var totalBalance = BalanceRelay.aaveTotalBalance(of: wallet)
        
        func refresh() {
            items.forEach{ $0.items.forEach{ $0.refresh() } }
        }
        
        private func load() {
            
            var accounts: [Keypair] = []
            var tokens: [String: [Coin]] = [:]
            for coin in AAve.current.tokens {
                
                if wallet.coinManager.has(coin) {
                    
                    for account in wallet.accounts(forCoin: coin).accounts {
                        
                        if tokens[account.address] == nil {
                            tokens[account.address] = []
                            accounts.append(account)
                        }
                        tokens[account.address]?.append(coin)
                    }
                }
            }
            
            for account in accounts {
                items.append(SectionViewModel(wallet: wallet, account: account, tokens: tokens[account.address] ?? []) )
            }
        }
        
        private func bind() {
            
            var legalBalances: [BehaviorRelay<String>] = []
            for section in items {
                legalBalances.appends(array: section.items.map{ $0.legalBalance.value })
            }
            
            Observable.combineLatest(legalBalances).subscribe(onNext: { [weak self] (values) in
                guard let this = self else { return }
                
                var result = "0"
                for v in values {
                    if !v.isUnknownAmount { result = result.add(v, ThisAPP.CurrencyDecimal) }
                }
                this.totalBalance.accept(result)
            }).disposed(by: defaultBag)
        }
    }
}
        



