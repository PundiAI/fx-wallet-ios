import Hero
import RxCocoa
import RxSwift
import WKKit
extension WKWrapper where Base == SelectAccountViewController {
    var view: SelectAccountViewController.View { return base.view as! SelectAccountViewController.View }
}

extension SelectAccountViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let filter = context["filter"] as? (Coin, [String: Any]?) -> Bool
        var current: (Coin, Keypair)?
        if let coin = context["currentCoin"] as? Coin,
            let account = context["currentAccount"] as? Keypair
        {
            current = (coin, account)
        }
        let vc = SelectAccountViewController(wallet: wallet, current: current, filter: filter)
        vc.cancelHandler = context["cancelHandler"] as? () -> Void
        vc.confirmHandler = context["handler"] as? (UIViewController?, Coin, Keypair) -> Void
        return vc
    }
}

class SelectAccountViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, current: (Coin, Keypair)?, filter: ((Coin, [String: Any]?) -> Bool)? = nil) {
        listViewModel = AccountListViewModel(wallet: wallet, current: current, filter: filter)
        super.init(nibName: nil, bundle: nil)
        super.modalPresentationStyle = .overFullScreen
        super.modalPresentationCapturesStatusBarAppearance = true
        bindHero()
    }

    var cancelHandler: (() -> Void)?
    var confirmHandler: ((UIViewController?, Coin, Keypair) -> Void)?
    let listViewModel: AccountListViewModel
    lazy var listBinder = AccountListBinder(view: wk.view.listView)
    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bindListView()
        bindTitleAnimation()
    }

    private func bindListView() {
        weak var welf = self
        listBinder.bind(listViewModel)
        listBinder.didSeleted = { _, coin, account in
            welf?.confirmHandler?(welf, coin, account)
        }
        listBinder.refresh()
        wk.view.closeButton.action {
            Router.dismiss(welf) {
                welf?.cancelHandler?()
            }
        }
    }

    private func bindTitleAnimation() {
        wk.view.titleAnimator.bind(wk.view.listView)
        view.wk.bindLineDisplay(listBinder.view, maxOffset: wk.view.navBarHeight)
    }
}

extension SelectAccountViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { switch (from, to) {
    case (_, "SelectAccountViewController"): return animators["0"]
    default: return nil
    }
    }

    private func bindHero() { weak var welf = self
        let animator = WKHeroAnimator({ _ in
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            welf?.wk.view.contentView.hero.modifiers = [.fade, .useGlobalCoordinateSpace,
                                                        .useOptimizedSnapshot,
                                                        .translate(y: 1000)]
        }, onSuspend: { _ in
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
        })
        animators["0"] = animator
    }
}
