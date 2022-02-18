

import WKKit

extension CryptoBankAssetsOverviewViewController {
    class View: UIView {
        
        lazy var despositBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        lazy var despositButton: UIButton = {
            let v = UIButton()
            v.title = TR("CryptoBank.Deposit")
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.autoCornerRadius = 28
            v.backgroundColor = COLOR.title
            return v
        }()
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        lazy var listHeader = HeaderView(size: CGSize(width: ScreenWidth, height: 707))
        
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
            
            addSubviews([listView, despositBlur, despositButton])
            
            let blurHeight: CGFloat = 16.auto() + 56.auto() + CGFloat(16.auto().ifull(50.auto()))
            listView.tableHeaderView = self.listHeader
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: blurHeight), .white)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
            
            despositBlur.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(blurHeight)
            }
            
            despositButton.snp.makeConstraints { (make) in
                make.top.equalTo(despositBlur).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    
    }
}
        

//MARK: HeaderView
extension CryptoBankAssetsOverviewViewController {
    class HeaderView: UIView {
        
        lazy var infoContentView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        lazy var tokenNameLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var tokenSymbolLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        
        lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: HDA(0x71A800))
        private lazy var apyDescLabel = UILabel(text: TR("AssetsOverview.APYDesc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        private lazy var line1 = UIView(HDA(0xEBEEF0))
        
        private lazy var poolLabel = UILabel(text: TR("AssetsOverview.Pool"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var exchangeNameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var exchangeDescLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        lazy var exchangeLinkButton: UIButton = {
            let v = UIButton()
            v.titleColor = HDA(0x0552DC)
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleLabel?.adjustsFontSizeToFitWidth = true
            return v
        }()
        private lazy var line2 = UIView(HDA(0xEBEEF0))
        
        private lazy var liquidityTitleLabel = UILabel(text: TR("AssetsOverview.Liquidity"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var liquidityLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var legalLiquidityLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        private lazy var line3 = UIView(HDA(0xEBEEF0))
        
        private lazy var priceTitleLabel = UILabel(text: TR("AssetsOverview.AssetPrice"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var priceLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        
        lazy var loadingContentView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        lazy var loadingIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        lazy var loadingLabel = UILabel(text: TR("AssetsOverview.Loading"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var loadingDescLabel = UILabel(text: TR("AssetsOverview.NoAsset$Notice", "---"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0, alignment: .center)
        
        var infoContentHeight: CGFloat = 0
        var loadingContentHeight: CGFloat = 0
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            
            exchangeNameLabel.text = "Aave Market"
            exchangeDescLabel.text = TR("Aave.Liquidity.Protocol")
            exchangeLinkButton.title = "http://aave.com"
            
            let descHeight = TR("AssetsOverview.Pool").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            infoContentHeight = descHeight + 420.auto()
            
            let noticeHeight = TR("AssetsOverview.NoAsset$$Notice", "----", "----").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            loadingContentHeight = noticeHeight + 140.auto()
        }
        
        private func layoutUI() {
            
            addSubviews([infoContentView, loadingContentView])
            infoContentView.addSubviews([tokenIV, tokenSymbolLabel, tokenNameLabel, apyLabel, apyDescLabel, line1])
            infoContentView.addSubviews([poolLabel, exchangeNameLabel, exchangeDescLabel, exchangeLinkButton, line2])
            infoContentView.addSubviews([liquidityTitleLabel, liquidityLabel, legalLiquidityLabel, line3])
            infoContentView.addSubviews([priceTitleLabel, priceLabel])
            
            loadingContentView.addSubviews([loadingIV, loadingLabel, loadingDescLabel])
            
            
            infoContentView.snp.makeConstraints { (make) in
                make.top.equalTo(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(infoContentHeight)
            }
            
            
            loadingContentView.snp.makeConstraints { (make) in
                make.top.equalTo(infoContentView.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(loadingContentHeight)
            }
            
            //info...b
            
            let edge: CGFloat = 16.auto()
            tokenIV.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.left.equalTo(edge)
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            tokenSymbolLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenIV).offset(2.auto())
                make.left.equalTo(tokenIV.snp.right).offset(edge)
                make.height.equalTo(20.auto())
            }
            
            tokenNameLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(tokenIV).offset(-2.auto())
                make.left.equalTo(tokenIV.snp.right).offset(edge)
                make.height.equalTo(20.auto())
            }

            apyLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(tokenSymbolLabel)
                make.right.equalTo(-edge)
            }
            
            apyDescLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(tokenNameLabel)
                make.right.equalTo(-edge)
            }
            
            line1.snp.makeConstraints { (make) in
                make.top.equalTo(91.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            
            
            poolLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line1.snp.bottom).offset(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(18.auto())
            }
            
            exchangeNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(poolLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(20.auto())
            }
            
            exchangeDescLabel.snp.makeConstraints { (make) in
                make.top.equalTo(exchangeNameLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(edge)
            }
            
            exchangeLinkButton.snp.makeConstraints { (make) in
                make.top.equalTo(exchangeDescLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(20.auto())
            }
            
            line2.snp.makeConstraints { (make) in
                make.top.equalTo(exchangeLinkButton.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            
            
            
            liquidityTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line2).offset(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            liquidityLabel.snp.makeConstraints { (make) in
                make.top.equalTo(liquidityTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            legalLiquidityLabel.snp.makeConstraints { (make) in
                make.top.equalTo(liquidityLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            line3.snp.makeConstraints { (make) in
                make.top.equalTo(legalLiquidityLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            
            
            priceTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line3).offset(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            priceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(priceTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            //info...e
            
            
            
            //loading...b
            
            loadingIV.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            loadingLabel.snp.makeConstraints { (make) in
                make.top.equalTo(loadingIV.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(20.auto())
            }
            
            loadingDescLabel.snp.makeConstraints { (make) in
                make.top.equalTo(loadingLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            //loading...e
        }
    
    }
}
