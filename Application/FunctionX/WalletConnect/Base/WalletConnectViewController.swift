import RxSwift
import TrustWalletCore
import WKKit
extension WKWrapper where Base: WalletConnectViewController {
    var view: Base.View { return base.view as! Base.View }
}

class WalletConnectViewController: WKViewController {
    let url: String
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    override var interactivePopIsEnabled: Bool { false }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bind()
        connect()
    }

    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.action(.title, title: "Wallet Connect")
        navigationBar.hideLine()
    }

    func bind() {
        wk.view.disconnectButton.action { [weak self] in self?.onClickDisconnect() }
    }

    override func onClickBack() { onClickDisconnect() }
    func onClickDisconnect() {
        Router.showDisconnectWalletConnect { [weak self] allow in
            if allow {
                self?.disconnect()
            }
        }
    }

    func getSession() -> WalletConnectSession { fatalError("implementation by subclass") }
    func connect() {
        getSession().connect()
    }

    func disconnect() {
        let session = getSession()
        session.disconnect()
        session.release()
        Router.pop(self)
    }
}
