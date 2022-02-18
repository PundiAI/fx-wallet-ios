//
//  SendTokenFeeView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/8/11.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SendTokenFeeViewController {
    
    class View: ActionView {
        
        lazy var totalLabel = UILabel(font: XWallet.Font(ofSize: 12), textColor: UIColor.white.withAlphaComponent(0.5), alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var balanceLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
    
        func hideNotice(_ v: Bool) {
            
            totalLabel.isHidden = v
            balanceLabel.isHidden = v
            
            actionsHeight = 50.auto() + actionEdge * 2
            if !v { actionsHeight += (actionEdge + 36.auto()) }
            if actionView.height != actionsHeight {
                actionView.snp.updateConstraints { (make) in
                    make.height.equalTo(actionsHeight)
                }
            }
        }
        
        override func configuration() {
            super.configuration()
            
            submitButton.disabledTitle = TR("SendToken.InsufficientBalance")
            submitButton.disabledBGImage = UIImage.createImageWithColor(color: HDA(0x31324A).withAlphaComponent(0.5))
            submitButton.disabledTitleColor = HDA(0xFA6237)
        }
        
        override func layoutUI() {
            super.layoutUI()
            
            actionView.addSubviews([totalLabel, balanceLabel])
            
            totalLabel.snp.makeConstraints { (make) in
                make.top.equalTo(submitButton.snp.bottom).offset(actionEdge)
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(totalLabel.snp.bottom)
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            hideNotice(true)
        }
        
    }
}

extension SendTokenFeeViewController {
    
    class AmountCell: FxTableViewCell {
        
        lazy var legalAmountLabel = UILabel(font: XWallet.Font(ofSize: 24, weight: .bold))
        lazy var amountLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
        
        override class func height(model: Any?) -> CGFloat { (70 + 24).auto() }
        
        override func layoutUI() {
            contentView.addSubviews([amountLabel, legalAmountLabel])
            
            legalAmountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(30.auto())
            }
            
            amountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(legalAmountLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}



extension SendTokenFeeViewController {

    class OptionsCell: FxTableViewCell {
        
        lazy var actionButton: UIButton = {
            let v = UIButton(.clear)
            v.title = TR("SendToken.Fee.Options")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = .white
            return v
        }()
        
        override func layoutUI() {
            
            contentView.addSubview(actionButton)
            actionButton.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.height.equalTo(50.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
        
        override public class func height(model:Any? = nil) -> CGFloat { return (16 + 50).auto() }
    }
}

