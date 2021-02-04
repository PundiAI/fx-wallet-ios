//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension AddTokenViewController {
    class View: UIView {
        lazy var aBackgroundView = UIView(UIColor.white)
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.white()
            v.backButton.image = IMG("Menu.Close")
            return v
        }()
        
        var closeButton: UIButton { navBar.backButton }
           
        lazy var titleLabel = UILabel(text: TR("TokenList.AddWallet"), font: XWallet.Font(ofSize: 24, weight: .bold), textColor: HDA(0x080A32))
        lazy var subtitleLabel = UILabel(text: TR("SelectAccount.Title"), font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5))
        
        lazy var titleAnimator: ScrollScaleAnimator = {
            
            let v = ScrollScaleAnimator(offset: FullNavBarHeight)
            let s: CGFloat = 0.7
            v.add(PanScaleAnimator(view: titleLabel, endY: StatusBarHeight + (NavBarHeight - titleLabel.height * s) * 0.5 - 8, scale: s))
            v.add(PanScaleAnimator(view: subtitleLabel, endY: StatusBarHeight + (NavBarHeight - subtitleLabel.height * s) * 0.5 + 8, scale: s))
            return v
        }()
        
        lazy var searchView = HeaderView(size: CGSize(width: ScreenWidth, height: FullNavBarHeight))
        
        lazy var availableSection = SectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - (24 * 2).auto(), height: 40.auto()), text: TR("SelectOrAddAccount.AllAvailable"))
        lazy var suggestedSection = SectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - (24 * 2).auto(), height: 40.auto()), text: TR("Suggested"))
        
        lazy var mainListView: WKTableView = {
            
            let v = WKTableView(frame: ScreenBounds, style: .grouped)
            v.estimatedRowHeight = 88.auto()
            v.estimatedSectionFooterHeight = 40.auto()
            v.estimatedSectionFooterHeight = 24.auto()
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
            backgroundColor = .clear
            searchListView.isHidden = true
        }
        
        private func layoutUI() {
            
            addSubviews([aBackgroundView, mainListView, searchListView, navBar, titleLabel, subtitleLabel])
            
            aBackgroundView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            let inputSpace = 16.auto() + searchView.inputSpace
            let reducedHeaderHeight = FullNavBarHeight + inputSpace
            let normalHeaderHeight = FullNavBarHeight + reducedHeaderHeight
            searchView.size = CGSize(width: ScreenWidth, height: normalHeaderHeight)
            
            let titleContainerH: CGFloat = (32 + 22).auto()
            titleLabel.wk.adjust(frame: CGRect(x: 24.auto(), y: (normalHeaderHeight - titleContainerH) * 0.5, width: 0, height: 32.auto()))
            subtitleLabel.wk.adjust(frame: CGRect(x: 24.auto(), y: titleLabel.frame.maxY, width: 0, height: 22.auto()))
            
            mainListView.tableHeaderView = searchView
            mainListView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            searchListView.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight + inputSpace)
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalToSuperview()
            }
        }
    
    }
}

extension AddTokenViewController {
    class HeaderView: AddCoinListHeaderView {
        
        fileprivate var inputSpace: CGFloat { (56 + 16).auto() }
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
        
extension AddTokenViewController {
    class SectionView: UIView {
        
        let titleLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .bold))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        init(frame: CGRect, text: String) {
            super.init(frame: frame)
            
            backgroundColor = COLOR.title
            addCorner([.topLeft, .topRight])
            
            addSubview(titleLabel)
            titleLabel.text = text
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(16.auto())
                make.centerY.equalToSuperview()
            }
        }
    }
}

extension AddTokenViewController {
    class NoDataCell: FxTableViewCell {
        
        private lazy var background: UIView = {
            let v = UIView(HDA(0xF0F3F5))
            v.addCorner([.bottomLeft, .bottomRight], size: CGSize(width: ScreenWidth - (24 * 2).auto(), height: NoDataCell.height(model: nil)))
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
