//
//  WalletConnectDisconnectAlertController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/9/30.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension WalletConnectDisconnectAlertController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        
        let vc = WalletConnectDisconnectAlertController()
        vc.completionHandler = context["handler"] as? ( Bool) -> Void
        return vc
    }
}

class WalletConnectDisconnectAlertController: FxRegularPopViewController {
    
    var completionHandler: ( (Bool) -> Void )?
    
    override var dismissWhenTouch: Bool { true }
    
    override func bindListView() {
        
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    private func bindAction(_ cell: ActionCell) {
        
        weak var welf = self
        cell.cancelButton.action { welf?.dismiss(userCanceled: true) }
        cell.confirmButton.action { welf?.dismiss(userCanceled: false) }
    }
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        
        let handler = completionHandler
        Router.dismiss(self, animated: true) {
            handler?(!userCanceled)
        }
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}







//MARK: View
extension WalletConnectDisconnectAlertController {
    class ContentCell: FxTableViewCell {
        
        private lazy var tipBackground = UIView(.white, cornerRadius: 28)
        private lazy var tipIV = UIImageView(image: IMG("WC.Warning"))
        
        private lazy var noticeLabel1 = UILabel(text: TR("WalletConnect.Disconnect.Title"), font: XWallet.Font(ofSize: 20, weight: .medium), lines: 0, alignment: .center)
        private lazy var noticeLabel2 = UILabel(text: TR("WalletConnect.Disconnect.Subtitle"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
            
            let width = ScreenWidth - 24.auto() * 4
            let noticeHeight1 = TR("WalletConnect.Disconnect.Title").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 20, weight: .medium)])
            let noticeHeight2 = TR("WalletConnect.Disconnect.Subtitle").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
            return (32 + 56).auto() + (16.auto() + noticeHeight1) + (16.auto() + noticeHeight2)
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1, noticeLabel2])
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(32.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            noticeLabel1.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            noticeLabel2.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension WalletConnectDisconnectAlertController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var cancelButton: UIButton { leftActionButton }
        var confirmButton: UIButton { rightActionButton }
        
        override func configuration() {
            super.configuration()
            
            cancelButton.title = TR("NotNow")
            confirmButton.title = TR("Disconnect")
        }
    }
}
