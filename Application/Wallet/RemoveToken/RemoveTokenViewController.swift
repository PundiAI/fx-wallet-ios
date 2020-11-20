import Hero
import RxSwift
import TrustWalletCore
import WKKit
extension RemoveTokenViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let coin = context["coin"] as? Coin else { return nil }
        let vc = RemoveTokenViewController(wallet: wallet, coin: coin)
        return vc
    }
}

class RemoveTokenViewController: FxRegularPopViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet, coin: Coin) {
        self.coin = coin
        self.wallet = wallet.wk
        super.init(nibName: nil, bundle: nil)
    }

    let coin: Coin
    let wallet: WKWallet
    override var dismissWhenTouch: Bool { true }
    override func bindListView() {
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }

    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { _ in
            welf?.dismiss()
        }).disposed(by: cell.defaultBag)
        cell.confirmButton.action {
            guard let this = welf else { return }
            this.wallet.coinManager.remove(this.coin)
            this.wallet.accounts(forCoin: this.coin).clear()
            Router.dismiss(welf) { DispatchQueue.main.async {
                Router.pop(to: "FxTabBarController")
            }
            }
        }
    }

    override func layoutUI() {
        hideNavBar()
    }
}
