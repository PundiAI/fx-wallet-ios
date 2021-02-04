//
//  WalletConnectExistAlertController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/16.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

class WalletConnectExistAlertController: FxRegularPopViewController {
    
    override var navBarHeight: CGFloat { 72.auto() }
    override func bindListView() {
        
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self).submitButton.action { [weak self] in
            Router.dismiss(self)
        }
    }
}







//MARK: View
extension WalletConnectExistAlertController {
    class ContentCell: FxTableViewCell {
        
        private lazy var tipBackground = UIView(.white, cornerRadius: 28)
        private lazy var tipIV = UIImageView(image: IMG("WC.Warning"))
        private lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("WalletConnect.SessionExistTitle"), font: XWallet.Font(ofSize: 24, weight: .medium), alignment: .center)
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        private lazy var noticeLabel = UILabel(text: TR("WalletConnect.SessionExistNotice"), font: XWallet.Font(ofSize: 14), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
        
            let width = ScreenWidth - 24.auto() * 4
            let noticeHeight = TR("WalletConnect.SessionExistNotice").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
            return (0 + 56).auto() + (16 + 29).auto() + (16.auto() + noticeHeight) + 16.auto()
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, titleLabel, noticeLabel])
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(0.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(20.auto())
                make.height.equalTo(29.auto())
            }
            
            noticeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension WalletConnectExistAlertController {
    
    class ActionCell: WKTableViewCell.ActionCell {
        
        override func configuration() {
            super.configuration()
            
            submitButton.title = TR("Confirm").uppercased()
        }
    }
}
