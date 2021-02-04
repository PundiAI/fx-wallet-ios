//
//
//  XWallet
//
//  Created by May on 2020/12/24.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension SendTokenCrossChainRecommitController {
    
    class ContentCell: FxTableViewCell {
        
        lazy var closeButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_close_white")
            v.backgroundColor = .clear
            return v
        }()
        
        private lazy var noticeLabel1 = UILabel(text: TR("CrossChain.F2E.RecommitTitle"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: .white, lines: 0)
        private lazy var noticeLabel2 = UILabel(text: TR("CrossChain.F2E.RecommitSubtitle"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), lines: 0)
        
        private lazy var tipBackground: UIView =  {
            let v = UIView(.white)
            v.autoCornerRadius = 24
            return v
        }()
        
        private lazy var tipIV = UIImageView(image: IMG("SendToken.CrossChain"))
        
        lazy var amountLabel: UILabel = {
            let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 18, weight: .medium), textColor: .white)
            v.autoFont = true
            v.textAlignment = .center
            return v
        }()
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("BroadcastTx.SendTo"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
            v.autoFont = true
            v.textAlignment = .center
            return v
        }()
        
        lazy var addressLabel: UILabel = {
            let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat {
            guard let address = model as? String else {  return 0 }
            
            let width = ScreenWidth - 24.auto() * 2 * 2
            let noticeHeight1 = TR("CrossChain.F2E.RecommitTitle").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 24, weight: .medium)])
            let noticeHeight2 = TR("CrossChain.F2E.RecommitSubtitle").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
            let addressHeight = address.height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
            
            let contentHeight = 72.auto() + noticeHeight1 + 8.auto() + noticeHeight2 + 40.auto() + ( 48 + 16 + 22 + 16 + 19 + 4).auto() + addressHeight + 16.auto()
            return contentHeight
        }
        
        override func configuration() {
            super.configuration()

        }
        
        override func layoutUI() {
            contentView.addSubviews([closeButton, noticeLabel1, noticeLabel2, tipBackground, tipIV, amountLabel, titleLabel, addressLabel])
            
            closeButton.snp.makeConstraints { (make) in
                make.top.left.equalTo(16.auto())
                make.size.equalTo(CGSize(width: 40, height: 40).auto())
            }
            
            noticeLabel1.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(72.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            noticeLabel2.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel2.snp.bottom).offset(40.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            amountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(22.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(amountLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(19.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}

extension SendTokenCrossChainRecommitController {
    
    class ActionCell: WKTableViewCell.ActionCell {
        
        var confirmButton: UIButton { submitButton }
        
        override func configuration() {
            super.configuration()
            confirmButton.title = TR("Send")
        }
    }
}
