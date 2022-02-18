

import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON

extension NotificationPanelViewController {
    enum LayoutType {
        case fold
        case expand
        case hide
    }
    
    struct UpdateModel {
        let items:[CellViewModel]
        let indexPath:[IndexPath]
        let update:(()->Void)?
        let complated:(()->Void)?
        
        init(_ items:[CellViewModel], _ indexPath:[IndexPath], _ update:(()->Void)? = nil ,_ complated:(()->Void)? = nil) {
            self.items = items
            self.indexPath = indexPath
            self.complated = complated
            self.update = update
        }
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
        lazy var didUpdate = PublishSubject<UpdateModel>()
        lazy var didRemove = PublishSubject<UpdateModel>()
        
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
            
            CoinService.current.didSync
                .filter{ $0 }
                .take(1)
                .subscribe(onNext: { _ in
                    welf?.wallet.notifManager.online()
            }).disposed(by: defaultBag)

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
                welf?.didUpdate.onNext(UpdateModel([], []))
            }).disposed(by: defaultBag)
            
            wallet.notifManager.deleteRaw.subscribe(onNext: { (fxNot) in
                let layout = welf?.layoutType ?? .fold
                welf?.remove(fxNot, layout)
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
         
        func remove(at indexPath: IndexPath, _ layout:LayoutType, _ complated:(()->Void)? = nil) {
            guard indexPath.section == 1, indexPath.row < items.count else { return } 
            let item = items[indexPath.row].rawValue
            
            let count = items.count - 1
            itemCount.accept((count, layout))
            let indexPaths = count == 0 ? [] : [indexPath]
            let action = UpdateModel([], indexPaths, { [weak self] in
                guard let this = self else {return}
                if indexPath.row >= 0, indexPath.row < this.items.count {
                    self?.items.remove(at: indexPath.row)
                } 
            } , complated)
            didRemove.onNext(action)
            wallet.notifManager.delete(item)
        }
        
        private func remove(coin: Coin, layout:LayoutType) { 
            let count = items.count
            items.removeAll { $0.rawValue.coinId == coin.id }
            
            if items.count != count {
                itemCount.accept((items.count, layout))
                didRemove.onNext(UpdateModel([], []))
            }
        }
        
        private func remove(coin: Coin, account: Keypair, layout:LayoutType) {
            
            let count = items.count
            items.removeAll { $0.rawValue.coinId == coin.id && $0.rawValue.address == account.address }
            
            if items.count != count {
                itemCount.accept((items.count, layout))
                didRemove.onNext(UpdateModel([], []))
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
            didRemove.onNext(UpdateModel([], []))
            wallet.notifManager.deleteAll()
        }
        
        //MARK: Network
        func isAll(_ isAll:Bool) -> ViewModel {
            self.isAll = isAll
            return self
        }
        
        lazy var refreshItems = Action<(Bool, LayoutType), [CellViewModel]> { [weak self] (input) -> Observable<[CellViewModel]> in
            guard let this = self else { return .empty() }
            return this.fetchItems(isAll: input.0, page: 0, pageSize: 0).observeOn(MainScheduler.instance)
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
                    var nItems = Array<FxNotification>()
                    nItems.append(FxNotification.backup)
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
