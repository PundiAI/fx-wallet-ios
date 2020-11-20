import RxCocoa
import RxSwift
import WKKit
extension TokenInfoDappListBinder {
    class ViewModel: WKListViewModel<DappCellViewModel> {
        let coin: Coin
        let wallet: WKWallet
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            super.init()
            refreshItems = Action { [weak self] _ -> Observable<[DappCellViewModel]> in
                if coin.isCloud { return .just([]) }
                var items: [DappCellViewModel] = []
                for dapp in wallet.dappManager.apps {
                    if dapp.isExplorer || dapp.isCrossChain || coin.isFunctionX {
                        items.append(DappCellViewModel(dapp: dapp))
                    }
                }
                self?.items = items
                return .just(items)
            }
        }
    }
}
