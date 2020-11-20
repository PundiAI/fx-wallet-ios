import HapticGenerator
import Hero
import pop
import PromiseKit
import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit

extension Router {
    private static func rootViewController(wallet: Wallet?) -> WKNavigationController {
        var rootController: WKNavigationController
        if let wallet = XWallet.sharedKeyStore.currentWallet?.wk, let state = wallet.createCompleted {
            switch state {
            case .crateMnemonic:
                rootController = WKNavigationController(rootViewController: Router.setNickNameController(wallet: wallet))
            case .createNickname:
                rootController = WKNavigationController(rootViewController: Router.securityTypeController(wallet: wallet))
            case .importNickname:
                rootController = WKNavigationController(rootViewController: Router.importNamedController(wallet: wallet))
            case .setSecurity:
                rootController = WKNavigationController(rootViewController: Router.securityTypeController(wallet: wallet))
            case .completed:
                rootController = WKNavigationController(rootViewController: Router.walletRootController(wallet.rawValue))
            }
        } else {
            rootController = WKNavigationController(rootViewController: Router.welcomeCreateWalletController)
        }
        rootController.hero.isEnabled = false
        rootController.hero.navigationAnimationType = .none
        rootController.interactivePopGestureRecognizer?.delegate = nil
        rootController.interactivePopGestureRecognizer?.isEnabled = true
        return rootController
    }

    @discardableResult
    static func setRootController(wallet: Wallet?, viewControllers: [UIViewController]? = nil) -> Guarantee<Bool> {
        return Guarantee<Bool> { seal in
            guard let window = self.window else {
                seal(false)
                return
            }
            let rootController = Router.rootViewController(wallet: wallet)
            if let items = viewControllers {
                rootController.viewControllers.appends(array: items)
            }
            let setRootViewControllerBlock: () -> Void = {
                window.rootViewController = rootController
                window.makeKeyAndVisible()
            }
            setRootViewControllerBlock()
            seal(true)
        }
    }

    @discardableResult
    static func resetRootController(wallet: Wallet?, animated: Bool = false) -> Guarantee<Bool> {
        return Guarantee<Bool> { seal in
            guard let window = self.window else {
                seal(false)
                return
            }
            let rootController = Router.rootViewController(wallet: wallet)
            let setRootViewControllerBlock: () -> Void = {
                let currentRootVC = window.rootViewController as? UINavigationController
                window.rootViewController = rootController
                window.makeKeyAndVisible()
                currentRootVC?.viewControllers = []
            }
            guard let _ = window.rootViewController else {
                setRootViewControllerBlock()
                seal(true)
                return
            }
            if animated == false {
                setRootViewControllerBlock()
                seal(true)
            } else {
                if let vController = rootController.viewControllers.first as? WelcomeCreateWalletViewController {
                    vController.startAnimate(from: window, to: rootController.view)
                        .asObservable()
                        .subscribeOn(MainScheduler.instance)
                        .subscribe(onNext: { _ in
                            setRootViewControllerBlock()
                        }, onCompleted: {
                            seal(true)
                        }).disposed(by: rootController.defaultBag)
                } else if let vController = rootController.viewControllers.first as? FxTabBarController {
                    vController.startAnimate(from: window, to: rootController.view)
                        .asObservable()
                        .subscribeOn(MainScheduler.instance)
                        .subscribe(onNext: { _ in
                            setRootViewControllerBlock()
                        }, onCompleted: {
                            seal(true)
                        }).disposed(by: rootController.defaultBag)
                } else {
                    setRootViewControllerBlock()
                    seal(true)
                }
            }
        }
    }

    public static func walletRootController(_ wallet: Wallet) -> UITabBarController {
        return FxTabBarController(wallet)
    }

    static func tokenRootController(wallet: Wallet) -> UIViewController {
        return viewController("TokenRootViewController", context: ["wallet": wallet])
    }

    static func dappRootController(wallet: Wallet, coin: Coin) -> UIViewController {
        return viewController("DappPageListViewController", context: ["wallet": wallet, "coin": coin])
    }
}

extension WKWrapper where Base == TokenRootViewController {
    var view: TokenRootViewController.View { return base.view as! TokenRootViewController.View }
}

extension TokenRootViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet else { return nil }
        return TokenRootViewController(wallet: wallet)
    }
}

class TokenRootViewController: TokenListViewController {
    private var isVisible: Bool = true
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(wallet: Wallet) {
        notifBinder = NotificationListViewController(wallet: wallet)
        super.init(wallet: wallet)
        bindHero()
    }

