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

extension FxMyDelegatesViewController {
    
    class SectionViewModel {
        
        init(wallet: WKWallet, coin: Coin, account: Keypair) {
            self.coin = coin
            self.wallet = wallet
            self.account = account
        }
        
        let coin: Coin
        let wallet: WKWallet
        let account: Keypair
        
        private var map: [String: CellViewModel] = [:]
        var items: [CellViewModel] = []
        var amount = ""
        
        lazy var refreshAction = APIAction(request())
        private func request() -> Observable<[Validator]> {
            
            return FxAPIManager.fx.fetchValidators(of: account.address)
                .do(onNext: { [weak self] result in
                    guard let this = self, result.count > 0 else { return }
                
                    var amount = "0"
                    for validator in result {
                        
                        amount = amount.add(validator.delegateAmount)
                        if let item = this.map[validator.validatorAddress] {
                            item.validator = validator
                        } else {
                            let item = CellViewModel(wallet: this.wallet, coin: this.coin, account: this.account, validator: validator)
                            this.map[validator.validatorAddress] = item
                            this.items.append(item)
                        }
                    }
                    this.amount = amount.div10(this.coin.decimal).thousandth()
                    this.items.last?.isLast = true
            })
        }
        
        let height: CGFloat = 62.auto()
    }
}

extension FxMyDelegatesViewController {
    
    class CellViewModel {
        
        init(wallet: WKWallet, coin: Coin, account: Keypair, validator: Validator) {
            self.coin = coin
            self.wallet = wallet
            self.account = account
            self.validator = validator
        }
        
        let coin: Coin
        let wallet: WKWallet
        let account: Keypair
        fileprivate(set) var validator: Validator
        
        var isLast = false
        let height: CGFloat = 120.auto()
    }
}
        
