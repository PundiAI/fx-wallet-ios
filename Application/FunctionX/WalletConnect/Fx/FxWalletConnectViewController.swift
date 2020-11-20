import RxSwift
import TrustWalletCore
import WKKit
extension FxWalletConnectViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let url = context["url"] as? String,
            let wallet = context["wallet"] as? WKWallet
        else {
            return nil
        }
        return FxWalletConnectViewController(url: url, wallet: wallet)
    }
}

class FxWalletConnectViewController: WalletConnectViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(url: String, wallet: WKWallet) {
        self.wallet = wallet
        super.init(url: url)
    }

    let wallet: WKWallet
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    override func bind() {
        super.bind()
        weak var welf = self
        session.didApproveSession
            .take(1)
            .subscribe(onNext: { approved in
                if approved {
                    welf?.bindListView()
                } else {
                    welf?.disconnect()
                }
            }).disposed(by: defaultBag)
    }

    private func bindListView() {
        wk.view.didConnect(true)
        listBinder.push(DappCell.self, vm: session.dapp)
        listBinder.push(WCInfoCell.self, vm: WCInfoCellViewModel(title: TR("WalletConnect.TSelectAddress"), subtitle: session.account.address))
        listBinder.push(WCInfoCell.self, vm: WCInfoCellViewModel(title: TR("WalletConnect.TSignedTxCount"), subtitle: "0"))
    }

    private var session: FxWalletConnectSession { getSession() as! FxWalletConnectSession }
    private var sessionId: String { "Fx" }
    override func getSession() -> WalletConnectSession {
        if let session: FxWalletConnectSession = WalletConnectSession.session(forId: sessionId) {
            if session.url == url {
                return session
            } else {
                session.disconnect()
                session.release()
            }
        }
        let session = FxWalletConnectSession(id: sessionId, url: url, wallet: wallet)
        session.retain()
        session.viewController = self
        return session
    }
}
