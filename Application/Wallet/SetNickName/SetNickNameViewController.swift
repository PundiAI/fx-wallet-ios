
import HapticGenerator
import Hero
import PromiseKit
import RxCocoa
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit
extension WKWrapper where Base == SetNickNameViewController {
    var view: SetNickNameViewController.View { return base.view as! SetNickNameViewController.View }
}

extension SetNickNameViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet, let ticket = context["ticket"] as? String else { return nil }
        let vc = SetNickNameViewController(wallet: wallet)
        vc.ticket = ticket
        return vc
    }
}

class SetNickNameViewController: WKViewController {
    private let wallet: WKWallet
    private var ticket: String = ""
    lazy var animator: WNavTitlePanScaleAnimator = {
        let v = WNavTitlePanScaleAnimator(wk.view.titleLabel, endOrigin: CGPoint(x: (ScreenWidth - wk.view.titleLabel.width * 0.5) * 0.5,
                                                                                 y: 58 + StatusBarHeight + (NavBarHeight - wk.view.titleLabel.height * 0.5) * 0.5), maxOffset: 58)
        return v
    }()

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
        configuration()
        bind()
        bindKeyboard()
        logWhenDeinit()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        wk.view.inputTF.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wk.view.inputTF.resignFirstResponder()
    }

    private func bind() {
        wallet.createCompleted = .crateMnemonic
        wallet.registerType = .newCreate
        let view = wk.view
        weak var welf = self
        view.doneButton.action { welf?.next() }
        view.inputTF.rx.text.distinctUntilChanged().subscribeOn(MainScheduler.instance).subscribe(onNext: { text in
            var pwd = text ?? "?"
            pwd = pwd.trimmingCharacters(in: .whitespaces)
            pwd = pwd.trimCenterSpace()
            view.inputTF.text = pwd
            if pwd.length == 0 {
                view.doneButton.isEnabled = false
                view.inputTFContainer.borderColor = COLOR.inputborder
                view.tipView1.isNSelected = false
                view.tipView2.isNSelected = false
                view.tipView3.isNSelected = false
                view.tipView4.isNSelected = false
            } else {
                let p4 = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]*$")
                let p2 = NSPredicate(format: "SELF MATCHES %@", "^[0-9a-zA-Z]*$")
                let p3 = NSPredicate(format: "SELF MATCHES %@", "[0-9a-zA-Z_\\.-]*")

                let p = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]+[0-9a-zA-Z_\\.-]{1,16}[0-9a-zA-Z]$")
                view.tipView1.isNSelected = p4.evaluate(with: pwd.substring(range: NSRange(location: 0, length: 1)))
                view.tipView2.isNSelected = pwd.length >= 3 && pwd.length <= 18
                let temp = pwd.substring(range: NSRange(location: pwd.length - 1, length: 1))
                view.tipView3.isNSelected = p2.evaluate(with: temp)
                view.tipView4.isNSelected = p3.evaluate(with: pwd)
                let able = p.evaluate(with: pwd) && (pwd.length >= 3 && pwd.length <= 18)
                view.doneButton.isEnabled = able
                view.inputTFContainer.borderColor = COLOR.inputborder
            }
        }).disposed(by: defaultBag)
        view.closeButton.action { [weak self] in
            self?.stopAction()
        }
        animator.bind(view.scrollview)
        view.scrollview.rx.didScroll.subscribe(onNext: { [weak self] _ in
            guard let contentY = self?.wk.view.scrollview.contentOffset.y, let view = self?.wk.view else { return } if contentY >= 58 {
                view.navBar.backgroundColor = UIColor.white
                view.navBar.titleLabel.text = view.titleLabel.text
            } else {
                view.navBar.backgroundColor = UIColor.clear
                view.navBar.titleLabel.text = ""
            }
        }).disposed(by: defaultBag)
    }

    private func configuration() {
        if #available(iOS 11.0, *) {
            wk.view.scrollview.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    private func stopAction() { Router.showBackAlert()
    }

    private func next() {
        if ticket.length > 0 {
            haveTicket()
            return
        }
        hud?.hide()
        hud?.waiting()
        createName().subscribe(onNext: { [weak self] json in
            guard let this = self else { return }
            let nickName = json["nickName"].stringValue
            let secret = json["secret"].stringValue
            let userId = json["userId"].stringValue
            if this.wallet.createCompleted == .crateMnemonic {
                this.wallet.createCompleted = .createNickname
                this.wallet.nickName = nickName
                this.wallet.secret = secret
                this.wallet.userId = userId
                Router.pushToSecurityType(wallet: this.wallet)
            }
        }, onError: { [weak self] e in
            self?.hud?.hide()
            self?.hud?.text(m: e.asWKError().msg, d: 2, p: .topCenter)
        }).disposed(by: defaultBag)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    private func bindKeyboard() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self else { return }
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                let endFrame = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = UIScreen.main.bounds.height - endFrame.origin.y
                this.wk.view.scrollview.snp.updateConstraints { make in
                    make.bottom.equalTo(this.view).offset(-margin)
                }
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
            }).disposed(by: defaultBag)
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self else { return }
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                this.wk.view.scrollview.snp.updateConstraints { make in
                    make.bottom.equalTo(this.view)
                }
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
            }).disposed(by: defaultBag)
    }

    private func haveTicket() {
        hud?.waiting()
        let nickName = wk.view.inputTF.text ?? ""
        let params = SetNickNameViewController.getAddressAndPubKey(mnemonic: wallet.mnemonic)
        APIManager.fx.createNewNickName(address: params.0, addressPubKey: params.1, nickName: nickName, ticket: ticket).subscribe(onNext: { [weak self] json in
            guard let weakself = self else { return }
            weakself.hud?.hide()
            let nickName = json["nickName"].stringValue
            let secret = json["secret"].stringValue
            let userId = json["userId"].stringValue
            weakself.wallet.nickName = nickName
            weakself.wallet.secret = secret
            weakself.wallet.userId = userId
            weakself.wallet.createCompleted = .createNickname
            Router.pushToSecurityType(wallet: weakself.wallet)
        }, onError: { [weak self] e in
            self?.hud?.hide()
            self?.hud?.text(m: e.asWKError().msg, d: 2, p: .topCenter)
        }, onCompleted: {}).disposed(by: defaultBag)
    }

    static func getAddressAndPubKey(mnemonic: String) -> (String, String, PrivateKey) {
        let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
        let privateKey = wallet.getKey(derivationPath: "m/44'/60'/0'/0/0")
        let address = AnyAddress(publicKey: privateKey.getPublicKeySecp256k1(compressed: false), coin: .ethereum)
        let pubkey = privateKey.getPublicKeySecp256k1(compressed: false).data.hex
        return (address.description, pubkey, privateKey)
    }

    private func createName() -> Observable<JSON> {
        return NetworkServer.encrypt.fetchEncrypt().flatMap { (_) -> Observable<JSON> in
            APIManager.fx.fetchSignInfo()
        }.flatMap { self.steptwo($0) }.flatMap { self.stepThree($0) }
    }

    private func steptwo(_ json: JSON) -> Observable<JSON> {
        let singNum = json["singNum"].stringValue
        let singAuthInfo = json["singAuthInfo"].stringValue
        let params = SetNickNameViewController.getAddressAndPubKey(mnemonic: wallet.mnemonic)
        return APIManager.fx.addressVerify(address: params.0,
                                           addressPubKey: params.1,
                                           signAuthNum: singNum,
                                           singAuthInfo: singAuthInfo,
                                           privateKey: params.2)
    }

    private func stepThree(_ json: JSON) -> Observable<JSON> {
        let ticket = json["ticket"].stringValue
        let nickName = wk.view.inputTF.text ?? ""
        let params = SetNickNameViewController.getAddressAndPubKey(mnemonic: wallet.mnemonic)
        return APIManager.fx.createNewNickName(address: params.0, addressPubKey: params.1, nickName: nickName, ticket: ticket)
    }
}

