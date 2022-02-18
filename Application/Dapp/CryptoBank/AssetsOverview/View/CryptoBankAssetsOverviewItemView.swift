

import WKKit

extension CryptoBankAssetsOverviewViewController {
    class ItemView: UIView {
        
        private lazy var contentView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        
        private lazy var addressBGView = UIView(COLOR.title)
        lazy var addressIndexLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
        lazy var addressLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: .white)
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        private lazy var depositTitleLabel = UILabel(text: TR("CryptoBank.MyDeposits"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var depositBalanceLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var depositLegalBalanceLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        lazy var withdrawButton: UIButton = {
            let v = UIButton()
            let text = "    \(TR("CryptoBank.Withdraw"))    "
            v.setAttributedTitle(NSAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium), .foregroundColor: UIColor.white]), for: .normal)
            v.titleColor = .white
            v.backgroundColor = COLOR.title
            v.autoCornerRadius = 18
            return v
        }()
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        private lazy var myBalanceTitleLabel = UILabel(text: TR("AssetsOverview.BalanceTitle"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var myBalanceLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var myLegalBalanceLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        
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
            
            addSubview(contentView)
            contentView.addSubviews([addressBGView, addressIndexLabel, addressLabel])
            contentView.addSubviews([depositTitleLabel, depositBalanceLabel, depositLegalBalanceLabel, withdrawButton, line])
            contentView.addSubviews([myBalanceTitleLabel, myBalanceLabel, myLegalBalanceLabel])
            
            let edge = 24.auto()
            contentView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(edge)
                make.bottom.equalTo(-edge)
            }
            
            addressBGView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(62.auto())
            }
            
            addressIndexLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressBGView).offset(12.auto())
                make.left.equalTo(addressBGView).offset(edge)
                make.height.equalTo(18.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(addressBGView).offset(-12.auto())
                make.left.right.equalTo(addressBGView).inset(edge)
                make.height.equalTo(18.auto())
            }
            
            depositTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressBGView.snp.bottom).offset(24.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            depositBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(depositTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            depositLegalBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(depositBalanceLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(edge)
                make.height.equalTo(17.auto())
            }
            
            withdrawButton.snp.makeConstraints { (make) in
                make.top.equalTo(depositLegalBalanceLabel.snp.bottom).offset(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(36.auto())
            }
            
            line.snp.makeConstraints { (make) in
                make.top.equalTo(withdrawButton.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            
            
            
            myBalanceTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line).offset(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            myBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(myBalanceTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            myLegalBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(myBalanceLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
        }
    
    }
}
        
