//
//  VisitSocialAlertView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension VisitSocialAlertController {
    class ContentCell: FxTableViewCell {
        
        lazy var titleLabel = UILabel(text: TR("VisitSocial.Title"), font: XWallet.Font(ofSize: 24, weight: .medium), alignment: .center)
        lazy var tipLabel = UILabel(text: TR("VisitSocial.Notice"), font: XWallet.Font(ofSize: 14), textColor: .white, lines: 0, alignment: .center)
        lazy var iconIV = UIImageView(HDA(0x1A1D42), cornerRadius: 24.auto())
        
        lazy var nameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
        lazy var linkLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), alignment: .center)
         
        override class func height(model: Any?) -> CGFloat {
            
            let titleHeight: CGFloat = 30
            let tipHeight = TR("VisitSocial.Notice").height(ofWidth: ScreenWidth - 24.auto() * 2 * 2, attributes: [.font: XWallet.Font(ofSize: 14)])
            return (40.auto() + titleHeight) + (16.auto() + tipHeight) + 152.auto()
        }
        
        override func layoutUI() {
            contentView.addSubviews([titleLabel, tipLabel, iconIV, nameLabel, linkLabel])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(40.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            tipLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            iconIV.snp.makeConstraints { (make) in
                make.top.equalTo(tipLabel.snp.bottom).offset(40.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            nameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(iconIV.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(20.auto())
            }
            
            linkLabel.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel.snp.bottom).offset(4)
                make.centerX.equalToSuperview()
                make.height.equalTo(16)
            }
        }
    }
}


extension VisitSocialAlertController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var cancelButton: UIButton { leftActionButton }
        var confirmButton: UIButton { rightActionButton }
        
        override func configuration() {
            super.configuration()
            
            confirmButton.title = TR("Continue")
        }
    }
}

