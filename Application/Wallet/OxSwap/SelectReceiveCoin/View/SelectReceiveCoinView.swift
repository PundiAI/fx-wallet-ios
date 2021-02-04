//
//
//  XWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit


typealias OxHeaderView = SelectReceiveCoinViewController.HeaderView
extension SelectReceiveCoinViewController {
    class View: UIView {
        
        lazy var contentView: UIView = {
            let v = UIView(.white)
            v.size = CGSize(width: ScreenWidth, height: ScreenHeight)
            return v
        }()
        
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.white()
            v.backButton.image = IMG("Menu.Close")
            return v
        }()
        
        var closeButton: UIButton { navBar.backButton }
        lazy var searchView = HeaderView(size: CGSize(width: ScreenWidth, height: (56 + 16).auto()))
        
        lazy var listView: WKTableView = {
            
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = .white
            v.estimatedRowHeight = 88.auto()
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionFooterHeight = 0
            return v
        }()
        
        lazy var searchListView: WKTableView = {
            
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = .white
            v.estimatedRowHeight = 88.auto()
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionFooterHeight = 0
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
            backgroundColor = .white
            searchListView.isHidden = true
            navBar.titleLabel.font = XWallet.Font(ofSize: 18, weight: .medium)
        }
        
        private func layoutUI() {
            addSubviews([contentView])
            contentView.addSubviews([listView, navBar])
            
            contentView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            let inputSpace = 16.auto() + searchView.inputSpace
            let reducedHeaderHeight = FullNavBarHeight + inputSpace
            searchView.size = CGSize(width: ScreenWidth, height: reducedHeaderHeight)
            listView.tableHeaderView = searchView
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 24.auto()), .clear)
            
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
        }
    }
}
        



extension SelectReceiveCoinViewController {
   
    
    class AddCoinListItemView: UIView {
        
        lazy var pannel = UIView(HDA(0xF0F3F5))
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        
        lazy var tokenLabel = UILabel(font: XWallet.Font(ofSize: 18, weight: .medium), textColor: HDA(0x080A32))
        
        lazy var contractLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5))
            v.lineBreakMode = .byTruncatingMiddle
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
            backgroundColor = .white
            pannel.autoCornerRadius = 16
        }
        
        private func layoutUI() {
            addSubview(pannel)
            pannel.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalToSuperview().offset(-16.auto())
            }
            
            pannel.addSubviews([tokenIV, tokenLabel, contractLabel])
           
            tokenIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }

            tokenLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(tokenIV).offset(-10.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.right.equalToSuperview().offset(-24.auto())
                make.height.equalTo(20.auto())
            }

            contractLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(tokenIV).offset(14.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.right.equalToSuperview().offset(-24.auto())
                make.height.equalTo(20.auto())
            }
        }
    }
}

extension SelectReceiveCoinViewController {
    
    class HeaderView: AddCoinListHeaderView {
        
        var inputSpace: CGFloat { (56 + 16).auto() }
        var beginEdit = false
        
        override func layoutUI() {
            super.layoutUI()
            
            backgroundColor = .clear
            inputBackgroud.backgroundColor = HDA(0xF7F7FA)
            inputBackgroud.autoCornerRadius = 28
            
            inputBackgroud.snp.remakeConstraints { (make) in
                make.bottom.equalTo(-16.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(56.auto())
            }
        }
    }
}



extension SelectReceiveCoinViewController {
    class NoDataCell: FxTableViewCell {
        
        private lazy var background: UIView = {
            let v = UIView(HDA(0xF0F3F5))
            v.addCorner([.topLeft, .topRight, .bottomLeft, .bottomRight], size: CGSize(width: ScreenWidth - (24 * 2).auto(), height: NoDataCell.height(model: nil)))
            return v
        }()
        
        private lazy var titleLabel = UILabel(text: TR("NoData"), font: XWallet.Font(ofSize: 16, weight: .bold), textColor: HDA(0x080A32))
        private lazy var subtitleLabel = UILabel(text: TR("TokenList.NoResultNotice"), font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
            
            let subtitleHeight = TR("TokenList.NoResultNotice").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
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
        
