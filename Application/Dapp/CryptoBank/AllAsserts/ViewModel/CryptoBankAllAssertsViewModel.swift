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

extension CryptoBankAllAssertsViewController {
    class ViewModel {
        
        init(_ wallet: WKWallet) {
            
            let listViewModel = ListViewModel(wallet)
            self.listViewModel = listViewModel
            self.searchListViewModel = SearchListViewModel(wallet, listViewModel.items)
        }
        
        let listViewModel: ListViewModel
        let searchListViewModel: SearchListViewModel
        
        func refresh() {
            listViewModel.refresh()
        }
    }
}

extension CryptoBankAllAssertsViewController {
    
    class ListViewModel {
        
        init(_ wallet: WKWallet) {
            self.wallet = wallet
            
            self.items = AAve.current.tokens.map{ CryptoBankAssetCellViewModel(coin: $0) }
        }
        
        let wallet: WKWallet
        var items: [CryptoBankAssetCellViewModel] = []
        
        func refresh() {
            items.forEach{ $0.reserveData.refreshIfNeed() }
        }
    }
}


extension CryptoBankAllAssertsViewController {
    
    class SearchListViewModel {
        
        init(_ wallet: WKWallet, _ items: [CryptoBankAssetCellViewModel]) {
            self.wallet = wallet
            self.allItems = items
        }
        
        let wallet: WKWallet
        private var allItems: [CryptoBankAssetCellViewModel] = []
        
        var items: [CryptoBankAssetCellViewModel] = []
        let itemCount = BehaviorRelay<Int>(value: 0)
        
        func search(_ input: ControlProperty<String?>) -> Observable<[CryptoBankAssetCellViewModel]> {
            
            return input
                .distinctUntilChanged()
                .flatMap{ [weak self] v -> Observable<[CryptoBankAssetCellViewModel]> in
                    guard let this = self else { return .just([]) }
                    
                    let text = (v ?? "").lowercased()
                    if text.isEmpty {
                        this.items = this.allItems
                    } else {
                        this.items = this.allItems.filter {
                            $0.coin.symbol.lowercased().contains(text)
                                || $0.coin.name.lowercased().contains(text)
                        }
                    }
                    this.itemCount.accept(this.items.count)
                    return .just(this.items)
            }
        }
    }
}
