//
//
//  XWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SelectPayAccountViewController {
    
    class AccountListViewModel {

        init(wallet: WKWallet, showRecentAccounts: Bool = true, current: (Coin, Keypair)?, filter: ((Coin, [String: Any]?) -> Bool)? = nil) {
            self.wallet = wallet
            self.filter = filter
            self.current = current
            self.showRecentAccounts = showRecentAccounts
            
            self.loadAccounts()
        }
        
        let wallet: WKWallet
        let filter: ((Coin, [String: Any]?) -> Bool)?
        let current: (Coin, Keypair)?
        let showRecentAccounts: Bool
        
        var items: [AccountSectionViewModel] = []
        
        var coins: [AccountSectionViewModel] = []
        
        var itemsCount = BehaviorRelay<Int>(value: 1)
        
        
        func loadAccounts() {
            
//            if showRecentAccounts, wallet.records.count > 0 {
//                items.append(RecentAccountSectionViewModel(wallet: wallet, current: current, filter: filter))
//            }
             
            var disableItmes: [AccountSectionViewModel] = []
            for coin in wallet.coins {
                
                let item = AccountSectionViewModel(wallet: wallet, coin: coin, current: current, filter: filter)
                
                let bool = filter?(coin, nil) ?? true  
                if item.isEnabled && bool {
                    if item.coin.isETH || item.coin.isERC20 {
                        items.append(item)
                    }
                } else {
                    disableItmes.append(item)
                }
            }
//            items.append(contentsOf: disableItmes)
            
            var enabled = false
            for item in items { enabled = enabled || item.isEnabled }
            if !enabled { items.insert(NoneAccountSectionViewModel(wallet: wallet, coin: .empty, current: nil), at: 0) }
        }
        
        func refresh() {
            items.forEach{ $0.refresh() }
        }
        
        func search(_ input: ControlProperty<String?>) -> Observable<[AccountSectionViewModel]> {

            return input
                .distinctUntilChanged()
                .flatMap{ [weak self] v -> Observable<[AccountSectionViewModel]> in
                    guard let this = self else { return .just([]) }

                    let text = (v ?? "").lowercased()
                    if !text.isEmpty {
                        this.coins = this.items.filter { $0.coin.token.lowercased().contains(text) || $0.coin.name.lowercased().contains(text)}
                    } else {
                        
                        this.coins = this.items
                    }
                    return .just(this.coins)
            }
        }
    }
}
        
