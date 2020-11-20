import RxCocoa
import RxSwift
import WKKit
extension NotificationListViewController {
    class ViewModel: RxObject {
        init(_ wallet: WKWallet) {
            self.wallet = wallet
            super.init()
            bind()
        }

        let wallet: WKWallet
        lazy var items: [CellViewModel] = []
        lazy var foldItems: [CellViewModel] = []
        lazy var itemCount = BehaviorRelay<Int>(value: 0)
        lazy var didUpdate = PublishSubject<([CellViewModel], [IndexPath])>()
        lazy var didRemove = PublishSubject<([CellViewModel], [IndexPath])>()
        private func bind() {
            weak var welf = self
            wallet.notifManager.online()
            wallet.notifManager.didRemoveCoin.subscribe(onNext: { coin, _ in
                welf?.remove(coin: coin)
            }).disposed(by: defaultBag)
            wallet.notifManager.didRemoveAccount.subscribe(onNext: { coin, account in
                welf?.remove(coin: coin, account: account)
            }).disposed(by: defaultBag)
            wallet.notifManager.didAddCoin.subscribe(onNext: { coin, _ in
                welf?.items.forEach {
                    if $0.coin?.id == coin.id {
                        $0.didAddCoin()
                    }
                }
                welf?.didUpdate.onNext(([], []))
            }).disposed(by: defaultBag)
        }

        func insert(_ item: FxNotification) {
            let row = 0
            let model = CellViewModel(item)
            items.insert(model, at: row)
            foldItems.insert(model, at: row)
            itemCount.accept(items.count)
        }

        private func remove(_ item: FxNotification) {
            guard let index = items.indexOf(condition: { $0.rawValue.id == item.id }) else { return }
            remove(at: IndexPath(item: index, section: 1))
        }

        func remove(at indexPath: IndexPath) {
            guard indexPath.section == 1, indexPath.row < items.count else { return }
            let item = items[indexPath.row].rawValue
            items.remove(at: indexPath.row)
            itemCount.accept(items.count)
            didRemove.onNext(([], items.count == 0 ? [] : [indexPath]))
            wallet.notifManager.delete(item)
        }

        private func remove(coin: Coin) {
            let count = items.count
            items.removeAll { $0.rawValue.coinId == coin.id }
            if items.count != count {
                itemCount.accept(items.count)
                didRemove.onNext(([], []))
            }
        }

        private func remove(coin: Coin, account: Keypair) {
            let count = items.count
            items.removeAll { $0.rawValue.coinId == coin.id && $0.rawValue.address == account.address }
            if items.count != count {
                itemCount.accept(items.count)
                didRemove.onNext(([], []))
            }
        }

        func add(coin: Coin) {
            wallet.coinManager.add(coin)
        }

        func removeAll() {
            items.removeAll()
            foldItems.removeAll()
            itemCount.accept(items.count)
            didRemove.onNext(([], []))
            wallet.notifManager.deleteAll()
        }

        lazy var refreshItems = Action<Void, [CellViewModel]> { [weak self] _ -> Observable<[CellViewModel]> in
            guard let this = self else { return .empty() }
            return this.fetchItems(page: 0, pageSize: 0)
                .do(onNext: { items in
                    this.items = items
                    this.itemCount.accept(items.count)
                })
        }

        private func fetchItems(page _: Int, pageSize _: Int) -> Observable<[CellViewModel]> {
            return wallet.notifManager.fetchItems.map { $0.map { CellViewModel($0) } }
        }

        public func reloadData() {
            foldItems.removeAll()
            if let first = items.first {
                foldItems.append(first)
            }
        }
    }
}
