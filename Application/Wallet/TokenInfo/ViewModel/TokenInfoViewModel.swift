import RxCocoa
import RxSwift
import WKKit
extension TokenInfoPageViewController {
    class ViewModel {
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            dappListVM = TokenInfoDappListBinder.ViewModel(wallet: wallet, coin: coin)
            addressListVM = TokenInfoAddressListBinder.ViewModel(wallet: wallet, coin: coin)
            bind()
        }

        let coin: Coin
        let wallet: WKWallet
        let bag = DisposeBag()
        let dappListVM: TokenInfoDappListBinder.ViewModel
        let addressListVM: TokenInfoAddressListBinder.ViewModel
        lazy var rankText = BehaviorRelay<String>(value: "--")
        lazy var marketText = BehaviorRelay<String>(value: "--")
        lazy var marketSource = BehaviorRelay<String>(value: "")
        lazy var rateText = BehaviorRelay<NSAttributedString?>(value: nil)
        lazy var priceText = BehaviorRelay<String>(value: "$--")
        var balance: BehaviorRelay<String> { addressListVM.balance.value }
        lazy var legalBalance = BalanceRelay(legal: true, coin: coin)
        private lazy var marketRank = coin.symbol.marketRank()
        private lazy var exchangeRate = coin.symbol.exchangeRate()
        lazy var fetchMultiExchangeRate = APIAction(coin.multiExchangeRate())
        func refresh() {
            marketRank.refreshIfNeed()
            exchangeRate.refreshIfNeed()
            fetchMultiExchangeRate.execute()
        }

        private func bind() {
            weak var welf = self
            exchangeRate.value
                .subscribe(onNext: { welf?.priceText.accept("$\($0.value.thousandth(2))") })
                .disposed(by: bag)
            marketRank.value
                .subscribe(onNext: { welf?.handle(rank: $0) })
                .disposed(by: bag)
            Observable.combineLatest(balance, exchangeRate.value)
                .subscribe(onNext: { t in
                    let (balance, rate) = t
                    guard let this = welf, !rate.isUnknown, !balance.isUnknownAmount else { return }
                    let legalBalance = balance.div10(this.coin.decimal).mul(rate.value, 2)
                    welf?.legalBalance.accept(legalBalance)
                }).disposed(by: bag)
        }

        private func handle(rank: FxMarketRank) {
            rankText.accept(rank.value)
            marketText.accept("$\(rank.marketCap.thousandth(2))")
            marketSource.accept(rank.source)
            let formattedRate = format(rate: rank.dailyChange)
            rateText.accept(formattedRate.0)
        }

        private func format(rate: Double) -> (NSAttributedString, UIImage?) {
            let isIncrease = rate >= 0
            let prefix = isIncrease ? "+" : "-"
            let text = NSAttributedString(string: String(format: "\(prefix)%.2f", abs(rate)) + "%", attributes: [.foregroundColor: HDA(isIncrease ? 0x71A800 : 0xFA6237)])

            return (text, nil)
        }
    }
}
