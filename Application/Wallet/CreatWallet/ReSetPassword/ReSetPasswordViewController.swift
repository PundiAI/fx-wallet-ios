 
import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == ReSetPasswordViewController {
    var view: ReSetPasswordViewController.View { return base.view as! ReSetPasswordViewController.View }
}

extension ReSetPasswordViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet, let pwd = context["pwd"] as? String  else { return nil }
        let vc = ReSetPasswordViewController(wallet: wallet, pwd: pwd)
        return vc
    }
}

extension ReSetPasswordViewController: NotificationToastProtocol {
    func allowToast(notif: FxNotification) -> Bool { false }
}

class ReSetPasswordViewController: WKViewController {
    
    private var pwd: String
    private let wallet: WKWallet
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, pwd: String) {
        self.wallet = wallet
        self.pwd = pwd
        super.init(nibName: nil, bundle: nil)
    }

    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        logWhenDeinit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wk.view.inputTF.becomeFirstResponder()
    }
    
    private func bind() {
        let view = wk.view
        let enabled = view.inputTF.rx.text.map{ ($0?.count ?? 0) >= 6 && ($0?.count ?? 0) <= 128 }
        enabled.asObservable()
            .bind(to: view.doneButton.rx.isEnabled)
            .disposed(by: defaultBag)
        
        view.doneButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let this = self else { return }
            let text = view.inputTF.text ?? ""
            if text == this.pwd {
                this.wallet.accessCode = this.pwd
                this.wallet.createCompleted = .setSecurity
                Router.pushToSetBiometricsViewController(wallet: this.wallet)
            } else {
                this.hud?.text(m: TR("SetPwd.Set.NotMatch"))
            }
        }).disposed(by: defaultBag)
        
        view.closeButton.action {
            Router.pop(self)
        }
        
        view.noteView.rx.tapGesture().subscribe(onNext: { _ in
            view.inputTF.resignFirstResponder()
        }).disposed(by: defaultBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var interactivePopIsEnabled: Bool {
        return false
    }
}
        
