

import WKKit

extension CryptoBankMyDepositsViewController {
    
    class ListHeader: UITableViewHeaderFooterView {
        
        private lazy var addressBGView = UIView(COLOR.title)
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
        lazy var addressLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: .white)
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            contentView.backgroundColor = .white
            
            addressBGView.addCorner([.topLeft, .topRight], radius: 20.auto(), size: CGSize(width: ScreenWidth - 24.auto() * 2, height: 62.auto()))
        }
        
        private func layoutUI() {
            contentView.addSubviews([addressBGView, titleLabel, addressLabel])
            
            let edge = 24.auto()
            addressBGView.snp.makeConstraints { (make) in
                make.top.equalTo(edge)
                make.left.right.equalToSuperview()
                make.height.equalTo(62.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressBGView).offset(12.auto())
                make.left.equalTo(addressBGView).offset(edge)
                make.height.equalTo(18.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(addressBGView).offset(-12.auto())
                make.left.right.equalTo(addressBGView).inset(edge)
                make.height.equalTo(18.auto())
            }
        }
        
    }
}


extension CryptoBankMyDepositsViewController {
    
    class ItemView: UIView {
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 40, height: 40).auto())
        
        lazy var balanceLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var legalBalanceLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        lazy var withdrawButton: UIButton = {
            let v = UIButton()
            let text = "    \(TR("CryptoBank.Withdraw"))    "
            v.setAttributedTitle(NSAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium), .foregroundColor: UIColor.white]), for: .normal)
            v.titleColor = .white
            v.backgroundColor = COLOR.title
            v.titleLabel?.adjustsFontSizeToFitWidth = true
            v.autoCornerRadius = 18
            return v
        }()
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: HDA(0x71A800))
        private lazy var apyTLabel = UILabel(text: TR("APY"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        
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
            
            addSubviews([tokenIV, balanceLabel, legalBalanceLabel, apyLabel, apyTLabel, withdrawButton, line])
            
            tokenIV.snp.makeConstraints { (make) in
                make.top.equalTo(26.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 40, height: 40).auto())
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenIV).offset(-1)
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.right.equalTo(-10.auto())
                make.height.equalTo(19.auto())
            }
            
            legalBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(balanceLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.right.equalTo(-10.auto())
                make.height.equalTo(17.auto())
            }
            
            withdrawButton.snp.makeConstraints { (make) in
                make.top.equalTo(84.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 105, height: 36).auto())
            }

            apyLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(withdrawButton)
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
            }
            
            apyTLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(withdrawButton)
                make.left.equalTo(apyLabel.snp.right).offset(8.auto())
            }
            
            line.snp.makeConstraints { (make) in
                make.bottom.right.equalToSuperview()
                make.left.equalTo(80.auto())
                make.height.equalTo(1)
            }
        }
        
        func relayout(isLast: Bool) {
            line.isHidden = isLast
            if isLast {
                self.addCorner([.bottomLeft, .bottomRight], radius: 20.auto(), size: CGSize(width: ScreenWidth - 24.auto() * 2, height: 135.auto()))
            } else {
                self.layer.mask = nil
            }
        }
    }
}
        
