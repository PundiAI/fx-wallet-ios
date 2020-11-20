
import HDWalletKit
import Hero
import pop
import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit
extension WKWrapper where Base == WelcomeCreateWalletViewController {
    var view: WelcomeCreateWalletViewController.View { return base.view as! WelcomeCreateWalletViewController.View }
}

class WelcomeCreateWalletViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindAction()
        bindHero()
        wk.view.tipLabel.isHidden = false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    private func bindAction() {
        wk.view.createControl.action { [weak self] in
            self?.createWallet()
        }
        wk.view.importControl.action { [weak self] in
            self?.restoreWallet()
        }
    }

    @objc private func createWallet() {
        let mnemonic = filterMnemonic()
        guard let wallet = XWallet.sharedKeyStore.import(mnemonic: mnemonic) else { return }
        Router.pushToSetNickName(wallet: wallet.wk)
    }

    @objc private func restoreWallet() {
        Router.pushToImportWallet()
    }

    private func filterMnemonic() -> String {
        var mnemonic = Mnemonic.create(strength: .hight)
        while mnemonic.components(separatedBy: " ").removingDuplicates().count != 24 {
            mnemonic = Mnemonic.create(strength: .hight)
        }
        return mnemonic
    }
}

extension WelcomeCreateWalletViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("WelcomeCreateWalletViewController", "SetNickNameViewController"): return animators["0"]
        case ("WelcomeCreateWalletViewController", "ImportWalletViewController"): return animators["0"]
        default: return nil
        }
    }

    private func bindHero() {
        weak var welk = self
        animators["0"] = WKHeroAnimator({ _ in
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.tipLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.pannel.hero.modifiers = [.translate(y: 400), .useGlobalCoordinateSpace]
        }, onSuspend: { _ in
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.subtitleLabel.hero.modifiers = nil
            welk?.wk.view.pannel.hero.modifiers = nil
            welk?.wk.view.tipLabel.hero.modifiers = nil
        })
        animators["1"] = WKHeroAnimator({ _ in
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.tipLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.pannel.hero.modifiers = [.translate(y: 400), .useGlobalCoordinateSpace]
        }, onSuspend: { _ in
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.subtitleLabel.hero.modifiers = nil
            welk?.wk.view.pannel.hero.modifiers = nil
            welk?.wk.view.tipLabel.hero.modifiers = nil
        })
    }

    func startAnimate(from fromView: UIView, to toView: UIView) -> Observable<Bool> {
        weak var welk = self
        return Observable.create { (observer) -> Disposable in
            guard let view = welk?.wk.view else { return Disposables.create() }
            let containerView = UIView(frame: toView.bounds, UIColor.clear)
            if let sfromView = fromView.snapshotView(afterScreenUpdates: true) {
                let backView = UIView(frame: containerView.bounds, UIColor.white)
                backView.alpha = 0
                containerView.addSubview(sfromView)
                containerView.addSubview(backView)
                toView.setNeedsLayout()
                toView.layoutIfNeeded()
                toView.addSubview(containerView)
                containerView.frame = toView.bounds
                view.setNeedsLayout()
                view.layoutIfNeeded()
                observer.onNext(true)
                if let sWelViewTitle = view.titleLabel.snapshotView(),
                    let sWelViewSubTitle = view.subtitleLabel.snapshotView(),
                    let sWelViewPanel = view.pannel.snapshotView()
                {
                    let stitleFrame = view.convert(view.titleLabel.frame, to: fromView)
                    let sSubFrame = view.convert(view.subtitleLabel.frame, to: fromView)
                    let sPanelFrame = view.convert(view.pannel.frame, to: fromView)
                    sWelViewTitle.frame = stitleFrame
                    sWelViewSubTitle.frame = sSubFrame
                    sWelViewPanel.frame = sPanelFrame
                    containerView.addView(sWelViewTitle, sWelViewSubTitle, sWelViewPanel)
                    sWelViewPanel.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 500)
                    sWelViewTitle.alpha = 0
                    sWelViewSubTitle.alpha = 0
                    sWelViewTitle.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -100)
                    sWelViewSubTitle.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -100)
                    UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        backView.alpha = 1 sWelViewTitle.alpha = 1
                        sWelViewSubTitle.alpha = 1
                        sWelViewTitle.transform = CGAffineTransform.identity
                        sWelViewSubTitle.transform = CGAffineTransform.identity
                        sWelViewPanel.transform = CGAffineTransform.identity
                    }, completion: { _ in
                        observer.onCompleted()
                    })
                } else {
                    observer.onError(NSError(domain: "view == nil", code: 0, userInfo: nil))
                }
            } else {
                observer.onError(NSError(domain: "fromView snapshotView == nil", code: 0, userInfo: nil))
            }
            return Disposables.create {
                containerView.removeFromSuperview()
            }
        }
    }
}
