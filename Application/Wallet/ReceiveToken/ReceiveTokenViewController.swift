
import HapticGenerator
import Hero
import SwiftyJSON
import WKKit
extension WKWrapper where Base == ReceiveTokenViewController {
    var view: ReceiveTokenViewController.View { return base.view as! ReceiveTokenViewController.View }
}

extension ReceiveTokenViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin,
            let account = context["account"] as? Keypair else { return nil }
        return ReceiveTokenViewController(coin, account)
    }
}

class ReceiveTokenViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ coin: Coin, _ account: Keypair) {
        self.coin = coin
        self.account = account
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    let coin: Coin
    let account: Keypair
    private var shareController: UIDocumentInteractionController?
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bind()
    }

    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Receive") + " \(coin.token)")
        navigationBar.action(.back, imageName: "ic_back_60") { [weak self] in
            Router.pop(self)
        }
    }

    private func bind() {
        bindQRCode()
        let name = XWallet.currentWallet?.wk.nickName ?? ""
        wk.view.userNameLabel.text = "@\(name)"
        wk.view.addressLabel.text = account.address
        wk.view.copyButton.rx.tap.subscribe(onNext: { [weak self] _ in
            Haptic.success.generate()
            UIPasteboard.general.string = self?.account.address ?? ""
            self?.hud?.text(m: TR("Copied"))
        }).disposed(by: defaultBag)
        wk.view.shareButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.share()
        }).disposed(by: defaultBag)
    }

    private func bindQRCode() {
        let qrCodeString = "\(coin.chainName):\(account.address.lowercased())?token=\(coin.symbol)" wk.view.qrCodeIV.image = WKQRMaker(value: qrCodeString, size: 200.auto())
    }

    private func share() {
        let image = wk.view.qrCodeContainer.asImage()
        guard let imageData = image.jpegData(compressionQuality: 1),
            let tempFile = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ReceiveQR.png")
        else {
            hud?.text(m: "can`t share now")
            return
        }
        do {
            try imageData.write(to: tempFile, options: .atomicWrite)
            let controller = UIDocumentInteractionController(url: tempFile)
            shareController = controller
            controller.presentOpenInMenu(from: view.bounds, in: view, animated: true)
        } catch {
            hud?.text(m: "can`t share now")
        }
    }
}

extension ReceiveTokenViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { switch (from, to) {
    case ("SelectOrAddAccountViewController", "ReceiveTokenViewController"): return animators["0"]
    case ("TokenRootViewController", "ReceiveTokenViewController"): return animators["1"]
    case ("DappPageListViewController", "ReceiveTokenViewController"): return animators["1"]
    case ("TokenInfoViewController", "ReceiveTokenViewController"): return animators["2"]
    default: return nil
    }
    }

    private func bindHero() { weak var welf = self
        let onSuspendBlock: (WKHeroAnimator) -> Void = { _ in
            welf?.navigationBar.leftBarButton?.hero.modifiers = nil
            welf?.navigationBar.titleView?.hero.modifiers = nil
            welf?.navigationBar.backgoundView?.hero.modifiers = nil
            welf?.wk.view.qrCodeBackContainer.hero.id = nil
            welf?.wk.view.qrCodeBackContainer.hero.modifiers = nil
            welf?.wk.view.qrCodeContainer.hero.modifiers = nil
            welf?.wk.view.shareButton.hero.modifiers = nil
            welf?.wk.view.tipButton.hero.modifiers = nil
            welf?.wk.view.copyButton.hero.modifiers = nil
            welf?.wk.view.backgoundView.hero.id = nil
            welf?.wk.view.contentView.hero.modifiers = nil
            Router.tabBarController?.tabBar.hero.modifiers = nil
        }
        animators["0"] = WKHeroAnimator({ _ in
            welf?.navigationBar.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: -100)]
            welf?.wk.view.backgoundView.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot]
            welf?.wk.view.qrCodeBackContainer.hero.id = "qrCodeBackground"
            welf?.wk.view.qrCodeBackContainer.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .cornerRadius(16.auto())]
            welf?.wk.view.qrCodeContainer.hero.modifiers = [.fade, .delay(0.2), .scale(0.5), .useGlobalCoordinateSpace]
            welf?.wk.view.shareButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 1000)]
            welf?.wk.view.tipButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 10)]
            welf?.wk.view.copyButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 1500)]
        }, onSuspend: onSuspendBlock)
        animators["1"] = WKHeroAnimator({ _ in
            welf?.navigationBar.backgoundView?.alpha = 0
            let modifiers: [HeroModifier] = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: -100)]
            welf?.navigationBar.hero.modifiers = modifiers
            welf?.wk.view.backgoundView.hero.id = "token_list_background"
            welf?.wk.view.contentView.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(y: 1000)]
            Router.tabBarController?.tabBar.hero.modifiers = [.whenPresenting(.useGlobalCoordinateSpace, .beginWith([.zPosition(110)]),
                                                                              .translate(y: CGFloat(100.0 * 2.0))),
                                                              .whenDismissing(.useGlobalCoordinateSpace, .beginWith([.zPosition(110)]), .delay(0.1),
                                                                              .translate(y: CGFloat(100.0 * 2.0)), .forceAnimate)]
        }, onSuspend: onSuspendBlock)
        animators["2"] = WKHeroAnimator.Share.push()
    }
}
