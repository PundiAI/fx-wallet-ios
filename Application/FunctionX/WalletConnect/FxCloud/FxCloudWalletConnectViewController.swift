//
//  FxValidatorConnectViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/5/14.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import TrustWalletCore

extension FxCloudWalletConnectViewController {
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let url = context["url"] as? String,
            let wallet = context["wallet"] as? Wallet else {
            return nil
        }
        
        return FxCloudWalletConnectViewController(url: url, wallet: wallet)
    }
}

class FxCloudWalletConnectViewController: WalletConnectViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(url: String, wallet: Wallet) {
        
        let url = url.replacingOccurrences(of: "FXSocket:", with: "")
        self.wallet = wallet
        super.init(url: url)
    }
    
    let wallet: Wallet
    
    override func bind() {
        
        _ = wk.view
//        view.connectingView.startAnimation()
        
//        view.addressLabel.text = ""
//        session.isConnected.asDriver().drive(onNext: { (flag) in
//
//            let node = "FX Cloud"
//            view.textLebal.text = flag ? node : TR("WalletConnect.Connecting")
//            view.stateLabel.text = flag ? TR("WalletConnect.Connected") : TR("WalletConnect.Connecting%@", node)
//            view.onlineDot.isHidden = !flag
//            view.onlineLabel.isHidden = !flag
//            view.connectedIV.isHidden = !flag
//            view.connectingView.isHidden = flag
//            view.connectNodeLabel.text = flag ? TR("WalletConnect.SelectAddress.Subtitle$", node) : ""
//            view.connectingView.snp.updateConstraints { (make) in
//                make.top.equalTo(FullNavBarHeight + 70 + (flag ? 60 : 0))
//            }
//        }).disposed(by: defaultBag)
        
        session.error.asDriver().drive(onNext: { [weak self](error) in
            guard error != nil, self?.navigationController?.topViewController == self else { return }

            self?.navigationController?.popViewController(animated: true)
            self?.navigationController?.topViewController?.hud?.text(m: error?.localizedDescription ?? "")
        }).disposed(by: defaultBag)
    }
    
    
    //MARK: Utils
    private var session: FxCloudWalletConnectSession { getSession() as! FxCloudWalletConnectSession }
    private var sessionId: String { "CloudWidget" }
    override func getSession() -> WalletConnectSession {
        
        if let session: FxCloudWalletConnectSession = WalletConnectSession.session(forId: sessionId) {
//            if session.url == self.url {
//                return session
//            } else {
                session.disconnect()
                session.release()
//            }
        }
        
        let session = FxCloudWalletConnectSession(id: sessionId, url: url, wallet: wallet)
        session.viewController = self
        session.retain()
        return session
    }
}
