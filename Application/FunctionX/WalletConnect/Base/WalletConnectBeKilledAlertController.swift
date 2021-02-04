//
//  WalletConnectBeKilledAlertController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/9/30.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

class WalletConnectBeKilledAlertController: FxRegularPopViewController {
    
    override func bindListView() {
        
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self).submitButton.action { [weak self] in
            Router.dismiss(self)
        }
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}







//MARK: View
extension WalletConnectBeKilledAlertController {
    class ContentCell: FxTableViewCell {
        
        private lazy var tipBackground = UIView(.white, cornerRadius: 28)
        private lazy var tipIV = UIImageView(image: IMG("WC.Warning"))
        private lazy var noticeLabel = UILabel(text: TR("WalletConnect.SessionBeKilled"), font: XWallet.Font(ofSize: 20, weight: .medium), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
        
            let width = ScreenWidth - 24.auto() * 4
            let noticeHeight = TR("WalletConnect.SessionBeKilled").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 20, weight: .medium)])
            return (32 + 56).auto() + (16.auto() + noticeHeight)
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel])
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(32.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            noticeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension WalletConnectBeKilledAlertController {
    
    class ActionCell: WKTableViewCell.ActionCell {
        
        override func configuration() {
            super.configuration()
            
            submitButton.title = TR("OK")
        }
    }
}

