//
//  NotificationAlertController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit
import RxSwift
import TrustWalletCore

extension NotificationAlertController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let completionHandler = context["handler"] as? ((Bool) -> Void) else {
            return nil
        }
        return NotificationAlertController(completionHandler: completionHandler)
    }
}


class NotificationAlertController: FxRegularPopViewController {
    let completionHandler:(Bool) -> Void
    override var dismissWhenTouch: Bool { false }
    override var interactivePopIsEnabled: Bool { false }
    
    init(completionHandler:@escaping (Bool) -> Void) {
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindListView() {
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        Router.pop(self)
    }
    
    private func bindAction(_ cell: ActionCell) {
        
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { (_) in
            Router.dismiss(welf)
            welf?.completionHandler(false)
        }).disposed(by: cell.defaultBag)
        
        cell.confirmButton.rx.tap.asObservable().flatMap { (_) -> Observable<Bool> in
            return WKRemoteServer.request().map {  $0 == 1 }
        }.subscribe(onNext: { result in 
            Router.dismiss(welf)
            welf?.completionHandler(result)
            guard let wallet = XWallet.sharedKeyStore.currentWallet else { return }
            wallet.wk.pushState = result
            if result {
                wallet.wk.accountPushState = result
                wallet.wk.systePushState = result
            }
        }).disposed(by: cell.reuseBag)
    }
    
    override func layoutUI() {
        hideNavBar()
        setBackgoundOverlayViewImage()
    }
}

 
