//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension TokenListViewController {
    class ItemView: UIView {
        
        lazy var tokenIV: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFit
            v.cornerRadius = 18
            return v
        }()
        
        lazy var tokenLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16, weight: .medium)
            v.textColor = HDA(0x373737)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var priceLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = HDA(0x666666)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var rateIV: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFit
            return v
        }()
        
        lazy var rateLabel: UILabel = {
            let v = UILabel()
            v.text = TR("")
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = .red
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = HDA(0x666666)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var legalAmountLabel: UILabel = {
            let v = UILabel()
            v.text = TR("$-")
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = HDA(0x373737)
            v.backgroundColor = .clear
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
            
            addSubviews([tokenIV, tokenLabel, priceLabel, rateIV, rateLabel, amountLabel, legalAmountLabel])
            
            tokenIV.snp.makeConstraints { (make) in
               make.centerY.equalToSuperview()
               make.left.equalTo(25)
               make.size.equalTo(CGSize(width: 36, height: 36))
            }

            tokenLabel.snp.makeConstraints { (make) in
               make.top.equalTo(tokenIV)
               make.left.equalTo(tokenIV.snp.right).offset(6)
            }
         
            priceLabel.snp.makeConstraints { (make) in
               make.bottom.equalTo(tokenIV)
               make.left.equalTo(tokenIV.snp.right).offset(6)
            }

            rateIV.snp.makeConstraints { (make) in
               make.centerY.equalTo(priceLabel)
               make.left.equalTo(priceLabel.snp.right).offset(6)
                make.size.equalTo(CGSize(width: 5, height: 6))
            }
         
            rateLabel.snp.makeConstraints { (make) in
               make.centerY.equalTo(priceLabel)
               make.left.equalTo(rateIV.snp.right).offset(2)
            }
         
            legalAmountLabel.snp.makeConstraints { (make) in
               make.centerY.equalTo(tokenLabel)
               make.right.equalTo(-10)
            }
            
            amountLabel.snp.makeConstraints { (make) in
               make.centerY.equalTo(priceLabel)
               make.right.equalTo(-10)
            }
            
        }
    
    }
}
        
