

import WKKit
import RxSwift
import RxCocoa
import TrustWalletCore
import Hero

class BackAlertViewController: FxRegularPopViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.bindHero()
        logWhenDeinit()
    }
    
    
    override var dismissWhenTouch: Bool { false }
    override var interactivePopIsEnabled: Bool { false }
    override func bindListView() { 
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    private func bindAction(_ cell: ActionCell) {
           
           weak var welf = self
           cell.cancelButton.rx.tap.subscribe(onNext: { (_) in
               welf?.dismiss()
           }).disposed(by: cell.defaultBag)
           
           cell.confirmButton.rx.tap.subscribe(onNext: { (_) in
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
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        Router.pop(self, animated: animated, completion: completion)
    }
}

/// hero
extension BackAlertViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        return to == "BackAlertViewController" ? animators["0"] : nil
    }

    private func bindHero() {
        animators["0"] = self.heroAnimatorBackgound()
    }
}

