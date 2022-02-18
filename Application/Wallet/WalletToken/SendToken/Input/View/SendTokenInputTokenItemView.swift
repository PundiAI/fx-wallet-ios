//
//  SendTokenInputTokenItemView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/6/29.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SendTokenInputViewController {
    class ItemView: UIView {
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 36, height: 36).auto())
        
        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = HDA(0xffffff)
            v.backgroundColor = .clear
            v.autoFont = true
            return v
        }()
        
        lazy var symbolLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = HDA(0xffffff)
            v.backgroundColor = .clear
            v.autoFont = true
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
            backgroundColor = .clear
        }
        
        private func layoutUI() {
            
            addSubviews([tokenIV, nameLabel, symbolLabel])
            
            tokenIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
                make.size.equalTo(CGSize(width: 36, height: 36).auto())
            }

            nameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenIV)
                make.left.equalTo(tokenIV.snp.right).offset(11.auto())
            }
         
            symbolLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(tokenIV)
                make.left.equalTo(tokenIV.snp.right).offset(11.auto())
            }
        }
    
    }
}
