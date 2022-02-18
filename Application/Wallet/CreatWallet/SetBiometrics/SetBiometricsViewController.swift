 
import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == SetBiometricsViewController {
    var view: SetBiometricsViewController.View { return base.view as! SetBiometricsViewController.View }
}

extension SetBiometricsViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = SetBiometricsViewController(wallet: wallet)
        return vc
    }
}

extension SetBiometricsViewController: NotificationToastProtocol {
    func allowToast(notif: FxNotification) -> Bool { false }
}

class SetBiometricsViewController: WKViewController {
    
    private let wallet: WKWallet
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        logWhenDeinit()
    }
    
    private func bind() {
        
        wk.view.backUpButton.action { [weak self] in
            self?.enableBiometrics()
        }
        
        wk.view.notNowButton.action { [weak self] in
            self?.goBackUpNow()
        }
        
        wk.view.closeButton.action {
            Router.showBackAlert()
        }
        
        wallet.createCompleted = .setBio
    }
    
    //MARK: Action
    
    @objc private func enableBiometrics() {
        
        guard LocalAuthManager.shared.isEnabled else {
            let authId = TR(LocalAuthManager.shared.isAuthFace ? "FaceId" : "TouchId")
            self.hud?.error(m: TR("Settings.$BiometricsDisable",authId))
            return
        }
        Router.showSetBioAlert { [weak self](error) in
            guard let wallet = self?.wallet else { return }
            guard let this = self else { return }
            if error == nil {
                this.wallet.createCompleted =  .setSecurity
                LocalAuthManager.shared.userAllowed = true
                if let type = wallet.registerType, type == .importT {
                    wallet.createCompleted = .completed
                    wallet.isBackuped = true
                    Router.resetRootController(wallet: wallet.rawValue, animated: true)
                } else {
                    Router.pushToBackUpNow(wallet: wallet)
                }
            }
        }
    }
    
    @objc private func goBackUpNow() {
        
        if let type = wallet.registerType, type == .importT {
            wallet.createCompleted = .completed
            wallet.isBackuped = true
            Router.resetRootController(wallet: wallet.rawValue, animated: true)
        } else {
            Router.pushToBackUpNow(wallet: wallet)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var interactivePopIsEnabled: Bool {
        return false
    }
}

