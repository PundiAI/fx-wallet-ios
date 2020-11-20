import Hero
import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit
class BackAlertViewController: FxRegularPopViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        bindHero()
        modalPresentationStyle = .fullScreen
        logWhenDeinit()
    }

    override var dismissWhenTouch: Bool { false }
    override func bindListView() { listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }

    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { _ in
            welf?.dismiss()
        }).disposed(by: cell.defaultBag)
        cell.confirmButton.rx.tap.subscribe(onNext: { _ in
            if let wallet = XWallet.sharedKeyStore.currentWallet {
                let error = XWallet.sharedKeyStore.delete(wallet: wallet)
                if let _error = error {
                    welf?.hud?.text(m: _error.localizedDescription)
                }
                DispatchQueue.main.async {
                    XWallet.clear(wallet)
                }
            }
            Router.resetRootController(wallet: nil, animated: true)
        }).disposed(by: cell.defaultBag)
    }

    override func layoutUI() {
        hideNavBar()
    }
}

extension BackAlertViewController {
    override func heroAnimator(from _: String, to: String) -> WKHeroAnimator? {
        switch to {
        case "BackAlertViewController": return animators["0"]
        default: return nil
        }
    }

    private func bindHero() { weak var welf = self
        let animator = WKHeroAnimator({ _ in
            welf?.setBackgoundOverlayViewImage()
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            let modifiers: [HeroModifier] = [.useGlobalCoordinateSpace,
                                             .useOptimizedSnapshot, .translate(y: 1000)]
            welf?.wk.view.contentBGView.hero.modifiers = modifiers
            welf?.wk.view.contentView.hero.modifiers = modifiers
        }, onSuspend: { _ in welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentBGView.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
        })
        animators["0"] = animator
    }
}
