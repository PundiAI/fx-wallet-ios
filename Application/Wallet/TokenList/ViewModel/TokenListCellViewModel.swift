import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit
import XChains
extension TokenListViewController {
    class CellViewModel: RxObject {
        init(wallet: Wallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet.wk
            super.init()
            bind()
        }

        let coin: Coin
        let wallet: WKWallet
        lazy var rateText = BehaviorRelay<NSAttributedString?>(value: nil)
        lazy var priceText = BehaviorRelay<String>(value: "$--")
        lazy var refreshBag = DisposeBag()
        lazy var balance = BalanceRelay(coin: coin)
        lazy var legalBalance = BalanceRelay(legal: true, coin: coin)
        private lazy var marketRank = coin.symbol.marketRank()
        private lazy var fetchBalance = APIAction(refreshAccounts())
        private lazy var exchangeRate = coin.symbol.exchangeRate()
        func refresh() {
            fetchBalance.execute()
            marketRank.refreshIfNeed()
            exchangeRate.refreshIfNeed()
        }

        private func bind() {
            weak var welf = self
            let coin = self.coin
            marketRank.value
                .subscribe(onNext: { welf?.handle(rank: $0) })
                .disposed(by: defaultBag)
            exchangeRate.value
                .subscribe(onNext: { welf?.priceText.accept("$\($0.value.thousandth(2))") })
                .disposed(by: defaultBag)
            Observable.combineLatest(balance.value, exchangeRate.value)
                .subscribe(onNext: { t in
                    let (amount, rate) = t
                    if !rate.isUnknown, !amount.isUnknownAmount {
                        let legalAmount = amount.div10(coin.decimal).mul(rate.value, 2)
                        welf?.legalBalance.accept(legalAmount)
                    }
                }).disposed(by: defaultBag)
        }

        private func handle(rank: FxMarketRank) {
            let isIncrease = rank.dailyChange >= 0
            let prefix = isIncrease ? "+" : "-"
            rateText.accept(NSAttributedString(string: String(format: "\(prefix)%.2f", abs(rank.dailyChange)) + "%",
                                               attributes: [.foregroundColor: HDA(isIncrease ? 0x71A800 : 0xFA6237)]))
        }

        private func refreshAccounts() -> Observable<AccountList> {
            let accounts = Observable<AccountList>.just(wallet.accounts(forCoin: coin))
            return accounts.do(onNext: { [weak self] v in
                guard let this = self else { return }
                let coin = this.coin
                var source: [Balance] = []
                var signals: [BehaviorRelay<String>] = []
                for account in v.accounts {
                    let balance = this.wallet.balance(of: account.address, coin: coin)
                    source.append(balance)
                    signals.append(balance.value)
                }
                this.refreshBag = DisposeBag()
                Observable.combineLatest(signals).subscribe(onNext: { values in
                    var result = "0"
                    for v in values {
                        if !v.isUnknownAmount { result = result.add(v, coin.decimal) }
                    }
                    this.balance.accept(result)
                }).disposed(by: this.refreshBag)
                source.forEach { $0.refreshIfNeed() }
            })
        }
    }
}
