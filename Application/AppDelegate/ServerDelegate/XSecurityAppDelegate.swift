//
//  XSecurityAppDelegate.swift
//  XWallet
//
//  Created by Andy.Chan on 2019/9/4.
//  Copyright © 2019 Chen Andy. All rights reserved.
//

import UIKit
import WKKit
import SnapKit
import RxSwift
import RxCocoa
import PluggableApplicationDelegate

class XSecurityAppDelegate: XApplicationService {
    var snapshotView:UIView?
    weak var lastFirstResponder:UIResponder?
    var isSecured:Bool {
        return XWallet.sharedKeyStore.currentWallet != nil
    }
    
    var verificationIsRequired:Bool {
        return XWallet.currentWallet?.wk.verificationIsRequired ?? false
    }
    
    var isEnable:Bool = true
    
    private var _secureView:UIView? = nil
    var secureView: UIView {
        guard let view = _secureView else { 
            let secureView = UIView(frame:UIScreen.main.bounds)
            if UIAccessibility.isReduceTransparencyEnabled == false {
                let style = UIBlurEffect.Style.dark
                let blurEffect: UIBlurEffect = UIBlurEffect(style: style)
                let blurView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
                secureView.backgroundColor = HDA(0x080A32)
                secureView.addSubview(blurView)
                blurView.frame = secureView.bounds
                
                let logoIV = UIImageView(image: IMG("launch_logo"))
                logoIV.alpha = 0.6
                secureView.addSubview(logoIV)
                if self.verificationIsRequired {
                    logoIV.snp.makeConstraints { (make) in
                        make.top.equalTo(StatusBarHeight + 54.auto())
                        make.size.equalTo(CGSize(width: 78, height: 78).auto())
                        make.centerX.equalToSuperview()
                    }
                }else {
                    logoIV.snp.makeConstraints { (make) in
                        make.size.equalTo(CGSize(width: 100, height: 100))
                        make.center.equalToSuperview()
                    }
                }
                
            }else {
                secureView.backgroundColor = HDA(0x080A32)
            }
            _secureView = secureView
            return secureView
        }
        return view
    }
    
    private func openSecureView() {
        guard isEnable else {
            return
        }
        
        if let window = self.window , isSecured{
            secureView.frame = window.bounds
            window.addSubview(secureView)
            window.bringSubviewToFront(secureView)
            if let keyboardCandidateWindow = UIApplication.shared.windows.lastObject() {
                if window.isEqual(keyboardCandidateWindow) == false {
                    let isHidden = keyboardCandidateWindow.isHidden
                    keyboardCandidateWindow.isHidden = true
                    self.lastFirstResponder = window.findFirst()
                    if self.lastFirstResponder == nil {
                        self.lastFirstResponder = window.rootViewController?.findFirst()
                    }
                    let inputIsHidden = self.lastFirstResponder?.inputAccessoryView?.isHidden ?? false
                    self.lastFirstResponder?.inputAccessoryView?.isHidden = true
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute:{
                        self.lastFirstResponder?.resignFirstResponder()
                        keyboardCandidateWindow.isHidden = isHidden
                        self.lastFirstResponder?.inputAccessoryView?.isHidden = inputIsHidden
                    })

                }
            }
        }
    }
    
    private func closeSecureView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.secureView.alpha = 0
        }) { (result) in
            self.secureView.removeFromSuperview()
            self.secureView.alpha = 1
            self._secureView = nil
            if self.lastFirstResponder?.canBecomeFirstResponder ?? false {
                self.lastFirstResponder?.becomeFirstResponder()
            }
        }
    }
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let wallet = XWallet.sharedKeyStore.currentWallet?.wk
        wallet?.verificationInBackgroundTime = nil
        
        WKServer.addServer(aClass: FxNotificatioinAlertServer.self) 
        XEvent.App.ApplicationDidEnterBackground.on { (_) in
            let _wallet = XWallet.sharedKeyStore.currentWallet?.wk
            if _wallet?.verificationIsRequired ?? false {
                _wallet?.verificationInBackgroundTime = Date()
            }
        }.disposed(by: defaultBag)
        
        checkSecurityVerification()
        return true
    }
 
    func applicationDidBecomeActive(_ application: UIApplication) {
        closeSecureView()
        isEnable = true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        openSecureView()
        application.ignoreSnapshotOnNextApplicationLaunch()
        isEnable = true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        checkSecurityVerification()
    }
}


extension XSecurityAppDelegate {
    private func checkIsInlimitTime(_ wallet: WKWallet) ->Bool {
        let limitTime:Int = 5 * 60
        if let bDate = wallet.verificationInBackgroundTime {
            let currentDate:Date = Date()
            let components = NSCalendar.current.dateComponents([.second, .minute], from: bDate, to: currentDate)
            let second = ((components.minute ?? 0) * 60 + (components.second ?? 0))
            if second <= limitTime {
                return true
            }
        }
        return false
    }
    
    private func checkBiometrics() {
        guard XWallet.currentWallet != nil else { return }
        
        let authInfoChanged = LocalAuthManager.shared.checkAuthInfo()
        if authInfoChanged {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                let authId = TR(LocalAuthManager.shared.isAuthFace ? "FaceId" : "TouchId")
                WKRouter.window?.rootViewController?.hud?.error(m: TR("Settings.$BiometricsChanged", authId), d: 2)
            }
        }
    }
    
    private func checkSecurityVerification() {
        checkBiometrics()
        
        guard let wallet = XWallet.currentWallet?.wk else { return }
        guard wallet.hasSecurity, wallet.verificationIsRequired else { return }
         
        if checkIsInlimitTime(wallet) { return }
        
        let aClassString:String = "SecurityVerificationController"
        let viewController = Router.viewController(aClassString) as! SecurityVerificationController
        viewController.view.frame = UIScreen.main.bounds
        viewController.view.layoutIfNeeded()
        snapshotView?.removeFromSuperview()
        let snapshotView = viewController.view.snapshotView(afterScreenUpdates: true) ?? UIImageView(frame: UIScreen.main.bounds).then { $0.image = viewController.view.asImage() }
        self.snapshotView = snapshotView
         
        Router.window?.addSubview(snapshotView)
        viewController.didComplatedSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                snapshotView.removeFromSuperview()
            }).disposed(by: defaultBag)
         
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            if let topViewController = Router.topViewController,
               (topViewController.heroIdentity == aClassString) {
                snapshotView.removeFromSuperview()
                return
            }
            
            if let topViewController = Router.topViewController?.presentingViewController,
               (topViewController.heroIdentity == aClassString) {
                snapshotView.removeFromSuperview()
                return
            }
            
            if Router.isSecurityVerifying {
                snapshotView.removeFromSuperview()
                return
            }
            
            let navController = SecurityVerificationNavController(rootViewController: viewController)
            Router.topViewController?.present(navController, animated: false, completion: {
                snapshotView.removeFromSuperview()
            })
            viewController.toStartVerify(delay: 600)
        }
    }
}

 
