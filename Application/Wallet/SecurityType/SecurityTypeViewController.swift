import RxCocoa
import RxSwift
import WKKit
extension WKWrapper where Base == SecurityTypeViewController {
    var view: SecurityTypeViewController.View { return base.view as! SecurityTypeViewController.View }
}

extension SecurityTypeViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = SecurityTypeViewController(wallet: wallet)
        return vc
    }
}

class SecurityTypeViewController: WKViewController { private let wallet: WKWallet
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        bind()
        logWhenDeinit()
        if !LocalAuthManager.shared.isEnabled {
            wk.view.bioUse(b: true)
        }
    }

    private func bind() {
        wk.view.createControl.action { [weak self] in
            self?.goFaceID()
        }
        wk.view.importControl.action { [weak self] in
            self?.goPassword()
        }
        wk.view.closeButton.action {
            Router.showBackAlert()
        }
    }

    private func goFaceID() {
        enableBiometrics()
    }

    private func goPassword() { Router.showFirstSetPwdAlert(wallet: wallet) { [weak self] error in
        guard error == nil else { return }
        guard let wallet = self?.wallet else { return }
        if let type = wallet.registerType, type == .importT {
            wallet.createCompleted = .completed
            wallet.isBackuped = true
            Router.resetRootController(wallet: wallet.rawValue, animated: true)
        } else {
            DispatchQueue.main.async {
                Router.pushToBackUpNow(wallet: wallet)
            }
        }
    }
    }

    @objc private func enableBiometrics() {
        Router.showSetBioAlert { [weak self] error in
            guard let wallet = self?.wallet else { return }
            guard let this = self else { return }
            if error == nil {
                this.wallet.createCompleted = .setSecurity
                LocalAuthManager.shared.userAllowed = true
                if let type = wallet.registerType, type == .importT {
                    wallet.createCompleted = .completed
                    wallet.isBackuped = true
                    Router.resetRootController(wallet: wallet.rawValue, animated: true)
                } else {
                    Router.pushToBackUpNow(wallet: wallet)
                }
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension SecurityTypeViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { switch (from, to) {
    case ("SetNickNameViewController", "SecurityTypeViewController"): return animators["0"]
    case ("ImportNamedViewController", "SecurityTypeViewController"): return animators["0"]
    case ("SecurityTypeViewController", "BackUpNowViewController"): return animators["1"]
    default: return nil
    }
    }

    private func bindHero() { weak var welk = self
        animators["0"] = WKHeroAnimator({ _ in
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.pannel.hero.modifiers = [.fade, .translate(x: 1000), .useGlobalCoordinateSpace]
        }, onSuspend: { _ in
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.subtitleLabel.hero.modifiers = nil
            welk?.wk.view.pannel.hero.modifiers = nil
        })
        animators["1"] = WKHeroAnimator({ _ in
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.pannel.hero.modifiers = [.fade, .translate(x: -1000), .useGlobalCoordinateSpace]
        }, onSuspend: { _ in
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.subtitleLabel.hero.modifiers = nil
            welk?.wk.view.pannel.hero.modifiers = nil
        })
    }
}
