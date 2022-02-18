//
//  NotificationAlertView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension NotificationAlertController {
    class ContentCell: FxTableViewCell {
        private lazy var tipBackground = UIView(.white).then {
            $0.autoCornerRadius = 28
        }
        
        private lazy var tipIV = UIImageView(image: IMG("ic_not_notify"))
        
        private lazy var noticeLabel: UILabel = {
            let v = UILabel(text: TR("Notif.Alert.Notice"), font: XWallet.Font(ofSize: 20, weight: .medium), alignment: .center)
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat {
            let message = model as? String ?? TR("Notif.Alert.Notice")
            let width = ScreenWidth - 24.auto() * 2 * 2
            
            let font:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 20, weight: .medium)
                $0.text = message
                $0.autoFont = true }.font
            
            let noticeHeight1 = message.height(ofWidth: width, attributes: [.font:font])
            return (32 + 56).auto() + (16.auto() + noticeHeight1)
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
        
        override func update(model: Any?) {
            let message = model as? String ?? TR("Notif.Alert.Notice")
            noticeLabel.text = message
        }
    }
}


extension NotificationAlertController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var cancelButton: UIButton { leftActionButton }
        var confirmButton: UIButton { rightActionButton }
        
        override func configuration() {
            super.configuration()
            
            cancelButton.title = TR("NotNow")
            confirmButton.title = TR("TurnOn")
        }
    }
}

