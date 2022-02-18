

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
        
        let delegateAmount = BehaviorRelay<String>(value: unknownAmount)
        var fxcReward = BehaviorRelay<String>(value: unknownAmount)
        var fxUSDReward = BehaviorRelay<String>(value: unknownAmount)
        lazy var balance = wallet.balance(of: account.address, coin: coin)
        
        lazy var refreshAction = APIAction(workFactory: {[weak self] _ -> Observable<[Validator]> in
            guard let this = self else { return .empty() }
            
            self?.balance.refreshIfNeed()
            return FxAPIManager.fx.fetchValidators(of: this.account.address)
                .do(onNext: { [weak self] result in
                    guard let this = self, result.count > 0 else { return }
                
                    var amount = "0"
                    var fxcReward = "0"
                    var fxUSDReward = "0"
                    for validator in result {
                        
                        amount = amount.add(validator.delegateAmount)
                        fxcReward = fxcReward.add(validator.reward(of: this.coin.symbol))
                        fxUSDReward = fxUSDReward.add(validator.reward(of: Coin.FxUSDSymbol))
                        if let item = this.map[validator.validatorAddress] {
                            item.validator = validator
                        } else {
                            let item = CellViewModel(wallet: this.wallet, coin: this.coin, account: this.account, validator: validator)
                            this.map[validator.validatorAddress] = item
                            this.items.append(item)
                        }
                    }
                    this.fxcReward.accept(fxcReward)
                    this.fxUSDReward.accept(fxUSDReward)
                    this.delegateAmount.accept(amount)
                    this.items.last?.isLast = true
            })
        })
        
        let height: CGFloat = (62 + 16).auto()
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
        let height: CGFloat = (298 + 16).auto()
    }
}
        
