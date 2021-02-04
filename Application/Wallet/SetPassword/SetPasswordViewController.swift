//
//
//  XWallet
//
//  Created by May on 2020/12/17.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == SetPasswordViewController {
    var view: SetPasswordViewController.View { return base.view as! SetPasswordViewController.View }
}

extension SetPasswordViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = SetPasswordViewController(wallet: wallet)
        return vc
    }
}

extension SetPasswordViewController: NotificationToastProtocol {
    func allowToast(notif: FxNotification) -> Bool { false }
}

class SetPasswordViewController: WKViewController {
    
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
        
        view.doneButton.rx.tap.subscribe(onNext: { [weak self](_) in
            guard let this = self else { return }
            let text = view.inputTF.text ?? ""
            Router.pushToReSetPasswordViewController(wallet: this.wallet, pwd: text)
        }).disposed(by: defaultBag)
        
        view.closeButton.action {
            view.inputTF.resignFirstResponder()
            Router.showBackAlert()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var interactivePopIsEnabled: Bool {
        return false
    }
}
        
