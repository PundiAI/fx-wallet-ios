

import WKKit

extension CryptoBankViewController {
    class View: UIView {
        var backgoundView = UIView().then {
            $0.backgroundColor = UIColor.white
        }
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
            listView.backgroundColor = .clear
        }
        
        private func layoutUI() {
            insertSubview(backgoundView, at: 0)
            backgoundView.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalToSuperview().offset(1000)
            }
            
            addSubview(listView)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
            listView.contentInset = UIEdgeInsets(top: 16.auto(), left: 0, bottom: 16.auto(), right: 0)
        }
    }
}

//MARK: FxStakingCell
extension CryptoBankViewController {
    class FxStakingView: UIView {
        
        private lazy var container = UIView(HDA(0xF0F3F5), cornerRadius: 20)
        
        private lazy var titleLabel = UILabel(text: TR("FxStaking.Title"), font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        private lazy var descLabel = UILabel(text: TR("FxStaking.Desc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        
        lazy var tipButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Swap.Help")
            return v
        }()
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        private lazy var npxsContainer = UIView(UIColor.white.withAlphaComponent(0.5), cornerRadius: 16)
        lazy var npxsIV = CoinImageView(size: CGSize(width: 32, height: 32).auto())
        private lazy var npxsLabel = UILabel(text: Coin.FxSwapSymbol, font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
        lazy var npxsAPYLabel = UILabel(font: XWallet.Font(ofSize: 16), alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        private lazy var fxContainer = UIView(UIColor.white.withAlphaComponent(0.5), cornerRadius: 16)
        lazy var fxIV = CoinImageView(size: CGSize(width: 32, height: 32).auto())
        private lazy var fxLabel = UILabel(text: "FX", font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
        lazy var fxAPYLabel = UILabel(font: XWallet.Font(ofSize: 16), alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        private lazy var line1 = UIView(HDA(0xEBEEF0))
        
        lazy var viewButton: UIButton = {
            let v = UIButton()
            v.title = TR("FxStaking.GoToStake")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = COLOR.title
            v.titleEdgeInsets = UIEdgeInsets(top: -4, left: 0, bottom: 4, right: 0)
            v.contentHorizontalAlignment = .left
            return v
        }()
        
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        
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
            
            addSubview(container)
            container.addSubviews([titleLabel, descLabel, tipButton, line, npxsContainer, fxContainer, line1, viewButton, arrowIV])
            npxsContainer.addSubviews([npxsIV, npxsLabel, npxsAPYLabel])
            fxContainer.addSubviews([fxIV, fxLabel, fxAPYLabel])
            
            container.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(-24.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(22.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo(-16.auto())
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            line.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(16.auto())
                make.height.equalTo(1)
            }
            
            npxsContainer.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(24.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 136, height: 104).auto())
            }
            
            npxsIV.snp.makeConstraints { (make) in
                make.top.equalTo(12.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            npxsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(npxsIV.snp.bottom).offset(8.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            npxsAPYLabel.snp.makeConstraints { (make) in
                make.top.equalTo(npxsLabel.snp.bottom).offset(4.auto())
                make.left.right.equalToSuperview().inset(12.auto())
                make.height.equalTo(19.auto())
            }
            
            fxContainer.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(24.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 136, height: 104).auto())
            }
            
            fxIV.snp.makeConstraints { (make) in
                make.top.equalTo(12.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            fxLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxIV.snp.bottom).offset(8.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            fxAPYLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxLabel.snp.bottom).offset(4.auto())
                make.left.right.equalToSuperview().inset(12.auto())
                make.height.equalTo(19.auto())
            }

            line1.snp.makeConstraints { (make) in
                make.top.equalTo(line).offset(152.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            viewButton.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.right.bottom.equalToSuperview()
                make.height.equalTo(68.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalTo(viewButton).offset(-3.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
        }
    }
}

//MARK: NPXSSwapCell
extension CryptoBankViewController {
    class NPXSSwapView: UIView {
        
        private lazy var container = UIView(HDA(0xF0F3F5), cornerRadius: 20)
        
        private lazy var titleLabel = UILabel(text: TR("NPXSSwap.Title"), font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        private lazy var descLabel = UILabel(text: TR("NPXSSwap.Desc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        
        lazy var tipButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Swap.Help")
            return v
        }()
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        lazy var tokenLabel = UILabel(text: "\(Coin.FxSwapSymbol)/NPXS", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var rateLabel = UILabel(font: XWallet.Font(ofSize: 16), textColor: HDA(0x71A800))
        
        private lazy var line1 = UIView(HDA(0xEBEEF0))
        
        lazy var viewButton: UIButton = {
            let v = UIButton()
            v.title = TR("NPXSSwap.View")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = COLOR.title
            v.titleEdgeInsets = UIEdgeInsets(top: -4, left: 0, bottom: 4, right: 0)
            v.contentHorizontalAlignment = .left
            return v
        }()
        
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        
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
            
            addSubview(container)
            container.addSubviews([titleLabel, descLabel, tipButton, line, tokenIV, tokenLabel, rateLabel, line1, viewButton, arrowIV])
            
            container.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(-24.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(22.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo(-16.auto())
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            line.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(16.auto())
                make.height.equalTo(1)
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(16.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            tokenLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(19.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.height.equalTo(19.auto())
            }
            
            rateLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.height.equalTo(19.auto())
            }

            line1.snp.makeConstraints { (make) in
                make.top.equalTo(line).offset(80.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            viewButton.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.right.bottom.equalToSuperview()
                make.height.equalTo(68.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalTo(viewButton).offset(-3.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
        }
    }
}

//MARK: DelegateCell
extension CryptoBankViewController {
    class DelegateView: UIView {
        
        private lazy var container = UIView(HDA(0xF0F3F5), cornerRadius: 20)
        
        private lazy var titleLabel = UILabel(text: TR("FXDelegator.Title"), font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        private lazy var descLabel = UILabel(text: TR("FXDelegator.Desc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var detailButton: UIButton = {
            let v = UIButton()
            let title = NSAttributedString(string: TR("Details"), attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium), .foregroundColor: COLOR.title, .underlineColor: COLOR.title, .underlineStyle: NSUnderlineStyle.single.rawValue])
            v.setAttributedTitle(title, for: .normal)
            return v
        }()
        
        lazy var ethButton = ChainNameButton()
        lazy var functionXButton = ChainNameButton()
        
        lazy var tipButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Swap.Help")
            return v
        }()
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        lazy var tokenLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 16), textColor: HDA(0x71A800))
        
        lazy var delegateButton: UIButton = {
            let v = UIButton()
            let text = "    \(TR("BroadcastTx.Delegate"))    "
            v.setAttributedTitle(NSAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium), .foregroundColor: COLOR.title]), for: .normal)
            v.backgroundColor = .white
            v.autoCornerRadius = 18
            return v
        }()
        
        private lazy var line1 = UIView(HDA(0xEBEEF0))
        
        lazy var myDelegatesButton: UIButton = {
            let v = UIButton()
            v.title = TR("FXDelegator.ViewAll")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = COLOR.title
            v.titleEdgeInsets = UIEdgeInsets(top: -4, left: 0, bottom: 4, right: 0)
            v.contentHorizontalAlignment = .left
            return v
        }()
        
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        
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
            
            addSubview(container)
            container.addSubviews([ethButton, functionXButton])
            container.addSubviews([titleLabel, descLabel, detailButton, tipButton, line, tokenIV, tokenLabel, apyLabel, delegateButton, line1, myDelegatesButton, arrowIV])
            
            container.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(-24.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(24.auto())
            }
            
            ethButton.cornerRadius = 8.auto()
            ethButton.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(20.auto())
                make.height.equalTo(16.auto())
            }
            
            functionXButton.cornerRadius = 8.auto()
            functionXButton.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(ethButton.snp.right).offset(8.auto())
                make.height.equalTo(16.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(28.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(-76.auto())
            }
            
            detailButton.backgroundColor = container.backgroundColor
            detailButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(descLabel)
                make.right.equalTo(-24.auto())
                make.height.equalTo(17.auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo(-16.auto())
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            line.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(16.auto())
                make.height.equalTo(1)
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(16.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            tokenLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(19.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.height.equalTo(19.auto())
            }
            
            apyLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.height.equalTo(19.auto())
            }

            delegateButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(tokenIV)
                make.right.equalTo(-24.auto())
                make.height.equalTo(36.auto())
            }
            
            line1.snp.makeConstraints { (make) in
                make.top.equalTo(line).offset(80.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            myDelegatesButton.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.right.bottom.equalToSuperview()
                make.height.equalTo(68.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalTo(myDelegatesButton).offset(-3.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
        }
        
        func showDetail() {
            
            detailButton.isHidden = true
            
            descLabel.numberOfLines = 0
            descLabel.snp.updateConstraints { (make) in
                make.right.equalTo(-24.auto())
            }
        }
    }
}


//MARK: DepositCell
extension CryptoBankViewController {
    class DepositView: UIView {
        
        private lazy var container = UIView(HDA(0xF0F3F5), cornerRadius: 20)
        
        private lazy var titleLabel = UILabel(text: TR("CryptoBank.Deposit"), font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        private lazy var descLabel = UILabel(text: TR("CryptoBank.DepositDesc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        
        lazy var tipButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Swap.Help")
            return v
        }()
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        private lazy var assertsLabel = UILabel(text: TR("CryptoBank.Assets"), font: XWallet.Font(ofSize: 16), textColor: COLOR.subtitle)
        private lazy var apyLabel = UILabel(text: TR("APY"), font: XWallet.Font(ofSize: 16), textColor: COLOR.subtitle)
        
        lazy var assetListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.isScrollEnabled = false
            return v
        }()
        
        lazy var allAssertsButton: UIButton = {
            let v = UIButton()
            v.title = TR("CryptoBank.AllAssets")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = COLOR.title
            return v
        }()
        
        lazy var myDepositsButton: UIButton = {
            let v = UIButton()
            v.title = TR("CryptoBank.MyDeposits")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = COLOR.title
            return v
        }()
        
        private lazy var line1 = UIView(HDA(0xEBEEF0))
        private lazy var line2 = UIView(HDA(0xEBEEF0))
        
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
            
            addSubview(container)
            container.addSubviews([titleLabel, descLabel, tipButton, line, assertsLabel, apyLabel])
            container.addSubview(assetListView)
            container.addSubviews([allAssertsButton, myDepositsButton, line1, line2])
            
            container.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(-24.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(24.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo(-16.auto())
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            line.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(16.auto())
                make.height.equalTo(1)
            }
            
            assertsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(23.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(20.auto())
            }
            
            apyLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(assertsLabel)
                make.right.equalTo(-24.auto())
                make.height.equalTo(20.auto())
            }
            
            assetListView.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(58.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(3 * 80.auto())
            }
            
            allAssertsButton.snp.makeConstraints { (make) in
                make.left.bottom.equalToSuperview()
                make.height.equalTo(68.auto())
                make.width.equalToSuperview().multipliedBy(0.5)
            }
            
            myDepositsButton.snp.makeConstraints { (make) in
                make.right.bottom.equalToSuperview()
                make.height.equalTo(68.auto())
                make.width.equalToSuperview().multipliedBy(0.5)
            }
            
            line1.snp.makeConstraints { (make) in
                make.top.equalTo(allAssertsButton)
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            line2.snp.makeConstraints { (make) in
                make.centerY.equalTo(allAssertsButton)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 1, height: 48.auto()))
            }
        }
    }
}


//MARK: PurchaseCell
extension CryptoBankViewController {
    class PurchaseView: UIView {
        
        private lazy var container = UIView(HDA(0xF0F3F5), cornerRadius: 20)
        
        private lazy var titleLabel = UILabel(text: TR("CryptoBank.Purchase"), font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        private lazy var descLabel = UILabel(text: TR("CryptoBank.PurchaseDesc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        
        lazy var tipButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Swap.Help")
            return v
        }()
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        lazy var assetListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain) 
            v.isScrollEnabled = false
            return v
        }()
        
        lazy var allAssertsButton: UIButton = {
            let v = UIButton()
            v.title = TR("CryptoBank.Purchase.AllAssets")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = COLOR.title
            v.titleEdgeInsets = UIEdgeInsets(top: -4, left: 0, bottom: 4, right: 0)
            v.contentHorizontalAlignment = .left
            return v
        }()
        
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        private lazy var line1 = UIView(HDA(0xEBEEF0))
        
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
            
            addSubview(container)
            container.addSubviews([titleLabel, descLabel, tipButton, line])
            container.addSubview(assetListView)
            container.addSubviews([allAssertsButton, arrowIV, line1])
            
            container.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(-24.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(24.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo(-16.auto())
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            line.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(16.auto())
                make.height.equalTo(1)
            }
            
            assetListView.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(3 * 80.auto())
            }
            
            allAssertsButton.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.right.bottom.equalToSuperview()
                make.height.equalTo(68.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalTo(allAssertsButton).offset(-3.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            line1.snp.makeConstraints { (make) in
                make.top.equalTo(allAssertsButton)
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
        }
    }
}
