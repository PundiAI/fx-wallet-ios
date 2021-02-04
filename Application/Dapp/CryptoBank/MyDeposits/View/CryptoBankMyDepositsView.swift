//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension CryptoBankMyDepositsViewController {
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
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .grouped)
        lazy var listHeader = HeaderView(size: CGSize(width: ScreenWidth, height: (8 + 160).auto()))
        
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
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: blurHeight + 24.auto()), .white)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 24.auto(), bottom: 0, right: 24.auto()))
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
extension CryptoBankMyDepositsViewController {
    class HeaderView: UIView {
        
        private lazy var bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 160.auto()), HDA(0xF0F3F5))
        
        private lazy var titleLabel = UILabel(text: TR("MyDeposits.Aggregatedbalance"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var legalBalanceLabel = UILabel(font: XWallet.Font(ofSize: 24, weight: .medium), textColor: COLOR.title)
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        lazy var txHistoryButton: UIButton = {
            let v = UIButton()
            v.title = TR("MyDeposits.TxHistory")
            v.titleFont = XWallet.Font(ofSize: 16)
            v.titleColor = COLOR.subtitle
            v.contentHorizontalAlignment = .left
            return v
        }()
        
        lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            bgView.cornerRadius = 20.auto()
        }
        
        private func layoutUI() {
            
            addSubview(bgView)
            bgView.addSubviews([titleLabel, legalBalanceLabel, txHistoryButton, arrowIV, line])
            
            bgView.snp.makeConstraints { (make) in
                make.top.equalTo(8.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(160.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.left.equalTo(24.auto())
                make.height.equalTo(18.auto())
            }
            
            legalBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(30.auto())
            }
            
            line.snp.makeConstraints { (make) in
                make.top.equalTo(94.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            txHistoryButton.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.right.bottom.equalToSuperview()
                make.height.equalTo(68.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalTo(txHistoryButton)
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
        }
    }
}
