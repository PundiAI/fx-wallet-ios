//
//  FxNotificatioinAlertServer.swift
//  fxWallet
//
//  Created by Pundix54 on 2021/5/12.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON
import SystemServices
 
private let maxTimeOut:TimeInterval = 60 * 60 * 24
private let maxDelay:RxTimeInterval = .seconds(4)

class FxNotificatioinAlertServer: NSObject, WKServerProtocol  {
    func contentDescription() -> String { return "-" }
    var showDate:Date?
    
    var resetBag = DisposeBag()
     
    func register(params: Any?) {
        
        let delayAction:(URL?)->Void = { [weak self] url in
            guard let this = self else { return }
            Observable.just(()).delay(maxDelay, scheduler: MainScheduler.instance)
                .filter { this.needUpdate() }
                .subscribe(onNext: { _ in 
                    this.showViewController(toURL: url)
                }).disposed(by: this.resetBag)
        }
         
        let block:(Any?)->Void = { [weak self] (_) in
            guard let _ = XWallet.currentWallet?.wk else { return }
            guard let this = self else { return }
            this.resetBag = DisposeBag()
            if WKRemoteServer.didRequestRemoteNotif != -3 {
                WKRemoteServer.request().map { $0 == 1 }.subscribe(onNext: { result in
                    if result == false {
                        delayAction(URL(string: UIApplication.openSettingsURLString))
                    }
                }).disposed(by: this.resetBag)
            } else {
                delayAction(nil)
            }
        }
        
        XEvent.App.ApplicationDidBecomeActive.on(block).disposed(by: defaultBag)
        XEvent.User.DidLogin.on(block).disposed(by: defaultBag)
        
        XEvent.App.ApplicationDidEnterBackground.on {[weak self]  (_) in
            guard let this = self else { return }
            this.resetBag = DisposeBag()
        }.disposed(by: defaultBag)
    }
    
    func needUpdate() -> Bool {
        if let uDate = self.showDate, (Date().timeIntervalSince1970 - uDate.timeIntervalSince1970) <= maxTimeOut {
            return false
        }
        return true
    }
    
    func showViewController(toURL:URL? = nil) {
        if let _ = Router.topViewController as? NotificationAlertController {
            self.showDate = Date()
        }else {
            if let topViewController = Router.topViewController {
                let inHome:Bool = Router.tabBarController?.isKind(of: FxTabBarController.self) ?? false
                let isAnimated = Router.currentNavigator?.transitionCoordinator?.isAnimated ?? false
                let isOpenMenu = ((Router.tabBarController as? FxTabBarController)?.menuView?.stateSubject.value ?? .closed) == .open
                if inHome == false || isAnimated || isOpenMenu || (topViewController.isKind(of:FxPopViewController.self) || topViewController.isKind(of:SecurityVerificationController.self)) {
                        Observable.just(()).delay(maxDelay, scheduler: MainScheduler.instance)
                            .subscribe(onNext: { [weak self] in
                                self?.showViewController()
                            }, onCompleted: { [weak self] in
                                self?.showDate = Date()
                            }).disposed(by: self.resetBag)
                    }else {
                        self.showDate = Date()
                        let toSetting:Bool = toURL != nil
                        Router.showNotificationAlert(toSetting:toSetting, completionHandler: { result in
                            if let value = result {
                                WKRemoteServer.didRequestRemoteNotif = value ? 1 : 0
                                if !value, let url = toURL, UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        })
                    }
            }
        }
    }
}
