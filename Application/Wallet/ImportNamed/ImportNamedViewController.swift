import RxCocoa
import RxSwift
import WKKit
extension WKWrapper where Base == ImportNamedViewController {
    var view: ImportNamedViewController.View { return base.view as! ImportNamedViewController.View }
}

extension ImportNamedViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = ImportNamedViewController(wallet: wallet)
        return vc
    }
}

class ImportNamedViewController: WKViewController {
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
        bind()
        logWhenDeinit()
    }

    private func bind() {
        wk.view.nickNameLabel.text = "@" + (wallet.nickName ?? "")
        wk.view.doneButton.action { [weak self] in
            guard let weakself = self else { return }
            weakself.wallet.createCompleted = .createNickname
            Router.pushToSecurityType(wallet: weakself.wallet)
        }
        wk.view.closeButton.action {
            Router.showBackAlert()
        }
    }
}

extension ImportNamedViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("ImportWalletViewController", "ImportNamedViewController"): return animators["0"]
        case ("ImportNamedViewController", "SecurityTypeViewController"): return animators["1"]
        default: return nil
        }
    }

    private func bindHero() {
        weak var welk = self
        let onSuspendBlock: (WKHeroAnimator) -> Void = { _ in
            welk?.wk.view.navBar.hero.modifiers = nil
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.nickNameLabel.hero.modifiers = nil
            welk?.wk.view.doneButton.hero.modifiers = nil
            welk?.wk.view.tipLabel.hero.modifiers = nil
        }
        animators["0"] = WKHeroAnimator({ _ in welk?.wk.view.titleLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.nickNameLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.tipLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.doneButton.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
        animators["1"] = WKHeroAnimator({ _ in
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.nickNameLabel.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.doneButton.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.tipLabel.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
    }
}
