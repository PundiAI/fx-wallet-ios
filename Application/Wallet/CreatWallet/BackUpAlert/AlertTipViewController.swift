 
import WKKit
import RxSwift
import RxCocoa
import TrustWalletCore
import Hero
import Macaw

enum WalletBackUpType : Int {
    case skip = 0
    case backup
}

extension WalletBackUpAlertController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        let vc = WalletBackUpAlertController()
        vc.completionHandler = context["handler"] as? (WalletBackUpType) -> Void
        return vc
    }
}

class WalletBackUpAlertController: FxRegularPopViewController {
    var topViewController:UIViewController?
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.bindHero() 
        self.topViewController = Router.topViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var completionHandler: ((WalletBackUpType) -> Void)?
    override var navBarHeight: CGFloat { 72.auto() }
    override func bindListView() {
        weak var welf = self
        listBinder.push(ContentCell.self)
        let cell = listBinder.push(ActionCell.self)
        
        cell.stillSkipButton.action {
            if let handler = welf?.completionHandler {
                Router.showWalletBackUpAlertSecond(completionHandler: handler,
                                                   topViewController: welf?.topViewController) { _ in
                    Router.remove(self)
                }
            }
        }
         
        cell.backUpButton.action {
            Router.pop(welf, animated: true) {
                welf?.completionHandler?(.backup)
            }
        }
    }
     
    override func dismiss(userCanceled: Bool = false,
                          animated: Bool = true, completion: (() -> Void)? = nil) {
        Router.pop(self)
    }
}

extension WalletBackUpAlertController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case (_, "WalletBackUpAlertController"): return animators["0"]
        case ("WalletBackUpAlertController", "WalletBackUpAlertSecondController"): return animators["1"]
        default: return nil
        }
    }
    
    private func bindHero() {
        animators["0"] = self.heroAnimatorBackgound()
        animators["1"] = self.heroAnimatorBackgoundFrom()
    }
}


extension WalletBackUpAlertSecondController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        let vc = WalletBackUpAlertSecondController()
        vc.completionHandler = context["handler"] as? (WalletBackUpType) -> Void
        vc.topViewControler =  context["topViewController"] as? UIViewController
        vc.bindHero()
        return vc
    }
}

class WalletBackUpAlertSecondController: FxRegularPopViewController {
    var completionHandler: ((WalletBackUpType) -> Void)?
    var topViewControler:UIViewController?
 
    override var navBarHeight: CGFloat { 72.auto() }
    override func bindListView() {
        weak var welf = self
        listBinder.push(ContentCell.self)
        let cell = listBinder.push(ActionCell.self)
        
        cell.skipButton.action {
            Router.pop(welf) {
                welf?.completionHandler?(.skip)
            }
        }
        
        cell.cancelButton.action {
            Router.pop(welf)
        }
    }
    
    override func dismiss(userCanceled: Bool = false,
                          animated: Bool = true, completion: (() -> Void)? = nil) {
        Router.pop(self)
    }
}

extension WalletBackUpAlertSecondController: HeroViewControllerDelegate {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("TokenRootViewController", "WalletBackUpAlertSecondController"): return animators["1"]
        case ("WalletBackUpAlertController", "WalletBackUpAlertSecondController"): return animators["0"]
        default:
            return nil
        }
    }
    
    private func bindHero() {
        animators["0"] = self.heroAnimatorBackgoundTo(for: self.topViewControler?.view)
        animators["1"] = self.heroAnimatorDefault()
    }
}
