//
//  FxWalletConnectViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/6.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import TrustWalletCore

extension WKWrapper where Base: WalletConnectViewController {
    var view: Base.View { return base.view as! Base.View }
}

class WalletConnectViewController: WKViewController {
    let url: String
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    override var interactivePopIsEnabled: Bool { false }
    
    override func loadView() { self.view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bind()
        connect()
    }
    
    override func bindNavBar() {
        
        navigationBar.action(.title, title: TR("WalletConnect.Title"))
        navigationBar.action(.back, imageName: "ic_back_black") {  [weak self] in
            self?.onClickBack()
        }
        navigationBar.hideLine()
    }
    
    func bind() {
        wk.view.disconnectButton.action { [weak self] in self?.onClickDisconnect() }
    }
    
    override func onClickBack() {
        if getSession().didApproveSession.value == true {
            Router.dismiss(self)
        } else {
            disconnect()
        }
    }
    
    func onClickDisconnect() {
        
        Router.pushToDisconnectWalletConnect() { [weak self] allow in
            if allow {
                self?.disconnect()
            }
        }
    }
    
    func getSession() -> WalletConnectSession { fatalError("implementation by subclass") }
       
    func connect() {
        getSession().connect()
    }
    
    func disconnect() { 
        let session = getSession()
        session.disconnect()
        session.release()
        Router.dismiss(self)
    }
}
