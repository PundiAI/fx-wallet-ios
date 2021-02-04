//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

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
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight + 16.auto(), left: 0, bottom: 0, right: 0))
            }
        }
    }
}

//MARK: DelegateCell
extension CryptoBankViewController {
    class DelegateView: UIView {
        
        private lazy var container = UIView(HDA(0xF0F3F5), cornerRadius: 20)
        
        private lazy var titleLabel = UILabel(text: TR("FXDelegator.Title"), font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        private lazy var descLabel = UILabel(text: TR("FXDelegator.Desc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        
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
            container.addSubviews([titleLabel, descLabel, tipButton, line, tokenIV, tokenLabel, apyLabel, delegateButton, line1, myDelegatesButton, arrowIV])
            
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
