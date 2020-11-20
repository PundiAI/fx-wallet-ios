import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit
import XChains
extension TokenInfoAddressListBinder {
    class ViewModel: WKListViewModel<CellViewModel> {
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            super.init()
            bind()
        }

        let coin: Coin
        let wallet: WKWallet
        var accounts: AccountList { wallet.accounts(forCoin: coin) }
        private var refreshBag = DisposeBag()
        lazy var balance = BalanceRelay(coin: coin)
        func add(_ account: Keypair) -> Bool {
            let success = accounts.add(account)
            if success { refreshItems.execute() }
            return success
        }

        func remove(_ account: Keypair) -> Bool {
            for (idx, item) in items.enumerated() {
                if item.account.address == account.address {
                    items.remove(at: idx)
                    return true
                }
            }
            return false
        }

        func exchangeItem(from: Int, to: Int) {
            guard from != to, let item = items.get(from) else { return }
            items.remove(at: from)
            if to > items.count {
                items.append(item)
            } else {
                items.insert(item, at: to)
            }
            accounts.reset(items.map { $0.account })
        }

        private func bind() {
            pager.hasNext = { _ in false }
            refreshItems = Action { [weak self] _ -> Observable<[CellViewModel]> in
                guard let this = self else { return Observable.empty() }
                for account in this.wallet.accounts(forCoin: this.coin).accounts {
                    let isNew = this.items.indexOf { account.address == $0.address } == nil
                    if isNew {
                        this.items.append(CellViewModel(account: account, coin: this.coin))
                    }
                }
                self?.bindBalance()
                this.items.forEach { $0.refresh() }
                return .just(this.items)
            }
            XWallet.Event.subscribe(.UpdateAddressRemark, { [weak self] address, _ in
                guard let this = self, let address = address as? String,
                    let item = this.items.first(where: { $0.address == address }) else { return }
                item.remark.accept(item.account.remark)
            }, disposedBy: defaultBag)
        }

        private func bindBalance() {
            refreshBag = DisposeBag()
            Observable.combineLatest(items.map { $0.balance.value }).subscribe(onNext: { [weak self] values in
                guard let this = self else { return }
                var result = "0"
                for v in values {
                    if !v.isUnknownAmount { result = result.add(v, this.coin.decimal) }
                }
                this.balance.accept(result)
            }).disposed(by: refreshBag)
        }
    }
}
