//
//  ApprovePop.swift
//  fxWallet
//
//  Created by May on 2020/12/25.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension OxApprovingController {
    class ContentCell: FxTableViewCell {
        static var messageString0 = TR("BackAlert.AlertTitle")
        
        private lazy var tipBackground: UIView =  {
            let v = UIView(.white)
            v.autoCornerRadius = 28
            return v
        }()
        
        private lazy var tipIV = UIImageView(image: IMG("ic_not_notify"))
        
        lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: ContentCell.messageString0,
                            font: XWallet.Font(ofSize: 20, weight: .medium),
                            textColor: .white)
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
        
        lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: ContentCell.messageString0,
                            font: XWallet.Font(ofSize: 14),
                            textColor: UIColor.white.withAlphaComponent(0.5))
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
        
        
        
        override class func height(model: Any?) -> CGFloat {
            guard let token = model as? String else {
                print("-")
                return 0
            }
            
            
            let width = ScreenWidth - 24.auto() * 2 * 2
            
            let font:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 20, weight: .medium)
                $0.text = TR("Ox.Approve.Title", token)
                $0.autoFont = true }.font
             
            let noticeHeight1 = TR("Ox.Approve.Title", token).height(ofWidth: width, attributes: [.font:font])
            
            
            let font2:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = TR("Ox.Approve.SubTitle", token)
                $0.autoFont = true }.font
             
            let noticeHeight2 = TR("Ox.Approve.SubTitle", token).height(ofWidth: width, attributes: [.font:font2])
            
            return (32 + 56).auto() + (16.auto() + noticeHeight1) + (16.auto() + noticeHeight2)
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1])
            
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
        }
    }
}


extension OxApprovingController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var confirmButton: UIButton { rightActionButton }
            
        var cancelButton: UIButton { leftActionButton }
        
        override func configuration() {
            super.configuration()
            leftActionButton.title = TR("Ox.Button.Back")
            rightActionButton.title = TR("Ox.Button.View")
        }
    }
}
