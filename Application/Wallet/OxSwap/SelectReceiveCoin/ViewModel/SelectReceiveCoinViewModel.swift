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
import Web3


extension SelectReceiveCoinViewController {
    class ViewModel {
        
        init(_ wallet: WKWallet, filter: Coin?) {
            self.listViewModel = AddCoinListViewModel(wallet, hideAddedItem: false, filter: filter)
        }
        
        let listViewModel: AddCoinListViewModel
    }
}

extension SelectReceiveCoinViewController {
    
    class AddCoinListViewModel {
        
        init(_ wallet: WKWallet, hideAddedItem: Bool = true, filter: Coin?) {
            self.wallet = wallet
            self.hideAddedItem = hideAddedItem
            self.filter = filter
        }
        
        let wallet: WKWallet
        private let hideAddedItem: Bool
        
        var filter: Coin?
        
        var coins: [AddCoinCellViewModel] = []
        
        var items: [AddCoinCellViewModel] = []
        let itemCount = BehaviorRelay<Int>(value: 0)
        
        var didAdded: (() -> Void)?
        
        var isloading = BehaviorRelay<Int>(value: 0)
        
        lazy var fetchCoins = APIAction(loadCoins())
        
        private var refreshBag = DisposeBag()
        
        func search(_ input: ControlProperty<String?>) -> Observable<[AddCoinCellViewModel]> {

            return input
                .distinctUntilChanged()
                .flatMap{ [weak self] v -> Observable<[AddCoinCellViewModel]> in
                    guard let this = self else { return .just([]) }
                    let text = (v ?? "").lowercased()
                    
                    if text.length == 42 {
                        guard let _ = EthereumAddress(hex: text) else {
                            return .just([])
                        }
                        this.isloading.accept(1)
                        return OxCache.tokenMetadata(contract: text, expired: 100).map { (token) -> [AddCoinCellViewModel] in
                            this.items  = [AddCoinCellViewModel(token)]
                            this.isloading.accept(2)
                            return [AddCoinCellViewModel(token)]
                        }
                    }
                    if text.isEmpty {
                        this.items = this.coins
                    } else {
                        this.items = this.coins.filter {
                            $0.rawValue.symbol.lowercased().contains(text)
                                || $0.rawValue.name.lowercased().contains(text)
                        }
                    }
                    guard let _filter =  self?.filter else { return .just(this.items) }
                    this.items = this.items.filter { $0.rawValue.symbol != _filter.symbol }
                    return .just(this.items)
            }
        }

        func loadCoins() -> Observable<[OxToken]> {
            return FxAPIManager.fx.oxTokenList(expired: 3600 * 24).map { [weak self] (items) -> [OxToken] in
                guard let _filter =  self?.filter else { return items }
                return items.filter { (item) -> Bool in
                    item.symbol != _filter.symbol
                }
            }
        }
    }
}
        
