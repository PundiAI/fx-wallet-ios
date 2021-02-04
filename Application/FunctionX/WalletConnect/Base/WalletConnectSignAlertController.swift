//
//  WalletConnectSignAlertController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/9/30.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension WalletConnectSignAlertController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let dapp = context["dapp"] as? Dapp,
            let message = context["message"],
            let account = context["account"] as? Keypair else { return nil }
        
        let vc = WalletConnectSignAlertController(dapp: dapp, message: message, account: account)
        vc.completionHandler = context["handler"] as? ( Bool) -> Void
        return vc
    }
}

class WalletConnectSignAlertController: FxRegularPopViewController {
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(dapp: Dapp, message: Any, account: Keypair) {
        self.dapp = dapp
        self.account = account
        self.message = message
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    let dapp: Dapp
    private var message: Any
    private var account: Keypair
    
    var completionHandler: ( (Bool) -> Void )?
    
    override func bindListView() {
        
        listBinder.push(ContentCell.self) {
            $0.addressLabel.text = self.account.address
            $0.messageTextView.text = self.messageText
            
            $0.dappUrlLabel.text = self.dapp.isPreInstalled ? self.dapp.detail : self.dapp.url
            $0.dappNameLabel.text = self.dapp.name
            $0.dappIV.setImage(urlString: self.dapp.url, placeHolderImage: self.dapp.isPreInstalled ? self.dapp.placeholderIcon : IMG("WC.DappPlaceholder"))
        }
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    private func bindAction(_ cell: ActionCell) {
        
        weak var welf = self
        cell.cancelButton.action { welf?.dismiss(userCanceled: true) }
        cell.confirmButton.action { welf?.dismiss(userCanceled: false) }
    }
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        let handler = completionHandler
        if userCanceled {
            handler?(false)
            Router.pop(self)
        }else {
            handler?(!userCanceled)
        }
    }
    
    private var messageText: String? { message as? String }
}

extension WalletConnectSignAlertController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case (_, "WalletConnectSignAlertController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        let animator = WKHeroAnimator({ (_) in
            welf?.setBackgoundOverlayViewImage()
            welf?.wk.view.popAnimation(enabled: true)
        }, onSuspend: { (_) in
            welf?.wk.view.popAnimation(enabled: false)
        })
        self.animators["0"] = animator
    }
}


 




//MARK: View
extension WalletConnectSignAlertController {
    class ContentCell: FxTableViewCell {
        
        lazy var dappIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        lazy var dappNameLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 24, weight: .medium), textColor: .white, alignment: .center)
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var dappUrlLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), alignment: .center)
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        private lazy var addressBackground = UIView(UIColor.white.withAlphaComponent(0.08), cornerRadius: 16.auto())
        private lazy var addressTitleLabel = UILabel(text: TR("Address"), font: XWallet.Font(ofSize: 16, weight: .medium))
        fileprivate lazy var addressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), lines: 2)
        
        private lazy var messageBackground = UIView(UIColor.white.withAlphaComponent(0.08), cornerRadius: 16.auto())
        private lazy var messageTitleLabel = UILabel(text: TR("Message"), font: XWallet.Font(ofSize: 16, weight: .medium))
        fileprivate lazy var messageTextView: UITextView = {
            let v = UITextView()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.isEditable = false
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat { 400.auto() }
        
        override func layoutUI() {
            contentView.addSubviews([dappIV, dappUrlLabel, dappNameLabel])
            contentView.addSubviews([addressTitleLabel, addressBackground, addressLabel])
            contentView.addSubviews([messageTitleLabel, messageBackground, messageTextView])
            
            dappIV.snp.makeConstraints { (make) in
                make.top.equalTo(10.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            dappNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(dappIV.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(20.auto())
                make.height.equalTo(30.auto())
            }
            
            dappUrlLabel.snp.makeConstraints { (make) in
                make.top.equalTo(dappNameLabel.snp.bottom).offset(4)
                make.left.right.equalToSuperview().inset(20.auto())
                make.height.equalTo(20.auto())
            }
            
            addressTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(dappUrlLabel.snp.bottom).offset(32.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(20.auto())
            }
            
            addressBackground.snp.makeConstraints { (make) in
                make.top.equalTo(addressTitleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(66.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.edges.equalTo(addressBackground).inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16).auto())
            }
            
            messageTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressBackground.snp.bottom).offset(32.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(20.auto())
            }
            
            messageBackground.snp.makeConstraints { (make) in
                make.top.equalTo(messageTitleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(66.auto())
            }
            
            messageTextView.snp.makeConstraints { (make) in
                make.edges.equalTo(messageBackground).inset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12).auto())
            }
        }
    }
}


extension WalletConnectSignAlertController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var cancelButton: UIButton { leftActionButton }
        var confirmButton: UIButton { rightActionButton }
        
        override func configuration() {
            super.configuration()
            
            cancelButton.title = TR("Deny")
            confirmButton.title = TR("Sign")
        }
    }
}

