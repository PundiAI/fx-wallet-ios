

import WKKit

extension CryptoBankTxHistoryViewController {
    class ItemView: UIView {
        
        private lazy var bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 336.auto()), HDA(0xF0F3F5))
        
        lazy var txTypeLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
        private lazy var txTypeBGView = UIView(HDA(0x0552DC))
        
        private lazy var amountTitleLabel = UILabel(text: TR("Amount"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var amountLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var legalAmountLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        
        private lazy var addressTitleLabel = UILabel(text: TR("Address"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var addressLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        private lazy var dateTitleLabel = UILabel(text: TR("Date"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var dateLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
        
        lazy var explorerButton: UIButton = {
            let v = UIButton()
            v.title = TR("CryptoBank.History.ViewOnEtherscan")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = HDA(0x0552DC)
            v.contentHorizontalAlignment = .left
            return v
        }()
        
        lazy var arrowIV = UIImageView(image: IMG("ic_arrow_web"))
        
        private lazy var line = UIView(HDA(0xEBEEF0))
        private lazy var line2 = UIView(HDA(0xEBEEF0))
        private lazy var line3 = UIView(HDA(0xEBEEF0))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            bgView.cornerRadius = 24.auto()
        }
        
        private func layoutUI() {
            
            addSubview(bgView)
            bgView.addSubviews([txTypeBGView, txTypeLabel])
            bgView.addSubviews([amountTitleLabel, amountLabel, legalAmountLabel, line])
            bgView.addSubviews([addressTitleLabel, addressLabel, line2])
            bgView.addSubviews([dateTitleLabel, dateLabel, line3])
            bgView.addSubviews([explorerButton, arrowIV])
            
            let edge: CGFloat = 24.auto()
            bgView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: edge, right: 0))
            }
            
            txTypeBGView.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.width.equalTo(0)
                make.height.equalTo(36.auto())
            }
            
            txTypeLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(txTypeBGView)
                make.right.equalTo(-24.auto())
                make.height.equalTo(20.auto())
            }
            
            amountTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            amountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(amountTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            legalAmountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(amountLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(edge)
            }
            
            line.snp.makeConstraints { (make) in
                make.top.equalTo(109.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            addressTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line).offset(16.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(17.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressTitleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(29.auto())
            }
            
            line2.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(76.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            dateTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line2.snp.bottom).offset(16.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(18.auto())
            }
            
            dateLabel.snp.makeConstraints { (make) in
                make.top.equalTo(dateTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(19.auto())
            }
            
            line3.snp.makeConstraints { (make) in
                make.top.equalTo(line2.snp.bottom).offset(76.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            explorerButton.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.right.bottom.equalToSuperview()
                make.height.equalTo(64.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalTo(explorerButton)
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
        }
    
        func relayout(isDeposit: Bool) {
            txTypeLabel.text = TR(isDeposit ? "CryptoBank.Deposit" : "CryptoBank.Withdraw")
            let bgWidth = txTypeLabel.sizeThatFits(.zero).width + 24.auto() * 2
            
            txTypeBGView.addCorner([.bottomLeft], radius: 24.auto(), size: CGSize(width: bgWidth, height: 36.auto()))
            txTypeBGView.snp.updateConstraints { (make) in
                make.width.equalTo(bgWidth)
            }
        }
    }
}
        

extension CryptoBankTxHistoryViewController {
    class NoDataCell: FxTableViewCell {
        
        private lazy var background = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        
        private lazy var titleLabel = UILabel(text: TR("NoData"), font: XWallet.Font(ofSize: 16, weight: .bold), textColor: HDA(0x080A32))
        private lazy var subtitleLabel = UILabel(text: TR("CryptoBank.History.NoDataNotice"), font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
            
            let subtitleHeight = TR("CryptoBank.History.NoDataNotice").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            return 48.auto() + subtitleHeight + 20.auto()
        }
        
        override func layoutUI() {
            
            contentView.addSubviews([background, titleLabel, subtitleLabel])
            background.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(20.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(20.auto())
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}
