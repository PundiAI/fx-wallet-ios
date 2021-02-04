//
//  SetMnemonicPasswordViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/11/26.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension PrepareMnemonicViewController {
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let nextHandler = context["handler"] as? () -> Void else { return nil }
        
        let vc = PrepareMnemonicViewController()
        vc.nextHandler = nextHandler
        return vc
    }
}

class PrepareMnemonicViewController: WKViewController {

    override var preferFullTransparentNavBar: Bool { return true }
    
    private var nextHandler: ( () -> Void )?
    override func loadView() {
        
        let view = View(frame: ScreenBounds)
        self.view = view
        
        view.startButton.action { [weak self] in
            
            Router.showVerifyPasswordAlert() { error in
                guard error == nil else { return }
                
                self?.nextHandler?()
            }
        }
    }
}
