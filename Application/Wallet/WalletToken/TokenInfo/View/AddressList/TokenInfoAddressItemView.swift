//
//  TokenInfoAddressItemView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/20.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension TokenInfoAddressListBinder {
    class ItemView: UIView {
        
        lazy var balanceLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18)
            v.textColor = HDA(0x080A32)
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        fileprivate lazy var remarkBackground: UIView = {
            let v = UIView(HDA(0x0552DC))
            v.autoCornerRadius = 11
            return v
        }()
        
        lazy var remarkLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var addressLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x080A32).withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
        }
        
        private func layoutUI() {
            addSubviews([balanceLabel, addressLabel, remarkBackground, remarkLabel])
            
            balanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(20.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(-24.auto())
                make.height.equalTo(22.auto())
            }
            
            remarkLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(balanceLabel)
                make.right.equalTo((-24 - 2).auto())
                make.height.equalTo(22.auto())
            }
            
            remarkBackground.snp.makeConstraints { (make) in
                make.edges.equalTo(remarkLabel).inset(UIEdgeInsets(top: 0, left: -8, bottom: 0, right: -8))
                make.width.greaterThanOrEqualTo(50)
                make.width.lessThanOrEqualTo(100)
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(balanceLabel.snp.bottom).offset(10.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(22.auto())
            }
        }
    
        func hideRemark(_ v: Bool) {
            remarkLabel.isHidden = v
            remarkBackground.isHidden = v
            
            let edge: CGFloat = (24 + (v ? 0 : 100)).auto()
            balanceLabel.snp.updateConstraints { (make) in
                make.right.equalTo(-edge)
            }
        }
    }
}