    let notifBinder: NotificationListViewController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let isVisible = self.isVisible
        return (notifBinder.viewModel.itemCount.value > 0 && isVisible) ? .default : .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bindNotif()
        bindScrollNot()
        showNotifAlertIfNeed()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func bindNotif() { notifBinder.show(in: wk.view)
        notifBinder.view.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navigationBar.snp.top)
            make.height.equalTo(NotificationListViewController.minContentHeight)
        }
        notifBinder.viewModel.itemCount
            .subscribe(onNext: { [weak self] count in
                self?.isVisible = count > 0
                self?.setNeedsStatusBarAppearanceUpdate()
                self?.wk.view.layoutNotif(count > 0)
            }).disposed(by: defaultBag)
    }

    private func showNotifAlertIfNeed() {
        let didRequestRemoteNotif = UserDefaults.standard.bool(forKey: "fx.didRequestRemoteNotif")
        if didRequestRemoteNotif {
            WKRemoteServer.request()
        } else {
            UserDefaults.standard.set(true, forKey: "fx.didRequestRemoteNotif")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { Router.showNotificationAlert()
            }
        }
    }
}

extension TokenRootViewController {
    private func bindScrollNot() {
        let navigationBar = self.navigationBar
        let notifView: UIView = notifBinder.view
        let notifMaxOffsetY: CGFloat = 22 + 10.auto()
        let listView = wk.view.listView
        let updateConstraints: (CGFloat, CGFloat) -> Void = { noffset, boffset in
            navigationBar.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(boffset)
            }
            notifView.snp.remakeConstraints { make in
                make.top.equalTo(navigationBar.snp.top).offset(noffset)
                make.left.right.equalToSuperview()
                make.height.equalTo(NotificationListViewController.minContentHeight)
            }
        }
        wk.view.listView.rx.contentOffset
            .asObservable()
            .filter { (_) -> Bool in
                listView.contentInset.top > 0
            }
            .distinctUntilChanged().subscribe(onNext: { point in
                let contentInsetTop = listView.contentInset.top
                let distance = NotificationListViewController.minContentHeight - contentInsetTop - notifMaxOffsetY
                let maxOffsetY = -1 * contentInsetTop
                if point.y >= maxOffsetY, point.y <= distance {
                    let maxDistance = distance - maxOffsetY
                    let offsetProess = (notifMaxOffsetY * (point.y - maxOffsetY)) / maxDistance
                    updateConstraints(-1 * offsetProess, -1 * (point.y - maxOffsetY))
                } else if point.y >= distance {
                    updateConstraints(-1 * notifMaxOffsetY, -1 * (distance + contentInsetTop))
                } else {
                    updateConstraints(0, 0)
                }
                notifView.isUserInteractionEnabled = abs(contentInsetTop - abs(point.y)) <= 0.5
            }).disposed(by: defaultBag)
        let doFilter: () -> Bool = {
            listView.contentInset.top > 0
                && notifView.frame.origin.y < 0
                && notifView.frame.maxY > notifMaxOffsetY
        }
        let updateStatusBarBlock: (Bool) -> Void = { [weak self] _isVisible in
            self?.isVisible = _isVisible
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        let doAction: () -> Void = {
            let point = listView.panGestureRecognizer.translation(in: listView)
            let contentInsetTop = listView.contentInset.top
            let toOffsetY = NotificationListViewController.minContentHeight - contentInsetTop - notifMaxOffsetY
            let anim1 = POPSpringAnimation(propertyNamed: kPOPScrollViewContentOffset)
            if point.y < 0 ? (abs(notifView.top) >= notifView.height * 1.0 / 3.0) : (notifView.bottom >= notifView.height * 1 / 3.0) == false {
                anim1?.toValue = CGPoint(x: 0, y: toOffsetY)
                updateStatusBarBlock(false)
            } else {
                anim1?.toValue = CGPoint(x: 0, y: -1 * contentInsetTop)
                updateStatusBarBlock(true)
            }
            listView.pop_add(anim1, forKey: "kPOPScrollViewContentOffset")
        }
        wk.view.listView.rx.didEndDecelerating.asObservable().subscribe(onNext: { _ in
            let isVisible = listView.contentInset.top > 0 && !(notifView.bottom <= 0)
            updateStatusBarBlock(isVisible)
        }).disposed(by: defaultBag)
        wk.view.listView.rx.didEndDragging.asObservable().subscribe(onNext: { willDecelerate in
            if willDecelerate == false {
                let isVisible = listView.contentInset.top > 0 && !(notifView.bottom <= 0)
                updateStatusBarBlock(isVisible)
            }
        }).disposed(by: defaultBag)
        wk.view.listView.rx.didEndDecelerating.asObservable().filter { (_) -> Bool in
            doFilter()
        }.subscribe(onNext: { _ in
            doAction()
        }).disposed(by: defaultBag)
        wk.view.listView.rx.didEndDragging.asObservable().filter { (_) -> Bool in
            doFilter()
        }.subscribe(onNext: { willDecelerate in
            if willDecelerate == false {
                doAction()
            }
        }).disposed(by: defaultBag)
    }
}

