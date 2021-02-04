//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

class CryptoBankAssetItemView: UIView {
    
    lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
    lazy var tokenLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
    lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 16), textColor: HDA(0x71A800))
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        logWhenDeinit()
        
        configuration()
        layoutUI()
    }
    
    private func configuration() {
        backgroundColor = HDA(0xF0F3F5)
    }
    
    private func layoutUI() {
        
        addSubviews([tokenIV, tokenLabel, apyLabel])
        
        tokenIV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(24.auto())
            make.size.equalTo(CGSize(width: 48, height: 48).auto())
        }

        tokenLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(tokenIV.snp.right).offset(16.auto())
        }
        
        apyLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-24.auto())
        }
    }
}
        






class CryptoBankPurchaseItemView: UIView {
    
    lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
    lazy var tokenLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
    lazy var buyButton: UIButton = {
        let v = UIButton()
        v.title = TR("CryptoBank.Cash.Buy")
        v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
        v.titleColor = COLOR.title
        v.backgroundColor = .white
        v.autoCornerRadius = 18
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
        backgroundColor = HDA(0xF0F3F5)
    }
    
    private func layoutUI() {
        
        addSubviews([tokenIV, tokenLabel, buyButton])
        
        tokenIV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-2.auto())
            make.left.equalTo(24.auto())
            make.size.equalTo(CGSize(width: 48, height: 48).auto())
        }

        tokenLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenIV)
            make.left.equalTo(tokenIV.snp.right).offset(16.auto())
        }
        
        buyButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenIV)
            make.right.equalTo(-24.auto())
            make.size.equalTo(CGSize(width: 93, height: 36).auto())
        }
    }
}
