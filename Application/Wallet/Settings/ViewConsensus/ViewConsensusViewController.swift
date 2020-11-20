import FunctionX
import WKKit
extension ViewConsensusViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet else { return nil }
        return ViewConsensusViewController(wallet: wallet)
    }
}

class ViewConsensusViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }

    let wallet: Wallet
    override var preferFullTransparentNavBar: Bool { return true }
    override func loadView() {
        let view = View(frame: ScreenBounds)
        self.view = view
        logWhenDeinit()
        view.startButton.action { [weak self] in
            self?.showKeypairIfAllow()
        }
    }

    private func showKeypairIfAllow() {
        Router.showFxValidatorSelectKeypairAlert(wallet: wallet.wk, dapp: .functionX) { [weak self] vc, keypair in
            vc?.dismiss(animated: false, completion: {
                Router.showVerifyPasswordAlert { error in
                    guard error == nil else { return }

                    Router.currentNavigator?.pushViewController(ViewConsensusCompletedViewController(keypair: keypair), animated: true)
                    Router.currentNavigator?.remove([self])
                }
            })
        }
    }
}

class ViewConsensusCompletedViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(keypair: Keypair) {
        self.keypair = keypair
        super.init(nibName: nil, bundle: nil)
    }

    let keypair: Keypair
    override var preferFullTransparentNavBar: Bool { return true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = self.view as! View
        let keypair = FunctionXValidatorKeypair(self.keypair.privateKey)
        view.publicKeyLabel.text = keypair.encodedPublicKey()
        view.privateKeyLabel.text = keypair.privateKey.hexString
        weak var welf = self
        view.doneButton.action { welf?.navigationController?.popViewController(animated: true) }
        view.copyPublicKeyButton.action { welf?.copy(string: view.publicKeyLabel.text) }
        view.copyPrivateKeyButton.action { welf?.copy(string: view.privateKeyLabel.text) }
        let publicKeyH = (view.publicKeyLabel.text ?? "").height(ofWidth: ScreenWidth - 106 - 43 - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium)])
        let privateKeyH = (view.privateKeyLabel.text ?? "").height(ofWidth: ScreenWidth - 106 - 43 - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium)])
        let keypairHeight = 10 + 20 + publicKeyH + 16 + privateKeyH + 20
        view.keypairBackground.snp.updateConstraints { make in
            make.height.equalTo(keypairHeight)
        }
    }

    private func copy(string: String?) {
        UIPasteboard.general.string = string
        hud?.text(m: TR("Copied"))
    }
}
