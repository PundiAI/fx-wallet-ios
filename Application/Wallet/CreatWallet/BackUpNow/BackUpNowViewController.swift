

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == BackUpNowViewController {
    var view: BackUpNowViewController.View { return base.view as! BackUpNowViewController.View }
}

extension BackUpNowViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = BackUpNowViewController(wallet: wallet)
        return vc
    }
}

extension BackUpNowViewController: NotificationToastProtocol {
    func allowToast(notif: FxNotification) -> Bool { false }
}

class BackUpNowViewController: WKViewController {
    private let wallet: WKWallet
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindAction()
        logWhenDeinit()
    }

    private func bindAction() {
        wk.view.backUpButton.action { [weak self] in
            self?.goToBackUp()
        }
        
        wk.view.notNowButton.action { [weak self] in
            Router.showWalletBackUpAlert { (type) in
                switch type {
                case .backup: self?.goToBackUp()
                case .skip: self?.goWallet()
                }
            } 
        }
        
        wk.view.closeButton.action {
            Router.showBackAlert()
        }
        
        wallet.createCompleted = .backup
    }
    
    private func goToBackUp() {
        
        guard let wallet = XWallet.sharedKeyStore.currentWallet else {
            self.hud?.text(m: TR("Error 100"), p: .topCenter)
            return
        }
        wallet.wk.createCompleted = .completed
        Router.pushToBackUpNotice(wallet: wallet.wk) { vc in
            Router.setRootController(wallet: wallet,
                                     viewControllers: [vc])
        }
    }
    
    //MARK: Action
    @objc private func goWallet() {
        guard let wallet = XWallet.sharedKeyStore.currentWallet else {
            self.hud?.text(m: TR("Error 100"), p: .topCenter)
            return
        }
        
        wallet.wk.createCompleted = .completed
        Router.resetRootController(wallet: wallet, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var interactivePopIsEnabled: Bool {
        return false
    }
}

/// Hero
extension BackUpNowViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { 
        switch (from, to) {
        case ("SecurityTypeViewController", "BackUpNowViewController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() { 
        weak var welf = self
        animators["0"] = WKHeroAnimator({ _ in
            welf?.wk.view.titleLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welf?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: 1000), .useGlobalCoordinateSpace]
            welf?.wk.view.backUpButton.hero.modifiers = [.fade,.translate(x: 1000), .useGlobalCoordinateSpace]
            welf?.wk.view.notNowButton.hero.modifiers = [.fade,.translate(x: 1000), .useGlobalCoordinateSpace]
        }, onSuspend: { _ in
            welf?.wk.view.titleLabel.hero.modifiers = nil
            welf?.wk.view.subtitleLabel.hero.modifiers = nil
            welf?.wk.view.backUpButton.hero.modifiers = nil
            welf?.wk.view.notNowButton.hero.modifiers = nil
        })
    }
}


