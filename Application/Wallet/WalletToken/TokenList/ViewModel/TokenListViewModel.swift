

import WKKit
import RxSwift
import RxCocoa
import TrustWalletCore

extension TokenListViewController {
    
    class ViewModel: WKListViewModel<CellViewModel> {
        
        init(_ wallet: WKWallet) {
            self.wallet = wallet
            super.init()
            
            self.refreshItems = Action { [weak self] _ in
                return self?.reloadItemsIfNeed() ?? .error(WKError.default)
            }
            
            self.preload()
            self.bind()
        }
        
        let wallet: WKWallet
        private var map: [String: CellViewModel] = [:]
        private(set) var displayItems: [SectionViewModel] = []
        
        private var refreshBag = DisposeBag()
        lazy var legalBalance = BalanceRelay.legalBalance(of: wallet)
        
        private var service: CoinService { .current }
        
        func refresh() {
            
            refreshItems.execute()
                .subscribe(onNext: { [weak self](items) in
                    
                    self?.bindBalance()
                    items.forEach{ $0.refresh() }
            }).disposed(by: defaultBag)
        }
        
        private func bind() {
            
            wallet.event.didAddCoin.subscribe(onNext: { [weak self](_) in
                self?.refresh()
            }).disposed(by: defaultBag)
            
            if service.needSync {
                
                service.didSync
                    .filter{ $0 }
                    .take(1)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [weak self](_) in
                        
                        self?.map.removeAll()
                        self?.items.removeAll()
                        self?.displayItems.removeAll()
                        self?.wallet.coinManager.reload()
                        self?.refresh()
                }).disposed(by: defaultBag)
            }
        }
        
        private func reloadItemsIfNeed() -> Observable<[CellViewModel]>  {
            guard service.readyForDisplay else { return .error(WKError(.default, "coinService not ready")) }
            
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
            
            let sections = [SectionViewModel(coin: service.btc ?? .empty),
                            SectionViewModel(coin: service.ethereum),
                            SectionViewModel(coin: service.bnb ?? .empty),
                            SectionViewModel(coin: service.bsc_bnb ?? .empty),
                            SectionViewModel(coin: service.fxCore),
                            SectionViewModel(coin: service.payc)]
            
            for item in self.items {
                
                for section in sections {
                    if section.coin.chainType == item.coin.chainType {
                        section.add(item)
                        break
                    }
                }
            }
            
            for section in sections {
                if section.items.isNotEmpty { displayItems.append(section) }
            }
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
                
                if !fromItem.coin.isEmpty && !toItem.coin.isEmpty {
                    wallet.coinManager.reset(items.map{ $0.coin }, reIndex: false)
                }
            }
        }
        
        //MARK: Preload
        private func preload() {
            if service.didSync.value { return }
            if NodeManager.shared.currentEthereumNode.isMainnet { return }
            
            let id = Coin.empty.currencyId
            let section = SectionViewModel(coin: .ethereum)
            let eth = Coin(id: id, chain: .ethereum_kovan, type: 60, name: "Ethereum", symbol: "ETH", decimal: 18, symbolId: 0, imgUrl: "https://cdn.mytoken.org/FvKK2xxE7DNqbKHA9Dle2FPheJJe")
            let npxs = Coin(id: id, chain: .ethereum_kovan, type: 60, name: "Pundi X Token", symbol: "NPXS", decimal: 18, contract: "0x9ED87454b3FF198D57f91e584070b865c6503B3b", symbolId: 0, imgUrl: "https://cdn.mytoken.org/Fs4R1VIJ9Zn6S_OsdyH07gGJNj01")
            let fx = Coin(id: id, chain: .ethereum_kovan, type: 60, name: "Function X", symbol: "FX", decimal: 18, contract: "0xc5229C5199d8A306c3f7b4CA43122F684F23f6E6", symbolId: 0, imgUrl: "https://cdn.mytoken.org/Fq8v7Z5k9mgdzwj0thBBK4Pf_nrh")
            
            for coin in [eth, npxs, fx] {
                let item = CellViewModel(wallet: wallet.rawValue, coin: coin)
                items.append(item)
                section.add(item)
            }
            self.displayItems = [section]
        }
    }
}
        
