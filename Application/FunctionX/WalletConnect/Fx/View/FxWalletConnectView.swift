//
//  FxWalletConnectView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxWalletConnectViewController {
    class ItemView: UIView {
        
        lazy var coinIV = UIImageView(.white, cornerRadius: 12)
        lazy var balanceLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
            v.adjustsFontSizeToFitWidth = true
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
            addSubviews([coinIV, balanceLabel])
            
            coinIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(48.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(coinIV.snp.right).offset(12.auto())
                make.right.equalTo(-12.auto())
            }
        }
    }
}
