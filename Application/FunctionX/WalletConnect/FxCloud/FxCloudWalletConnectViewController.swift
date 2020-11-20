import RxSwift
import TrustWalletCore
import WKKit
extension FxCloudWalletConnectViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let url = context["url"] as? String,
            let wallet = context["wallet"] as? Wallet
        else {
            return nil
        }
        return FxCloudWalletConnectViewController(url: url, wallet: wallet)
    }
}

class FxCloudWalletConnectViewController: WalletConnectViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(url: String, wallet: Wallet) {
        let url = url.replacingOccurrences(of: "FXSocket:", with: "")
        self.wallet = wallet
        super.init(url: url)
    }

    let wallet: Wallet
    override func bind() {
        let view = wk.view

        session.error.asDriver().drive(onNext: { [weak self] error in
            guard error != nil, self?.navigationController?.topViewController == self else { return }
            self?.navigationController?.popViewController(animated: true)
            self?.navigationController?.topViewController?.hud?.text(m: error?.localizedDescription ?? "")
        }).disposed(by: defaultBag)
    }

    private var session: FxCloudWalletConnectSession { getSession() as! FxCloudWalletConnectSession }
    private var sessionId: String { "CloudWidget" }
    override func getSession() -> WalletConnectSession {
        if let session: FxCloudWalletConnectSession = WalletConnectSession.session(forId: sessionId) {
            session.disconnect()
            session.release()
        }
        let session = FxCloudWalletConnectSession(id: sessionId, url: url, wallet: wallet)
        session.viewController = self
        session.retain()
        return session
    }
}
