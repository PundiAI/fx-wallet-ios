import RxCocoa
import RxSwift
import WKKit
extension DappPageListViewController {
    class ViewModel {
        init(wallet: Wallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet.wk
            popularListVM = DappPopularListBinder.ViewModel(wallet: wallet, coin: coin)
            favoriteListVM = DappFavoriteListBinder.ViewModel(wallet: wallet, coin: coin)
        }

        let coin: Coin
        let wallet: WKWallet
        let popularListVM: DappPopularListBinder.ViewModel
        let favoriteListVM: DappFavoriteListBinder.ViewModel
    }
}

extension DappPopularListBinder {
    class ViewModel: WKListViewModel<DappCellViewModel> {
        init(wallet: Wallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            super.init()
            pager.hasNext = { _ in false }
            fetchItems = { _ -> Observable<[DappCellViewModel]> in
                Observable.just(DappManager.manager(forWallet: wallet).apps.map { DappCellViewModel(dapp: $0) })
            }
        }

        let coin: Coin
        let wallet: Wallet
    }
}

extension DappFavoriteListBinder {
    class ViewModel: WKListViewModel<DappCellViewModel> {
        init(wallet: Wallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            super.init()
            pager.hasNext = { _ in false }
            refreshItems = Action { [weak self] _ -> Observable<[DappCellViewModel]> in
                let items = DappManager.manager(forWallet: wallet).apps.filter { $0.favorited }.map { DappCellViewModel(dapp: $0) }
                self?.items = items
                return .just(items)
            }
        }

        let coin: Coin
        let wallet: Wallet
    }
}
