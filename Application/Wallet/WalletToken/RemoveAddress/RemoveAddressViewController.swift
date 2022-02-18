//
//  RemoveTokenViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import TrustWalletCore
import Hero

extension RemoveAddressViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        let vc = RemoveAddressViewController()
        vc.completionHandler = context["handler"] as? (WKError?) -> Void
        return vc
    }
}

class RemoveAddressViewController: FxRegularPopViewController {
    
    var completionHandler: ((WKError?) -> Void)?
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.bindHero()
    }
    
    override var dismissWhenTouch: Bool { true }
    override var interactivePopIsEnabled: Bool { false }
    override func bindListView() {
        
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    private func bindAction(_ cell: ActionCell) {
        
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { (_) in 
            Router.pop(welf)
        }).disposed(by: cell.defaultBag)
        
        cell.confirmButton.action {
            welf?.completionHandler?(nil)
            Router.pop(welf)
        }
    }
     
    override func layoutUI() {
        hideNavBar()
    }
}

/// hero
extension RemoveAddressViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
         
        switch (from, to) {
        case ("TokenActionSheet", "RemoveAddressViewController"): return animators["0"]
        case ("TokenInfoViewController", "RemoveAddressViewController"): return animators["1"]
        default: return nil
        }
    }
    
    private func getOverlayView() ->UIView? {
        return Router.currentNavigator?.viewControllers.last(where: { (vc) -> Bool in
            return vc.heroIdentity == "TokenInfoViewController"
        })?.view
    }
    
    private func bindHero() {
        weak var welf = self
        animators["0"] = self.heroAnimatorBackgoundTo(for: welf?.getOverlayView())
        animators["1"] = self.heroAnimatorBackgound(for: welf?.getOverlayView())
    }
}

 