extension TokenRootViewController {
    class InfoAnimator: WKHeroAnimator {
        var cell: Cell!
    }
}

extension TokenRootViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { switch (from, to) {
    case ("TokenRootViewController", "TokenInfoViewController"): return animators["0"]
    case ("TokenRootViewController", "SendTokenInputViewController"): return animators["1"]
    case ("TokenRootViewController", "ReceiveTokenViewController"): return animators["1"]
    case ("TokenRootViewController", "AddTokenViewController"): return animators["2"]
    case ("TokenRootViewController", "SelectOrAddAccountViewController"): return animators["2"]
    default: return nil
    }
    }

    private func clearHeroModifersForCell() {
        wk.view.listView.visibleCells.each { _cell in
            _cell.hero.modifiers = nil
            (_cell as? Cell)?.view.tokenLabel.hero.id = nil
            (_cell as? Cell)?.view.tokenIV.hero.id = nil
            (_cell as? Cell)?.view.tokenLabel.hero.modifiers = nil
            (_cell as? Cell)?.view.tokenIV.hero.modifiers = nil
        }
    }

    private func bindHero() {
        weak var welf = self
        let onSuspend: (WKHeroAnimator) -> Void = { _ in
            welf?.navigationBar.backgoundView?.alpha = 1
            welf?.navigationBar.visualEffectView?.alpha = 1
            (welf?.navigationBar as? TokenNavigationBar)?.backgroundBlurView.alpha = 1
            welf?.navigationBar.hero.modifiers = nil
            welf?.wk.view.bgroundView.hero.id = nil
            welf?.wk.view.bgroundView.hero.modifiers = nil
            welf?.wk.view.bgroundColorView.hero.modifiers = nil
            welf?.wk.view.listView.hero.modifiers = nil
            welf?.clearHeroModifersForCell()
            welf?.wk.view.listView.tableFooterView?.hero.modifiers = nil
            Router.tabBarController?.tabBar.hero.modifiers = nil
            welf?.notifBinder.view.hero.modifiers = nil
            welf?.wk.view.listView.hero.modifiers = nil
            welf?.wk.view.listView.tableHeaderView?.hero.modifiers = nil
        }
        let infoAnimator = InfoAnimator({ a in
            guard let animator = a as? InfoAnimator else { return }
            welf?.wk.view.navBarView.hero.id = "token_list_navbar_view"
            welf?.wk.view.bgroundView.hero.id = "token_list_background"
            welf?.wk.view.bgroundView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.bgroundColorView.hero.modifiers = [.forceAnimate, .useGlobalCoordinateSpace, .useNormalSnapshot]
            welf?.wk.view.listView.hero.modifiers = [.cascade, .whenAppearing(.fade),
                                                     .whenDisappearing(.forceNonFade),
                                                     .useOptimizedSnapshot]
            animator.cell.view.tokenLabel.hero.id = "token_title_lable"
            animator.cell.view.tokenLabel.hero.modifiers = [.useScaleBasedSizeChange]
            animator.cell.view.tokenIV.hero.id = "token_image_view"
            animator.cell.view.tokenIV.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                         .useGlobalCoordinateSpace]
            welf?.navigationBar.hero.modifiers = [.useGlobalCoordinateSpace, .useLayerRenderSnapshot,
                                                  .translate(y: -1000)]
            welf?.notifBinder.view.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot,
                                                     .translate(y: -1000)]
            welf?.clearHeroModifersForCell()
            welf?.wk.view.listView.visibleCells.each(call: { index, _cell in
                _cell.hero.modifiers = [.fade, .useOptimizedSnapshot, .useGlobalCoordinateSpace,
                                        .scale(0.9), .translate(x: 0, y: CGFloat(100 + index * 20), z: 10)]
            })
            welf?.wk.view.listView.tableHeaderView?.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                                      .useGlobalCoordinateSpace,
                                                                      .translate(x: 0, y: -300, z: 0)]
            welf?.wk.view.listView.tableFooterView?.hero.modifiers = [.fade, .useOptimizedSnapshot, .useGlobalCoordinateSpace]
        }, onSuspend: onSuspend)
        animators["0"] = infoAnimator
        let sendAnimator = WKHeroAnimator({ _ in
            welf?.wk.view.hero.modifiers = nil
            welf?.wk.view.bgroundView.hero.id = "token_list_background"
            welf?.clearHeroModifersForCell()
            welf?.navigationBar.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useLayerRenderSnapshot, .translate(y: -1000)]
            welf?.notifBinder.view.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: -1500)]
            welf?.wk.view.listView.hero.modifiers = [.fade, .useOptimizedSnapshot, .useGlobalCoordinateSpace,
                                                     .translate(x: 0, y: 1000, z: 0)]
            welf?.wk.view.bgroundView.hero.modifiers = [.useNormalSnapshot, .useGlobalCoordinateSpace,
                                                        .translate(x: 0, y: 1000, z: 0)]
            welf?.wk.view.bgroundColorView.hero.modifiers = [.forceAnimate, .useGlobalCoordinateSpace, .useNormalSnapshot]
            welf?.wk.view.listView.tableHeaderView?.hero.modifiers = [.fade, .useOptimizedSnapshot, .useGlobalCoordinateSpace,
                                                                      .translate(x: 0, y: -300, z: 0)]
        }, onSuspend: onSuspend)
        animators["1"] = sendAnimator
        let addAnimator = WKHeroAnimator({ _ in
            welf?.wk.view.bgroundView.hero.id = "token_list_background"
            welf?.wk.view.bgroundView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.bgroundColorView.hero.modifiers = [.forceAnimate, .useGlobalCoordinateSpace, .useNormalSnapshot]
            welf?.navigationBar.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useLayerRenderSnapshot,
                                                  .translate(y: -1000)]
            welf?.notifBinder.view.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: -1500)]
            welf?.wk.view.listView.hero.modifiers = [.fade, .useOptimizedSnapshot, .useGlobalCoordinateSpace,
                                                     .translate(x: 0, y: 1000, z: 0)]
            welf?.wk.view.listView.tableHeaderView?.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                                      .useGlobalCoordinateSpace,
                                                                      .translate(x: 0, y: -300, z: 0)]
        }, onSuspend: onSuspend)
        animators["2"] = addAnimator
    }
}

