import RxCocoa
import RxSwift
import WKKit
extension WKWrapper where Base == BackUpNowViewController {
    var view: BackUpNowViewController.View { return base.view as! BackUpNowViewController.View }
}

extension BackUpNowViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = BackUpNowViewController(wallet: wallet)
        return vc
    }
}

class BackUpNowViewController: WKViewController {
    private let wallet: WKWallet
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindAction()
        logWhenDeinit()
    }

    private func bindAction() {
        wk.view.backUpButton.action { [weak self] in
            guard let wallet = XWallet.sharedKeyStore.currentWallet else {
                self?.hud?.text(m: TR("--"), p: .topCenter)
                return
            }
            wallet.wk.createCompleted = .completed
            Router.pushToBackUpNotice(wallet: wallet.wk) { vc in
                Router.setRootController(wallet: wallet,
                                         viewControllers: [vc])
            }
        }
        wk.view.notNowButton.action { [weak self] in
            self?.goWallet()
        }
        wk.view.closeButton.action {
            Router.showBackAlert()
        }
    }

    @objc private func goWallet() {
        guard let wallet = XWallet.sharedKeyStore.currentWallet else {
            hud?.text(m: TR("--"), p: .topCenter)
            return
        }
        wallet.wk.createCompleted = .completed
        Router.resetRootController(wallet: wallet, animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension BackUpNowViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { switch (from, to) {
    case ("SecurityTypeViewController", "BackUpNowViewController"): return animators["0"]
    default: return nil
    }
    }

    private func bindHero() { weak var welk = self
        animators["0"] = WKHeroAnimator({ _ in
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.backUpButton.hero.modifiers = [.fade, .translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.notNowButton.hero.modifiers = [.fade, .translate(x: 1000), .useGlobalCoordinateSpace]
        }, onSuspend: { _ in
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.subtitleLabel.hero.modifiers = nil
            welk?.wk.view.backUpButton.hero.modifiers = nil
            welk?.wk.view.notNowButton.hero.modifiers = nil
        })
    }
}
