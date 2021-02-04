//
//  SendTokenCrossChainView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/12.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SendTokenCrossChainCommitController {
    
    class View: BaseView {
        
        lazy var navTitleLabel = UILabel(text: TR("CrossChain.TxTitle"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
        lazy var navSubtitleLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
        
        lazy var cancelButton: UIButton = {
            let v = UIButton()
            v.title = TR("Cancel")
            v.titleFont = XWallet.Font(ofSize: 16)
            v.titleColor = .white
            v.autoCornerRadius = 25
            v.backgroundColor = HDA(0x31324A)
            return v
        }()

        lazy var confirmButton: UIButton = {
            let v = UIButton()
            v.title = TR("Confirm")
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = HDA(0x080A32)
            v.autoCornerRadius = 25
            v.backgroundColor = .white
            return v
        }()

        override func configuration() {
            super.configuration()
            
            contentView.autoCornerRadius = 36
            
            closeButton.autoCornerRadius = 16
            closeButton.image = IMG("SendToken.CrossChain")
            closeButton.backgroundColor = .white
            closeButton.contentVerticalAlignment = .center
            closeButton.contentHorizontalAlignment = .center
            closeButton.isUserInteractionEnabled = false
            closeButton.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9).auto()
            
            navBar.alpha = 0
            navBar.blur.isHidden = false
            navBar.blurColor.alpha = 0.54
            navBar.blurColor.backgroundColor = HDA(0x000237)
        }
        
        override func layoutUI() {
            super.layoutUI()
            
            contentView.addView(cancelButton, confirmButton)
            
            navBar.navigationArea.addSubviews([navTitleLabel, navSubtitleLabel])
            closeButton.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            navTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(14.auto())
                make.left.equalTo(closeButton.snp.right).offset(16.auto())
                make.height.equalTo(20.auto())
            }
            
            navSubtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(navTitleLabel.snp.bottom).offset(2)
                make.left.equalTo(closeButton.snp.right).offset(16.auto())
                make.height.equalTo(18.auto())
            }
            
            let edge = 24.auto()
            listView.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(cancelButton.snp.top).offset(-edge)
            }
            
            cancelButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(-edge)
                make.left.equalTo(24.auto())
                make.right.equalTo(confirmButton.snp.left).offset(-19.auto())
                make.height.equalTo(50.auto())
            }

            confirmButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(-edge)
                make.left.equalTo(cancelButton.snp.right).offset(19.auto())
                make.right.equalTo(-24.auto())
                make.width.equalTo(cancelButton)
                make.height.equalTo(50.auto())
            }
        }
    }
}

extension SendTokenCrossChainCommitController {
    
    class TitleCell: FxTableViewCell {
        
        lazy var resultIV = UIImageView(image: IMG("SendToken.CrossChain"))
        lazy var resultIVBackground = UIView(.white, cornerRadius: 28)
        
        lazy var titleLabel = UILabel(text: TR("CrossChain.TxTitle"), font: XWallet.Font(ofSize: 24, weight: .bold), alignment: .center)
        lazy var descLabel = UILabel(text: TR("CrossChain.F2E.TransferTip"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
            let descHeight = TR("CrossChain.F2E.TransferTip").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            return 175.auto() + descHeight
        }
        
        override func layoutUI() {
            
            contentView.addSubviews([resultIVBackground, resultIV, titleLabel, descLabel])
            
            resultIVBackground.snp.makeConstraints { (make) in
                make.top.equalTo(40.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            resultIV.snp.makeConstraints { (make) in
                make.center.equalTo(resultIVBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(resultIVBackground.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(30.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension SendTokenCrossChainCommitController {
    
    class SectionTitleCell: FxTableViewCell {
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: .white)
        lazy var chainTypeButton = ChainTypeButton().then{ $0.style = .lightContent }
        
        override class func height(model: Any?) -> CGFloat { (18 + 8).auto() }
        
        override func layoutUI() {
            
            addSubviews([titleLabel, chainTypeButton])
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(24.auto())
                make.height.equalTo(18.auto())
            }
            
            chainTypeButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(titleLabel)
                make.left.equalTo(titleLabel.snp.right).offset(12.auto())
                make.height.equalTo(16.auto())
            }
        }
    }
}

