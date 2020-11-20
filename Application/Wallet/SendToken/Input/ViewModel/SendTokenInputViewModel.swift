import BigInt
import FunctionX
import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit
import XChains
extension SendTokenInputViewController {
    class ViewModel: WKListViewModel<Coin> {
        init(wallet: WKWallet, coin: Coin, account: Keypair? = nil, receiver: User? = nil) {
            let account = account ?? wallet.accounts(forCoin: coin).recommend
            self.wallet = wallet
            self.receiver = receiver
            selectedToken = BehaviorRelay(value: coin)
            selectedAccount = BehaviorRelay(value: account)
            super.init()
            pager.hasNext = { _ in false }
            fetchItems = { _ -> Observable<[Coin]> in
                Observable.just(wallet.coins)
            }
            bind()
        }

        let wallet: WKWallet
        var receiver: User?
        let selectedToken: BehaviorRelay<Coin>
        let selectedAccount: BehaviorRelay<Keypair>
        var coin: Coin { selectedToken.value }
        let isUSD = BehaviorRelay<Bool>(value: false)
        private var refreshBag = DisposeBag()
        let rate = BehaviorRelay<String>(value: unknownAmount)
        let ready = BehaviorRelay<Bool>(value: false)
        let balance = BehaviorRelay<String>(value: unknownAmount)
        let legalBalance = BehaviorRelay<String>(value: unknownAmount)
        var availableBalance = "0"
        func select(_ token: Coin, account: Keypair) {
            let coinChaged = token.id != selectedToken.value.id
            let accountChaged = account.address != selectedAccount.value.address
            if coinChaged { selectedToken.accept(token) }
            if coinChaged || accountChaged { selectedAccount.accept(account) }
        }

        private func bind() {
            weak var welf = self
            selectedAccount.subscribe(onNext: { _ in
                welf?.fetchBalance()
            }).disposed(by: defaultBag)
            isUSD.subscribe(onNext: { _ in
                welf?.updateAvailableBalance()
            }).disposed(by: defaultBag)
        }

        private func fetchBalance() {
            refreshBag = DisposeBag()
            rate.accept(unknownAmount)
            ready.accept(false)
            balance.accept(unknownAmount)
            legalBalance.accept(unknownAmount)
            availableBalance = "0"
            weak var welf = self
            let coin = selectedToken.value
            Observable.combineLatest(balance, rate)
                .subscribe(onNext: { [weak self] t in
                    let (balance, rate) = t
                    if balance.isUnknownAmount || rate.isUnknownAmount { return }
                    self?.legalBalance.accept(balance.div10(coin.decimal).mul(rate, coin.decimal))
                    self?.updateAvailableBalance()
                    self?.ready.accept(true)
                }).disposed(by: refreshBag)
            coin.symbol.toUSDT()
                .subscribe(onNext: { welf?.rate.accept($0) })
                .disposed(by: refreshBag)
            wallet.balance(of: selectedAccount.value.address, coin: coin)
                .refresh()
                .subscribe(onNext: {
                    welf?.balance.accept($0)
                    welf?.updateAvailableBalance()
                })
                .disposed(by: refreshBag)
        }

        private func updateAvailableBalance() {
            availableBalance = isUSD.value ? legalBalance.value : balance.value.div10(coin.decimal)
        }
    }
}
