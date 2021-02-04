//
//  RemoveTokenView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension UnSupportAlertController {
    class ContentCell: FxTableViewCell {
        private lazy var tipBackground = UIView(.white).then { $0.autoCornerRadius = 28 }
        private lazy var tipIV = UIImageView(image: IMG("Swap.Warning"))
        
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: TR("ChangeNode.UnSupport.Notice1$", ""), font: XWallet.Font(ofSize: 20, weight: .medium))
            v.textAlignment = .center
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()
 
        override class func height(model: Any?) -> CGFloat {
            let name = (model as? Coin)?.displayChainName ?? ""
            let width = ScreenWidth - 24 * 2 - 24 * 2
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 20, weight: .medium)
                $0.text = TR("ChangeNode.UnSupport.Notice1$", name)
                $0.autoFont = true }.font
            
            let noticeHeight1 = TR("ChangeNode.UnSupport.Notice1", name).height(ofWidth: width, attributes: [.font: font1])
            return (32 + 56).auto() + (16.auto() + noticeHeight1)
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1])
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(32.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.edges.equalTo(tipBackground)
            }
            
            noticeLabel1.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
        
        override func update(model: Any?) {
            super.update(model: model)
            let name = (model as? Coin)?.displayChainName ?? ""
            self.noticeLabel1.text = TR("ChangeNode.UnSupport.Notice1$", name)
        }
    }
}


extension UnSupportAlertController {
    
    class ActionCell: WKTableViewCell.ActionCell {
        override func configuration() {
            super.configuration()
            submitButton.title = TR("ChangeNode.UnSupport.Done")
        }
    }
}

