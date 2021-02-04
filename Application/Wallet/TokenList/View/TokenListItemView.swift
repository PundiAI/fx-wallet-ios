//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension TokenListViewController {
    class SectionView: UITableViewHeaderFooterView {
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        lazy var mContentView = UIView()
        lazy var tokenButton = CoinTypeView()
        var topMargin:CGFloat = 0
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            logWhenDeinit()
            layoutUI()
            configuration()
        }
        
        private func configuration() {
            tintColor = .clear
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            blurView.alpha = 0
        }
        
        private func layoutUI() {
            addSubview(mContentView)
            mContentView.addSubviews([blurView, tokenButton]) 
            mContentView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            blurView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            tokenButton.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 100, height: 16).auto() )
            }
        } 
    }
}

extension TokenListViewController {
    class ItemView: UIView {
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        
        lazy var tokenLabel = UILabel(font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        lazy var balanceLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title.withAlphaComponent(0.5))
        lazy var legalBalanceLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
            v.setContentCompressionResistancePriority(.required, for: .horizontal)
            return v
        }()
        lazy var zeroBalanceLabel = UILabel(font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title, alignment: .right)
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
            zeroBalanceLabel.isHidden = true
        }
        
        private func layoutUI() {
            
            addSubviews([tokenIV, tokenLabel, balanceLabel, legalBalanceLabel, zeroBalanceLabel])
            
            tokenIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }

            tokenLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.right.lessThanOrEqualTo(legalBalanceLabel.snp.left)
                    .offset(-12.auto())
            }
            
            legalBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenIV)
                make.right.equalTo(-24.auto())
                make.left.greaterThanOrEqualTo(tokenLabel.snp.right)
                    .offset(12.auto())
                    .priority(.high)
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(tokenIV)
                make.right.equalTo(-24.auto())
            }
            
            zeroBalanceLabel.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.right.equalTo(-24.auto())
                make.width.equalTo(200)
            }
        }
        
        func relayout(byAmount text: String) {
            
            var hideZero = true
            if text.isUnknownAmount {
                hideZero = false
                zeroBalanceLabel.text = "~"
            } else if text.isZero {
                hideZero = false
                zeroBalanceLabel.text = "$0"
            }
            zeroBalanceLabel.isHidden = hideZero
            balanceLabel.isHidden = !hideZero
            legalBalanceLabel.isHidden = !hideZero
        }
    }
}
