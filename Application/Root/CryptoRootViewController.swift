//
//  DappRootViewController.swift
//  XWallet
//
//  Created by Pundix54 on 2020/10/14.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import UIKit
import Hero
import WKKit
import HapticGenerator
import TrustWalletCore
 
// MARK:- Dapp
class CryptoRootViewController: CryptoBankViewController {
    override init(wallet: WKWallet) {
        super.init(wallet: wallet)
//        bindHero()
        self.edgesForExtendedLayout = .bottom
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wk.view.listView.tableFooterView = UIView(frame: CGRect(origin: CGPoint.zero,
                                                                size: CGSize(width: 0, height: TabBarHeight) ))
    }
}

extension WKWrapper where Base == CryptoRootViewController {
    var view: CryptoRootViewController.View { return base.view as! CryptoRootViewController.View }
}

extension CryptoRootViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let viewController = CryptoRootViewController(wallet: wallet)
        
        return viewController
    }
}

// MARK: Hero(Crypto)
extension CryptoRootViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { 
        switch (from, to) {
        case ("CryptoRootViewController", "SendTokenInputViewController"):  return animators["0"]
        case ("CryptoRootViewController", "SelectOrAddAccountViewController"):  return animators["0"]
        case ("CryptoRootViewController", "ReceiveTokenViewController"): return animators["0"]
        default: return nil
        }
    }

    private func bindHero() {
        weak var welf = self
        animators["0"] = WKHeroAnimator({ (_) in
            welf?.wk.view.backgoundView.hero.id = "token_list_background"
            welf?.wk.view.backgoundView.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
            welf?.navigationBar.hero.modifiers =  [.useOptimizedSnapshot, .useGlobalCoordinateSpace,
                                                   .translate(y: -200)]
            welf?.wk.view.listView.hero.modifiers = [.useNormalSnapshot, .useGlobalCoordinateSpace,
                                                  .translate(y: 1000) ]
        }, onSuspend: { (_) in
            welf?.navigationBar.hero.modifiers =  nil
            welf?.wk.view.listView.hero.modifiers = nil
            welf?.wk.view.backgoundView.hero.modifiers = nil
        })
    }
    
    
}
