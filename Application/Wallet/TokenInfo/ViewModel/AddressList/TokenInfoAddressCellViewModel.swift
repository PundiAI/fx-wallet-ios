import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit
import XChains
extension TokenInfoAddressListBinder {
    class CellViewModel {
        init(account: Keypair, coin: Coin) {
            self.coin = coin
            self.account = account
        }

        let coin: Coin
        let account: Keypair
        var address: String { account.address }
        lazy var remark = BehaviorRelay<String>(value: account.remark)
        lazy var balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: coin) ?? .empty
        func refresh() {
            balance.refreshIfNeed()
        }
    }
}
