//
//  Python3
//  AllPurchaseViewController
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension AllPurchaseViewController {
    class TopCell: FxTableViewCell {
        private lazy var container = UIView(HDA(0xF0F3F5))
        
        private lazy var titleLabel = UILabel(text: TR("CryptoBank.Purchase"), font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        private lazy var descLabel = UILabel(text: TR("CryptoBank.PurchaseDesc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        lazy var tipButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Swap.Help")
            return v
        }()
        private lazy var line = UIView(HDA(0xEBEEF0))
        override func configuration() {
            backgroundColor = .white
            layer.masksToBounds = true
        }
        
        override func layoutUI() {
            contentView.backgroundColor = .clear
            addSubview(container)
            container.addSubviews([titleLabel, descLabel, tipButton, line])
            container.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(24.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo(-16.auto())
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            line.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(16.auto())
                make.height.equalTo(1)
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            let descHeight = TR("CryptoBank.PurchaseDesc").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            let titleHeight = 64.auto() + descHeight
            return titleHeight
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            container.addCorner(radius:20)
        }
    }
    
    class ItemContentCell: FxTableViewCell {
        let cView = CryptoBankPurchaseItemView(frame: ScreenBounds)
        
        private lazy var container = UIView(HDA(0xF0F3F5))
        override func configuration() {
            backgroundColor = .white
            layer.masksToBounds = true
        }
        
        override func layoutUI() {
            contentView.addSubview(container)
            container.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
            }
            container.addSubview(cView)
            cView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 80.auto()
        }
    }
    
    class BottomCell: FxTableViewCell {
        private lazy var container = UIView(HDA(0xF0F3F5))
        
        override func configuration() {
            backgroundColor = .white
            layer.masksToBounds = true
        }
        
        override func layoutUI() {
            addSubview(container)
            container.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(40)
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 20
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            container.addCorner([.bottomLeft, .bottomRight], radius:20)
        }
    }
}
