//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//
import WKKit
import RxSwift
import RxCocoa
import TrustWalletCore
import Hero

extension VerifyAlertViewController { 
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        let vc = VerifyAlertViewController()
        vc.completionHandler = context["handler"] as? (Bool) -> Void
        return vc
    }
}

class VerifyAlertViewController: FxRegularPopViewController {
    var completionHandler:((Bool) -> Void)?
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override var dismissWhenTouch: Bool { false }
    
    override func bindListView() {
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { [weak self] cell in
            self?.reBackWelcome(cell: cell)
        }
    }
    
    private func reBackWelcome(cell:ActionCell) {
        cell.confirmButton.rx.tap.subscribe(onNext: { [weak self] in
            Router.dismiss(self, animated: false) {
                self?.completionHandler?(true)
            }
        }).disposed(by: defaultBag)
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}

extension VerifyAlertErrorViewController {
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        let vc = VerifyAlertErrorViewController()
        vc.completionHandler = context["handler"] as? (Bool) -> Void
        return vc
    }
}

class VerifyAlertErrorViewController: FxRegularPopViewController {
    var completionHandler:((Bool) -> Void)?
    override var dismissWhenTouch: Bool { false }
  
    override func bindListView() {
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { [weak self] cell in
            self?.reBackWelcome(cell: cell)
        }
    }
    
    private func reBackWelcome(cell:ActionCell) {
        cell.confirmButton.rx.tap.subscribe(onNext: { [weak self] in
            Router.dismiss(self, animated: false) {
                self?.completionHandler?(true)
            }
        }).disposed(by: defaultBag)
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}




extension VerifyStopAlertViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        let vc = VerifyStopAlertViewController()
        vc.completionHandler = context["handler"] as? (WKError?) -> Void
        return vc
    }
}

class VerifyStopAlertViewController: FxRegularPopViewController {
    
    var completionHandler: ((WKError?) -> Void)?
    
    override var dismissWhenTouch: Bool { false }
    
    override func bindListView() {
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { [weak self] cell in
            cell.confirmButton.action {
                self?.reBackWelcome()
            }
            cell.cancelButton.action { [weak self] in
                guard let this = self else { return }
                Router.dismiss(this) {
                     this.completionHandler?(.canceled)
                }
            }
        }
    }
    
    private func reBackWelcome() {
        Router.dismiss(self) {
            self.completionHandler?(.success)
        }
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}

