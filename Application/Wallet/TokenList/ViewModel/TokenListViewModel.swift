import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit
extension TokenListViewController {
    class ViewModel: WKListViewModel<CellViewModel> {
        init(_ wallet: WKWallet) {
            self.wallet = wallet
            super.init()
            refreshItems = Action { [weak self] _ -> Observable<[CellViewModel]> in
                guard let this = self else { return Observable.empty() }
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
                return .just(this.items)
            }
            wallet.event.didAddCoin.subscribe(onNext: { [weak self] _ in
                self?.refresh()
            }).disposed(by: defaultBag)
        }

        let wallet: WKWallet
        private var map: [String: CellViewModel] = [:]
        private var refreshBag = DisposeBag()
        lazy var legalBalance = BehaviorRelay<String>(value: UserDefaults.standard.string(forKey: legalBalanceKey) ?? unknownAmount)
        private lazy var legalBalanceKey = "\(wallet.id)_legalBalance"
        func refresh() {
            refreshItems.execute()
                .subscribe(onNext: { [weak self] items in
                    self?.bindBalance()
                    items.forEach { $0.refresh() }
                }).disposed(by: defaultBag)
        }

        private func bindBalance() {
            refreshBag = DisposeBag()
            Observable.combineLatest(items.map { $0.legalBalance.value }).subscribe(onNext: { [weak self] amounts in
                var result = "0"
                amounts.forEach {
                    if !$0.isUnknownAmount { result = result.add($0) }
                }
                self?.legalBalance.accept(result)
                UserDefaults.standard.set(result, forKey: self?.legalBalanceKey ?? "")
            }).disposed(by: refreshBag)
        }

        func exchangeItem(from: Int, to: Int) {
            guard from != to, let item = items.get(from) else { return }
            items.remove(at: from)
            if to > items.count {
                items.append(item)
            } else {
                items.insert(item, at: to)
            }
            wallet.coinManager.reset(items.map { $0.coin })
        }
    }
}
