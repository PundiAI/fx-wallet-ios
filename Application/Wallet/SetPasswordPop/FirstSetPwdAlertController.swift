import Hero
import pop
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit

extension FirstSetPwdAlertController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = FirstSetPwdAlertController(wallet: wallet)
        vc.completionHandler = context["handler"] as? (WKError?) -> Void
        return vc
    }
}

class FirstSetPwdAlertController: FxPopViewController {
    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    private let wallet: WKWallet
    private let viewS = FirstSetPwdView(frame: ScreenBounds)
    private var keeper: Any?
    fileprivate lazy var inputPwdBinder = InputPwdBinder(view: viewS.pwdInputView)
    fileprivate lazy var pwdComfirmBinder = InputPwdBinder(view: viewS.pwdConfirmView)
    var completionHandler: ((WKError?) -> Void)?
    override func loadView() { view = viewS }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInputPwd()
        bindInputComfirm()
        logWhenDeinit()
    }

    override func bindAction() {}
    private func bindInputPwd() {
        weak var welf = self
        let confirmAction = Action<Bool, Void>(workFactory: { passed in
            if passed {
                welf?.keeper = welf
                welf?.toConfirmAction {}
            } else {
                welf?.hud?.error(m: TR("password error"))
            }
            return CocoaObservable.empty()
        })
        inputPwdBinder.bind(backAction: closeAction, confirmAction: confirmAction)
    }

    private func toConfirmAction(completionBlock: @escaping () -> Void) {
        viewS.pwdConfirmView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
        viewS.pwdConfirmView.pop_add(scaleAnimation, forKey: "kPOPViewScaleXY")
        let translationXY = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
        translationXY?.toValue = CGSize(width: 0, height: -1 * ScreenHeight)
        viewS.pwdConfirmView.layer.pop_add(translationXY, forKey: "kPOPLayerTranslationXY")
        let scaleAnimation0 = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation0?.toValue = NSValue(cgSize: CGSize(width: 0.8, height: 0.8))
        viewS.pwdInputView.pop_add(scaleAnimation0, forKey: "kPOPViewScaleXY0")
        let translationXY0 = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
        translationXY0?.toValue = CGSize(width: 0, height: ScreenHeight)
        viewS.pwdInputView.layer.pop_add(translationXY0, forKey: "kPOPLayerTranslationXY0")
        viewS.pwdConfirmView.inputTF.becomeFirstResponder()
        translationXY?.completionBlock = { _, _ in
            completionBlock()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputPwdBinder.startVerify()
    }

    private func bindInputComfirm() { weak var welf = self
        let confirmAction = Action<Bool, Void>(workFactory: { passed in
            if passed {
                welf?.keeper = welf
                if let pwd = welf?.viewS.pwdInputView.inputTF.text, let pwd2 = welf?.viewS.pwdConfirmView.inputTF.text {
                    if pwd == pwd2 {
                        welf?.hud?.text(m: TR("SetPwd.Set.Success"))
                        welf?.wallet.accessCode = pwd
                        welf?.wallet.createCompleted = .setSecurity
                        Router.dismiss(welf, animated: true) {
                            welf?.completionHandler?(nil)
                        }
                    } else {
                        welf?.hud?.text(m: TR("SetPwd.Set.NotMatch"), p: .topCenter)
                        welf?.viewS.pwdConfirmView.inputTFContainer.borderColor = COLOR.errorborderB
                    }
                }
            } else {
                welf?.hud?.error(m: TR("password error"))
            }
            return CocoaObservable.empty()
        })
        pwdComfirmBinder.bind(backAction: closeAction, confirmAction: confirmAction)
        pwdComfirmBinder.view.inputTF.rx.text.distinctUntilChanged().subscribe(onNext: { _ in
            welf?.viewS.pwdConfirmView.inputTFContainer.borderColor = HDA(0x2242C1)
        }).disposed(by: defaultBag)
    }

    private func executeCompletionHandler(error: WKError? = nil, result _: JSON = [:]) {
        if error != nil {
            hud?.text(m: error?.msg ?? TR("commit tx failed"), d: 3, p: .center)
        }
        completionHandler?(error)
        keeper = nil
    }

    private var closeAction: CocoaAction {
        return CocoaAction { [weak self] in
            self?.viewS.pwdInputView.inputTF.resignFirstResponder()
            self?.viewS.pwdConfirmView.inputTF.resignFirstResponder()
            Router.dismiss(self) {
                self?.completionHandler?(.canceled)
            }
        }
    }
}

extension FirstSetPwdAlertController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case (_, "FirstSetPwdAlertController"): return animators["0"]
        default: return nil
        }
    }

    private func bindHero() {
        weak var welf = self
        let animator = WKHeroAnimator({ _ in
            welf?.viewS.pwdInputView.backgroundBlur.alpha = 0
            welf?.viewS.pwdConfirmView.backgroundBlur.alpha = 0
            welf?.viewS.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                         .useGlobalCoordinateSpace]
            let modifiers: [HeroModifier] = [.useGlobalCoordinateSpace,
                                             .useOptimizedSnapshot, .translate(y: 1000)]
            welf?.viewS.containerView.hero.modifiers = modifiers
        }, onSuspend: { _ in
            welf?.viewS.backgroundBlur.hero.modifiers = nil
            welf?.viewS.containerView.hero.modifiers = nil
        })
        animators["0"] = animator
    }
}
