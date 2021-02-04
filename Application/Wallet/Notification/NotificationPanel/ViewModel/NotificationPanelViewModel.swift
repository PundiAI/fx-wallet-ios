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

extension NotificationPanelViewController {
    enum LayoutType {
        case fold
        case expand
        case hide
    }
    
    class ViewModel: RxObject {
        
        init(_ wallet: WKWallet, _ listView:UICollectionView) {
            self.wallet = wallet
            self.listView = listView
            super.init()
            self.bind()
        }
        
        let wallet: WKWallet
        var isAll: Bool = true
        let listView: UICollectionView
        
        lazy var items: [CellViewModel] = []
        lazy var foldItems: [CellViewModel] = []
        
        lazy var itemCount = BehaviorRelay<(Int, LayoutType)>(value: (0, .fold))
        
        lazy var didUpdate = PublishSubject<([CellViewModel], [IndexPath])>()
        lazy var didRemove = PublishSubject<([CellViewModel], [IndexPath])>()
        
        var layoutType:LayoutType {
            if listView.collectionViewLayout.isKind(of: NotificationFoldLayout.self) {
                return .fold
            }else if listView.collectionViewLayout.isKind(of: NotificationExpandLayout.self) {
                return .expand
            }else {
                return .hide
            }
        }
         
        private func bind() { 
            weak var welf = self
            wallet.notifManager.online()

            wallet.notifManager.didRemoveCoin.subscribe(onNext: { (coin, _) in
                let layout = welf?.layoutType ?? .fold
                welf?.remove(coin: coin, layout:layout)
            }).disposed(by: defaultBag)
            
            wallet.notifManager.didRemoveAccount.subscribe(onNext: { (coin, account) in
                let layout = welf?.layoutType ?? .fold
                welf?.remove(coin: coin, account: account, layout: layout)
            }).disposed(by: defaultBag)
            
            wallet.notifManager.didAddCoin.subscribe(onNext: { (coin, account) in
                welf?.items.forEach{
                    if $0.coin?.id == coin.id {
                        $0.didAddCoin()
                    }
                }
                welf?.didUpdate.onNext(([], []))
            }).disposed(by: defaultBag)
        }
        
        func insert(_ item: FxNotification, _ layout:LayoutType) {
            let row = 0
            let model = CellViewModel(item)
            items.insert(model, at: row)
            foldItems.insert(model, at: row)
            itemCount.accept( (items.count, layout) )
        }
        
        private func remove(_ item: FxNotification, _ layout:LayoutType) {
            guard let index = items.indexOf(condition: { $0.rawValue.id == item.id }) else { return }
            
            remove(at: IndexPath(item: index, section: 1), layout)
        }
        
        func remove(at indexPath: IndexPath, _ layout:LayoutType) {
            guard indexPath.section == 1, indexPath.row < items.count else { return }
            
            let item = items[indexPath.row].rawValue
            items.remove(at: indexPath.row)
            itemCount.accept((items.count, layout))
            didRemove.onNext(([], items.count == 0 ? [] : [indexPath]))
            
            wallet.notifManager.delete(item)
        }
        
        private func remove(coin: Coin, layout:LayoutType) { 
            let count = items.count
            items.removeAll { $0.rawValue.coinId == coin.id }
            
            if items.count != count {
                itemCount.accept((items.count, layout))
                didRemove.onNext(([], []))
            }
        }
        
        private func remove(coin: Coin, account: Keypair, layout:LayoutType) {
            
            let count = items.count
            items.removeAll { $0.rawValue.coinId == coin.id && $0.rawValue.address == account.address }
            
            if items.count != count {
                itemCount.accept((items.count, layout))
                didRemove.onNext(([], []))
            }
        }
        
        func add(coin: Coin) {
            if coin.isOther { CoinService.current.add(coins: [coin]) }
            wallet.coinManager.add(coin)
        }
        
        func removeAll(layout:LayoutType) {
            items.removeAll()
            foldItems.removeAll()
            itemCount.accept((items.count, layout))
            didRemove.onNext(([], []))
            wallet.notifManager.deleteAll()
        }
        
        //MARK: Network
        func isAll(_ isAll:Bool) -> ViewModel {
            self.isAll = isAll
            return self
        }
        
        lazy var refreshItems = Action<(Bool, LayoutType), [CellViewModel]> { [weak self] (input) -> Observable<[CellViewModel]> in
            guard let this = self else { return .empty() }
            return this.fetchItems(isAll: input.0, page: 0, pageSize: 0)
                .do(onNext: { (items) in
                    this.items = items
                    
                     
                    
                    
                    this.reloadData()
                    this.itemCount.accept((items.count, input.1))
                })
        }
        
        lazy var markAllRead = Action<(Bool, LayoutType), [CellViewModel]> { [weak self] (input) -> Observable<[CellViewModel]> in
            guard let this = self else { return .empty() }
            return this.wallet.notifManager.markAllRead().flatMap {[weak self] (_) -> Observable<[CellViewModel]> in
                guard let this = self else { return .empty() }
                return this.refreshItems.execute(input)
            }
        }
        
        lazy var markRead = Action<(Bool, LayoutType), [CellViewModel]> { [weak self] (input) -> Observable<[CellViewModel]> in
            guard let this = self else { return .empty() }
            return this.wallet.notifManager.markAllRead().flatMap {[weak self] (_) -> Observable<[CellViewModel]> in
                guard let this = self else { return .empty() }
                return this.refreshItems.execute(input)
            }
        }
         
        private func fetchItems(isAll:Bool = true, page: Int, pageSize: Int) -> Observable<[CellViewModel]> {
            if isAll == false {
                return wallet.notifManager.selecteItems(isRead: false).map { $0.map{ CellViewModel($0) }  }
            }
            
            return wallet.notifManager.fetchItems.flatMap({[weak self] (items) -> Observable<[FxNotification]> in
                guard let this = self else { return .just(items) }
                if this.wallet.event.isBackupedValue == false {
                    let fxNotif = FxNotification([:])
                    fxNotif.url = "fxWallet://app/backup"
                    fxNotif.message = TR("Notif.Backup")
                    fxNotif.urlText = TR("Notif.Backup.Security")
                    fxNotif.walletId = FxNotification.globalId
                    fxNotif.timestamp = Int64(Date().timeIntervalSince1970)
                    fxNotif.isRead = false
                    fxNotif.setMustKnown(known: true)
                    
                    
                    var nItems = Array<FxNotification>()
                    nItems.append(fxNotif)
                    nItems.appends(array: items)
                    return .just(nItems)
                }
                return .just(items)
            }).map{ $0.map{ CellViewModel($0) } }
        }
        
        public func reloadData() {
            foldItems.removeAll()
            if let first = items.first {
                foldItems.append(first)
            } 
        }
    }
}
        