extension SetNickNameViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("WelcomeCreateWalletViewController", "SetNickNameViewController"): return animators["0"]
        case ("SetNickNameViewController", "SecurityTypeViewController"): return animators["1"]
        default: return nil
        }
    }

    private func bindHero() { weak var welk = self
        let onSuspendBlock: (WKHeroAnimator) -> Void = { _ in
            welk?.wk.view.navBar.hero.modifiers = nil
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.subtitleLabel.hero.modifiers = nil
            welk?.wk.view.inputTFContainer.hero.modifiers = nil
            welk?.wk.view.doneButton.hero.modifiers = nil
            if let view = welk?.wk.view {
                [view.tipView1, view.tipView2, view.tipView3, view.tipView4].each { _, tview in
                    tview.hero.modifiers = nil
                }
            }
        }
        animators["0"] = WKHeroAnimator({ _ in
            welk?.wk.view.navBar.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.inputTFContainer.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.doneButton.hero.modifiers = [.translate(y: 2500), .useGlobalCoordinateSpace]
            if let view = welk?.wk.view {
                [view.tipView1, view.tipView2, view.tipView3, view.tipView4].each { index, tview in
                    tview.hero.modifiers = [.fade, .translate(y: 10 + CGFloat(index) * 20), .useGlobalCoordinateSpace]
                }
            }
        }, onSuspend: onSuspendBlock)
        animators["1"] = WKHeroAnimator({ _ in
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.inputTFContainer.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.doneButton.hero.modifiers = [.translate(x: -1000), .useGlobalCoordinateSpace]
            if let view = welk?.wk.view {
                [view.tipView1, view.tipView2, view.tipView3, view.tipView4].each { index, tview in
                    let offsetX: CGFloat = -1.0 * CGFloat(1000 + (4 - index) * 20)
                    tview.hero.modifiers = [.fade, .translate(x: offsetX), .useGlobalCoordinateSpace]
                }
            }
        }, onSuspend: onSuspendBlock)
    }
}
