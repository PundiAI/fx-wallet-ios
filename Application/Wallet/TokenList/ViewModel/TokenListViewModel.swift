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
        
        init(_ wallet: WKWallet) {
            self.wallet = wallet
            super.init()
            
            self.refreshItems = Action { [weak self] _ -> Observable<[CellViewModel]> in
                guard let this = self else { return Observable.empty() }
                
                let service = CoinService.current
                let needSync = service.needSync && NodeManager.shared.currentEthereumNode.isTestnet
                if !needSync {
                    return this.reloadItemsIfNeed()
                } else {
                    
                    return service.fetchLatestItems()
                        .catchErrorJustReturn((0, []))
                        .flatMap{ t -> Observable<[CellViewModel]> in
                        
                            if t.coinList.count > 0 {
                                service.sync(batchNum: t.batchNum, items: t.coinList)
                                this.wallet.coinManager.reload()
                            }
                        return this.reloadItemsIfNeed().delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
                    }
                }
            }
            
            wallet.event.didAddCoin.subscribe(onNext: { [weak self](_) in
                self?.refresh()
            }).disposed(by: defaultBag)
        }
        
        let wallet: WKWallet
        private var map: [String: CellViewModel] = [:]
        private(set) var displayItems: [SectionViewModel] = []
        
        private var refreshBag = DisposeBag()
        lazy var legalBalance = BalanceRelay.legalBalance(of: wallet)
        
        func refresh() {
            
            refreshItems.execute()
                .subscribe(onNext: { [weak self](items) in
                    
                    self?.bindBalance()
                    items.forEach{ $0.refresh() }
            }).disposed(by: defaultBag)
        }
        
        private func reloadItemsIfNeed() -> Observable<[CellViewModel]>  {
            
            let this = self
            for coin in this.wallet.coins {
                guard this.map[coin.id] == nil else { continue }
                
                let item = CellViewModel(wallet: this.wallet.rawValue, coin: coin)
                this.map[coin.id] = item
                this.items.append(item)
            }
            
            let temp = this.items
            for (idx, item) in temp.enumerated() {
                guard !this.wallet.coinManager.has(item.coin) else { continue }
                
                this.map[item.coin.id] = nil
                this.items.remove(at: idx)
            }
            this.indexCoinList()
            return .just(this.items)
        }
        
        private func indexCoinList() {
            
            displayItems.removeAll()
            let service = CoinService.current
            let btc = SectionViewModel(coin: service.btc ?? .empty)
            let eth = SectionViewModel(coin: service.ethereum)
            let fx = SectionViewModel(coin: service.functionX)
            for item in self.items {
                if item.coin.isBTC { btc.add(item) }
                else if item.coin.isEthereum { eth.add(item) }
                else if item.coin.isFunctionX { fx.add(item) }
            }
            
            if btc.items.isNotEmpty { displayItems.append(btc) }
            if eth.items.isNotEmpty { displayItems.append(eth) }
            if fx.items.isNotEmpty { displayItems.append(fx) }
        }
        
        private func bindBalance() {
             
            refreshBag = DisposeBag()
            Observable.combineLatest(items.map{ $0.legalBalance.value }).subscribe(onNext: { [weak self](amounts) in
                
                var result = "0"
                amounts.forEach{
                    if !$0.isUnknownAmount { result = result.add($0) }
                }
                self?.legalBalance.accept(result)
            }).disposed(by: refreshBag)
        }
        
        func exchangeItem(from: IndexPath, to: IndexPath) {
            guard from.section == to.section,
                  from.row != to.row,
                  let section = displayItems.get(from.section),
                  let toItem = section.items.get(to.row),
                  let fromItem = section.items.get(from.row) else { return }
            
            section.items.remove(at: from.row)
            if to.row > section.items.count {
                section.items.append(fromItem)
            } else {
                section.items.insert(fromItem, at: to.row)
            }
            
            if let toIdx = items.indexOf(condition: { $0.coin.id == toItem.coin.id }),
               let fromIdx = items.indexOf(condition: { $0.coin.id == fromItem.coin.id }) {
             
                items.remove(at: fromIdx)
                if toIdx > items.count {
                    items.append(fromItem)
                } else {
                    items.insert(fromItem, at: toIdx)
                }
                wallet.coinManager.reset(items.map{ $0.coin }, reIndex: false)
            }
        }
    }
}
        
