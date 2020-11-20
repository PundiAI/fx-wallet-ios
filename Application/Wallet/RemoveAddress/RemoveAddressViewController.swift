import Hero
import RxSwift
import TrustWalletCore
import WKKit
extension RemoveAddressViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        let vc = RemoveAddressViewController()
        vc.completionHandler = context["handler"] as? (WKError?) -> Void
        return vc
    }
}

class RemoveAddressViewController: FxRegularPopViewController {
    var completionHandler: ((WKError?) -> Void)?
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        bindHero()
    }

    override var dismissWhenTouch: Bool { true }
    override var interactivePopIsEnabled: Bool { false }
    override func bindListView() {
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }

    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { _ in Router.pop(welf)
        }).disposed(by: cell.defaultBag)
        cell.confirmButton.action {
            welf?.completionHandler?(nil)
            Router.pop(welf)
        }
    }

    override func layoutUI() {
        hideNavBar()
    }
}

extension RemoveAddressViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("TokenActionSheet", "RemoveAddressViewController"): return animators["0"]
        case ("TokenInfoViewController", "RemoveAddressViewController"): return animators["1"]
        default: return nil
        }
    }

    private func getOverlayView() -> UIView? {
        return Router.currentNavigator?.viewControllers.last(where: { (vc) -> Bool in
            vc.heroIdentity == "TokenInfoViewController"
        })?.view
    }

    private func bindHero() {
        weak var welf = self
        let animator = WKHeroAnimator({ _ in
            welf?.setBackgoundOverlayViewImage(for: welf?.getOverlayView())
            welf?.wk.view.contentBGView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y: 1000)]
            welf?.wk.view.contentView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y: 1000)]
        }, onSuspend: { _ in welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
            welf?.wk.view.contentBGView.hero.modifiers = nil
        })
        animators["0"] = animator
        let animator1 = WKHeroAnimator({ _ in
            welf?.setBackgoundOverlayViewImage(for: welf?.getOverlayView())
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            welf?.wk.view.contentBGView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y: 1000)]
            welf?.wk.view.contentView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y: 1000)]
        }, onSuspend: { _ in
            welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
            welf?.wk.view.contentBGView.hero.modifiers = nil
        })
        animators["1"] = animator1
    }
}
