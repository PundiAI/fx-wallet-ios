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
import TrustWalletCore

extension TokenListViewController {
    
    class ViewModel: WKListViewModel<CellViewModel> {
        
        init(_ wallet: Wallet) {
            self.wallet = wallet.wk
            super.init()
            
            self.pager.hasNext = { _ in false }
            self.refreshItems = Action { [weak self] _ -> Observable<[CellViewModel]> in
                guard let this = self else { return Observable.empty() }
                
                for coin in this.wallet.coins {
                    
                    let isNew = this.items.indexOf{ coin.id == $0.coin.id } == nil
                    if isNew {
                        this.items.append(CellViewModel(wallet: this.wallet.rawValue, coin: coin))
                    }
                }
                return .just(this.items)
            }
        }
        
        let wallet: WKWallet
        
        private var refreshBag = DisposeBag()
        let legalAmount = BehaviorRelay<String>(value: "0")
        
        func refresh() {
            
            refreshItems.execute()
                .subscribe(onNext: { [weak self](items) in
                    
                    self?.bindAmount()
                    items.forEach{ $0.refresh() }
            }).disposed(by: defaultBag)
        }
        
        private func bindAmount() {
            
            refreshBag = DisposeBag()
            Observable.combineLatest(items.map{ $0.legalAmount }).subscribe(onNext: { [weak self](amounts) in
                
                var result = "0"
                amounts.forEach{ result = result.add($0) }
                self?.legalAmount.accept(result)
            }).disposed(by: refreshBag)
        }
    }
}
        
