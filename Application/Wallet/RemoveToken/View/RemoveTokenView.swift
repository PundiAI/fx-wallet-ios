//
//  RemoveTokenView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension RemoveTokenViewController {
    class ContentCell: FxTableViewCell {
        
        private lazy var tipBackground = UIView(.white).then { $0.autoCornerRadius = 28 }
        private lazy var tipIV = UIImageView(image: IMG("ic_trash"))
        
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: TR("DeleteWallet.Notice1"), font: XWallet.Font(ofSize: 20, weight: .medium))
            v.textAlignment = .center
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()
        
        private lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: TR("DeleteWallet.Notice2"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.textAlignment = .center
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat {
            
            let width = ScreenWidth - 24 * 2 - 24 * 2
            
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 20, weight: .medium)
                $0.text = TR("DeleteWallet.Notice1")
                $0.autoFont = true }.font
            
            let font2:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = TR("DeleteWallet.Notice2")
                $0.autoFont = true }.font
            
            let noticeHeight1 = TR("DeleteWallet.Notice1").height(ofWidth: width, attributes: [.font: font1])
            let noticeHeight2 = TR("DeleteWallet.Notice2").height(ofWidth: width, attributes: [.font: font2])
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


extension RemoveTokenViewController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var cancelButton: UIButton { leftActionButton }
        var confirmButton: UIButton { rightActionButton }
        
        override func configuration() {
            super.configuration()
            
            cancelButton.title = TR("NotNow")
            confirmButton.title = TR("Remove")
            confirmButton.titleColor = .white
            confirmButton.backgroundColor = HDA(0xFA6237)
        }
    }
}

