//
//  FxAppUpgradeServer.swift
//  fxWallet
//
//  Created by Pundix54 on 2021/4/15.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON
import SystemServices

extension FxAPIManager {
    private var apiHost: String {
        return "\(NetworkServer.hosts.api)/\(ThisAPP.secondhost)"
    }
    
    func checkAppUpgrade() -> Observable<FxAppUpgradeModel> {
        let version = SystemServices.shared().applicationVersion ?? ""
        let params: [String : Any] = ["appVersion": version, "deviceType": "IOS"]
        return rx.post("\(apiHost)/v1/common/appVersion/check",parameters: params)
    }
}

class FxAppUpgradeModel: Model {
    var message:String = ""
    var version:String = "-"
    var timestamp:Int64 = 0
    var needUpgrade:Bool = false
    
    override class func instance(json: JSON) -> FxAppUpgradeModel {
        let model = FxAppUpgradeModel()
        model.message = json["content"].stringValue
        model.version = json["version"].stringValue
        model.timestamp = json["dt"].int64Value
        model.needUpgrade = json["needUpgrade"].boolValue
        return model
    }
}

private let maxTimeOut:TimeInterval = 60 * 60 * 24
private let maxDelay:RxTimeInterval = .seconds(10)

class FxAppUpgradeServer: NSObject, WKServerProtocol  {
    func contentDescription() -> String { return "-" }
    var showDate:Date?
    
    var resetBag = DisposeBag()
    func register(params: Any?) {
        XEvent.App.ApplicationDidBecomeActive.on {[weak self] (_) in
            guard let this = self else { return }
            this.resetBag = DisposeBag()
            FxAPIManager.fx.checkAppUpgrade()
                .filter { $0.needUpgrade &&
                    $0.version.isEmpty == false &&
                    $0.message.isEmpty == false && this.needUpdate() }
                .observeOn(MainScheduler.instance)
                .delay(maxDelay, scheduler: MainScheduler.instance)
                .subscribe(onNext: { model in
                    this.showViewController(message: model.message,
                                            version: model.version)
                }).disposed(by: this.resetBag)
        }.disposed(by: defaultBag)
        
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
    
    func showViewController(message:String, version:String) {
        if let _ = Router.topViewController as? FxAppUpgradeAlertController {
            self.showDate = Date()
        }else {
            let isAnimated = Router.currentNavigator?.transitionCoordinator?.isAnimated ?? false
            let isOpenMenu = ((Router.tabBarController as? FxTabBarController)?.menuView?.stateSubject.value ?? .closed) == .open
            let vControllers:[AnyClass] = [SetPasswordViewController.self, FxPopViewController.self, SecurityVerificationController.self]
            if let topViewController = Router.topViewController,
               vControllers.filter({ topViewController.isKind(of: $0) }).count > 0  ||
               isAnimated || isOpenMenu {
                Observable.just(()).delay(maxDelay, scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        self?.showViewController(message: message, version: version)
                    }, onCompleted: { [weak self] in
                        self?.showDate = Date()
                    }).disposed(by: self.resetBag)
            }else {
                self.showDate = Date()
                Router.showAppUpgradeAlert(message: message, version: version)
            }
        } 
    }
}