extension FxTabBarController {
    func startAnimate(from fromView: UIView, to toView: UIView) -> Observable<Bool> {
        weak var welk = self
        return Observable.create { (observer) -> Disposable in
            guard let view = welk?.view else { return Disposables.create() }
            guard let tabBar = welk?.tabBar else { return Disposables.create() }
            let containerView = UIView(frame: toView.bounds, UIColor.clear)
            if let sfromView = fromView.snapshotView(afterScreenUpdates: true) {
                let backView = UIView(frame: containerView.bounds, HDA(0x080A32))
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
                if let sViewController = welk?.selectedViewController as? TokenRootViewController {
                    sViewController.view.setNeedsLayout()
                    sViewController.view.layoutIfNeeded()
                    let bottomListView: () -> UIView? = {
                        sViewController.wk.view.listHeaderView.alpha = 0
                        let sListView = sViewController.wk.view.listView.snapshotView(afterScreenUpdates: true)
                        sViewController.wk.view.listHeaderView.alpha = 1
                        return sListView
                    }
                    let topListView: () -> UIView? = {
                        sViewController.wk.view.listHeaderView.alpha = 1
                        let sTopListView = sViewController.wk.view.listHeaderView.snapshotView()
                        return sTopListView
                    }
                    if let sTabbarView = tabBar.snapshotView(),
                        let topListView = topListView(),
                        let listBackView = sViewController.wk.view.bgroundView.snapshotView()
                    {
                        DispatchQueue.main.async {
                            let sListView = bottomListView() ?? UIView()
                            let sTabbarFrame = view.convert(tabBar.frame, to: fromView)
                            let bListViewFrame = sViewController.wk.view.convert(sViewController.wk.view.bgroundView.frame, to: fromView)
                            let lListViewFrame = sViewController.wk.view.convert(sViewController.wk.view.listView.frame, to: fromView)
                            let tListViewFrame = sViewController.wk.view.listView.convert(sViewController.wk.view.listHeaderView.frame, to: fromView)
                            listBackView.frame = bListViewFrame
                            listBackView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: containerView.bounds.height)
                            sListView.frame = lListViewFrame
                            sListView.alpha = 0
                            sListView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: containerView.bounds.height)
                            topListView.frame = tListViewFrame
                            topListView.alpha = 0
                            topListView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -topListView.frame.size.height)
                            sTabbarView.frame = sTabbarFrame
                            sTabbarView.alpha = 0
                            sTabbarView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 150)
                            containerView.addView(listBackView, sListView, topListView, sTabbarView)
                            UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                                backView.alpha = 1
                                listBackView.transform = CGAffineTransform.identity
                                sTabbarView.alpha = 1
                                sTabbarView.transform = CGAffineTransform.identity
                                topListView.alpha = 1
                                topListView.transform = CGAffineTransform.identity
                                sListView.alpha = 1
                                sListView.transform = CGAffineTransform.identity
                            }, completion: { _ in
                                observer.onCompleted()
                            })
                        }
                    } else {
                        observer.onError(NSError(domain: "view == nil", code: 0, userInfo: nil))
                    }
                } else {
                    observer.onError(NSError(domain: "fromView snapshotView == nil", code: 0, userInfo: nil))
                }
            }
            return Disposables.create {
                containerView.removeFromSuperview()
            }
        }
    }
}
