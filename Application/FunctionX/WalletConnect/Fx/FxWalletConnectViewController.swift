//
//  FxWalletConnectViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/5/14.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import TrustWalletCore

extension WalletConnectNavController {
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let url = context["url"] as? String,
            let wallet = context["wallet"] as? WKWallet else {
            return nil
        }
        
        return WalletConnectNavController(url: url, wallet: wallet)
    }
}

class WalletConnectNavController: WKNavigationController {
    var animators: [String: WKHeroAnimator] = [:]
    init(url: String, wallet: WKWallet) {
        super.init(rootViewController: FxWalletConnectViewController(url: url, wallet: wallet))
        self.bindHero()
        self.modalPresentationStyle = .fullScreen
        self.hero.navigationAnimationType = .none
        self.hero.modalAnimationType = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WalletConnectNavController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        return animators["0"]
    }
    
    private func bindHero() {
        weak var welf = self
        animators["0"] = WKHeroAnimator({ (_) in
            welf?.view.hero.modifiers = [.useGlobalCoordinateSpace,.duration(5),
                                         .useOptimizedSnapshot,.translate(y: 1000)
            ]
        }, onSuspend: { (_) in
            welf?.hero.isEnabled = false
            welf?.view.hero.modifiers = nil
        })
    }
}

class FxWalletConnectViewController: WalletConnectViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(url: String, wallet: WKWallet) {
        self.wallet = wallet
        super.init(url: url)
        self.bindHero()
    }
    
    let wallet: WKWallet
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    lazy var balanceList: [CellViewModel] = []
    
    override func bind() {
        super.bind()
        
        weak var welf = self
        session.didApproveSession
            .filterNil()
            .take(1)
            .subscribe(onNext: { (approved) in
                if approved {
                    welf?.bindListView()
                } else {
                    welf?.disconnect()
                }
            }).disposed(by: defaultBag)
    }
    
    private func bindListView() {
        
        wk.view.didConnect(true)
        navigationBar.leftBarButton?.image = IMG("ic_arrow_down_black")
        listBinder.push(DappCell.self, vm: session.dapp)
        listBinder.push(WCInfoCell.self, vm: WCInfoCellViewModel(title: TR("WalletConnect.TSelectAddress"), subtitle: session.account.address))
        let balanceCell = listBinder.push(WCInfoCell.self, vm: WCInfoCellViewModel(title: TR("Balance"), subtitle: ""))
        addCoinType(balanceCell)
        
        guard let account = session.account else { return }
        let address = account.address
        for c in wallet.coins {
            if c.isEthereum || (c.id == session.coin.id) {
                
                let addressList = wallet.accounts(forCoin: c)
                if addressList.account(for: address) != nil {
                    if wallet.balanceManager.hasBalance(of: address, coin: c) {
                        balanceList.append(CellViewModel(coin: c, balance: wallet.balance(of: address, coin: c)).set(height: 40.auto()))
                    } else if c.isETH {
                        balanceList.insert(CellViewModel(coin: c, balance: Balance(coin: c, address: address)).set(height: 40.auto()), at: 0)
                    }
                }
            }
        }
        for balance in balanceList {
            listBinder.push(Cell.self, vm: balance)
        }
    }
    
    //MARK: Utils
    private var session: FxWalletConnectSession { getSession() as! FxWalletConnectSession }
    override func getSession() -> WalletConnectSession {
        
        if let session: FxWalletConnectSession = WalletConnectSession.global() {
            if session.url == self.url {
                session.viewController = self
                return session
            } else {
                session.disconnect()
                session.release()
            }
        }
        
        let session = FxWalletConnectSession(id: WalletConnectSession.globalSessionId, url: url, wallet: wallet)
        session.retain()
        session.viewController = self
        return session
    }
    
    private func addCoinType(_ titleCell: WCInfoCell) {
        guard !session.coin.isEmpty else { return }
        
        let coinIV = CoinTypeView()
        titleCell.contentView.addSubview(coinIV)
        
        titleCell.titleLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(24.auto())
            make.left.equalTo(48.auto())
            make.height.equalTo(20)
        }
        
        coinIV.snp.makeConstraints { (make) in
            make.bottom.equalTo(titleCell.titleLabel)
            make.left.equalTo(titleCell.titleLabel.snp.right).offset(12.auto())
            make.size.equalTo(CGSize(width: 0, height: 16.auto()))
        }
        coinIV.bind(session.coin)
    }
}


extension FxWalletConnectViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("FxWalletConnectViewController", "WalletConnectAuthorizeController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        animators["0"] = WKHeroAnimator({ (_) in
            welf?.view.hero.modifiers = [.whenDismissing(.useGlobalCoordinateSpace,.useOptimizedSnapshot)]
        }, onSuspend: { (_) in
            welf?.view.hero.modifiers = nil
        })
    }
}
