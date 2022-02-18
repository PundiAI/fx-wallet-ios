//
//  TokenActionSheet.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/29.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit

import Web3
import XChains
extension TokenActionSheet {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
            let coin = context["coin"] as? Coin,
            let account = context["account"] as? Keypair else { return nil }
        
        return TokenActionSheet(wallet: wallet, coin: coin, account: account)
    }
}

class TokenActionSheet: FxRegularPopViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, account: Keypair) {
        self.coin = coin
        self.wallet = wallet
        self.account = account
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
        logWhenDeinit()
    }
    
    let coin: Coin
    let wallet: WKWallet
    let account: Keypair
    override var interactivePopIsEnabled: Bool { false }
    override var dismissWhenTouch: Bool { true }

    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        Router.pop(self, animated: animated, completion: completion)
    }

    override func bindListView() {
        let coin = self.coin
        let canRemove = wallet.accounts(forCoin: coin).accounts.count > 1
        listBinder.push(AddressCell.self).addressLabel.text = account.address
        listBinder.push(MenuCell.self, vm: MenuCell.Types.explorer)
        listBinder.push(MenuCell.self, vm: MenuCell.Types.send)
        listBinder.push(MenuCell.self, vm: MenuCell.Types.receive)
        if coin.isEthereum { listBinder.push(MenuCell.self, vm: MenuCell.Types.swap) }
        listBinder.push(MenuCell.self, vm: MenuCell.Types.copy)
        if canRemove { listBinder.push(MenuCell.self, vm: MenuCell.Types.remove) }
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(24.auto(), 0, UIColor.clear))

        listBinder.didSeletedBlock = { [weak self] (_, _, cell) in
            guard let this = self, let cell = cell as? MenuCell else { return }

            let showComplateBlock:((UIViewController)->Void) = { _ in
                if  Router.isExistInNavigator("TokenInfoViewController") {
                    Router.popAllButTop{ $0?.heroIdentity == "TokenInfoViewController" }
                }
            }
            if cell.type == .remove {
                Router.showRemoveAddress(completionHandler: { (error) in
                    if error == nil {
                        self?.wallet.accounts(forCoin: coin).remove(this.account)
                    }
                }, presenCompletion: showComplateBlock)
            } else {
                switch cell.type {
                case .explorer:
                    Router.showExplorer(this.coin, path: .address(this.account.address), push: true, completion: showComplateBlock)
                case .receive:
                    Router.pushToReceiveToken(coin: coin, account: this.account, completion: showComplateBlock)
                case .send:
                    Router.pushToSendTokenInput(wallet: this.wallet, coin: this.coin, account: this.account, completion: showComplateBlock)
                case .swap:
                    Router.pushToSwap(wallet: this.wallet, current: (this.coin, this.account), completion: showComplateBlock)
                case .copy:
                    UIPasteboard.general.string = this.account.address
                    Router.currentNavigator?.hud?.text(m: TR("Copied"))
                    Router.pop(self)

                    #if DEBUG
                    print("xxxcoinContract:", this.coin.contract, this.coin.symbol)
                    print("xxxSelectAddress:", this.account.address)
                    print("xxxSelectPrivateKey:", this.account.privateKey.data.hex)
                    #endif
                default: break
                }
            }
        }
    }
}

/// hero
extension TokenActionSheet {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("TokenInfoViewController", "TokenActionSheet"): return animators["0"]
        case ("TokenActionSheet", "RemoveAddressViewController"): return animators["1"]
        default: return nil
        }
    }
    
    private func bindHero() { 
        animators["0"] = self.heroAnimatorBackgound()
        animators["1"] = self.heroAnimatorBackgoundFrom()
    }
}





























//MARK: View
extension TokenActionSheet {

    class AddressCell: FxTableViewCell {

        private lazy var titleLabel = UILabel(text: TR("SelectAccount.Actions.Title"), font: XWallet.Font(ofSize: 24, weight: .medium))
        lazy var addressLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat { return (30 + 20 + 24).auto() }
        
        override func layoutUI() {
            contentView.addSubviews([titleLabel, addressLabel])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(24.auto())
                make.height.equalTo(30.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}
