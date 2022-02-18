//
//
//  XWallet
//
//  Created by May on 2021/1/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension FxValidatorListViewController {
    class View: UIView {
        lazy var aBackgroundView = UIView(UIColor.white)
        lazy var blurContainer = UIView(UIColor.white.withAlphaComponent(0.68))
        lazy var headerBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.standard()
            v.backButton.image = IMG("ic_back_black")
            return v
        }()
        var closeButton: UIButton { navBar.backButton }
        
        lazy var titleLabel = UILabel(text: TR("Delegate.Validators.Title"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: HDA(0x080A32))
        lazy var subtitleLabel = UILabel(text: TR("Delegate.Validators.SubTitle"), font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5))
        lazy var titleAnimator: ScrollScaleAnimator = {
            
            let v = ScrollScaleAnimator(offset: FullNavBarHeight)
            let s: CGFloat = 0.75
            v.add(PanScaleAnimator(view: titleLabel, endY: StatusBarHeight + (NavBarHeight - titleLabel.height * s) * 0.5 - 4, scale: s))
            v.add(PanScaleAnimator(view: subtitleLabel, endY: StatusBarHeight + (NavBarHeight - subtitleLabel.height * s) * 0.5 + 12, scale: s))
            return v
        }()
        
        lazy var switchView = UIView(HDA(0xE7E8EB), cornerRadius: 28)
        lazy var switchIndicator = UIView(.white, cornerRadius: 24)
        lazy var switchToMyAssets: UIButton = {
            let v = UIButton(.clear)
            v.titleColor = HDA(0x080A32)
            v.setAttributedTitle(NSAttributedString(string: TR("Delegate.All"), attributes: [.font: XWallet.Font(ofSize: 16), .foregroundColor: HDA(0x080A32)]), for: .normal)
            v.setAttributedTitle(NSAttributedString(string: TR("Delegate.All"), attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium), .foregroundColor: HDA(0x080A32)]), for: .selected)
            return v
        }()
        
        lazy var switchToAll: UIButton = {
            let v = UIButton(.clear)
            v.titleColor = HDA(0x080A32)
            v.setAttributedTitle(NSAttributedString(string: TR("Delegate.Active"), attributes: [.font: XWallet.Font(ofSize: 16), .foregroundColor: HDA(0x080A32)]), for: .normal)
            v.setAttributedTitle(NSAttributedString(string: TR("Delegate.Active"), attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium), .foregroundColor: HDA(0x080A32)]), for: .selected)
            return v
        }()
        
        lazy var contentView: UIScrollView = {
            
            let v = UIScrollView(.clear)
            v.contentSize = CGSize(width: ScreenWidth * 2, height: 0)
            v.isScrollEnabled = false
            return v
        }()
        
        lazy var leftListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .grouped)
            v.backgroundColor = .clear //HDA(0xF0F3F5)
            v.estimatedRowHeight = 0
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionHeaderHeight = 0
            return v
        }()
        
        
        lazy var rightListTitleView: UIView = {
            let v = UIView(HDA(0x080A32))
            v.addCorner([.topLeft, .topRight], size: CGSize(width: ScreenWidth - 24.auto() * 2, height: 40.auto()))
            return v
        }()
        
        lazy var rightListTitleLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium))
        
        lazy var searchView: ListHeaderView = {
            let v = ListHeaderView(size: CGSize(width: ScreenWidth, height: (40 + 44 + 24).auto() ))
            v.addCorner([.topLeft, .topRight], size: CGSize(width: ScreenWidth, height: (40 + 44 + 24).auto()))
            return v
        } ()
        
        
        lazy var searchView2: ListHeaderView = {
            let v = ListHeaderView(size: CGSize(width: ScreenWidth, height: (40 + 44 + 24).auto() ))
            v.addCorner([.topLeft, .topRight], size: CGSize(width: ScreenWidth, height: (40 + 44 + 24).auto()))
            return v
        } ()
        
        lazy var rightListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .grouped)
//            v.backgroundColor = HDA(0xF0F3F5)
            v.backgroundColor = .clear //HDA(0xF0F3F5)
            v.estimatedRowHeight = 0
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionHeaderHeight = 0
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
        }
        
        private func layoutUI() {
            addSubviews([aBackgroundView, contentView, blurContainer, navBar, titleLabel, subtitleLabel])
            
            switchView.addSubviews([switchIndicator, switchToMyAssets, switchToAll])
            blurContainer.addSubviews([headerBlur, switchView])
            self.wk.addLineShadow(below: blurContainer)
            
//            contentView.addSubviews([leftListView, rightListTitleView, rightListTitleLabel,rightListView])
            
            contentView.addSubviews([leftListView, rightListView])
            
            aBackgroundView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            //headerView...b
            let switchHeight: CGFloat = 56.auto()
            let reducedHeaderHeight = FullNavBarHeight + (switchHeight + 12.auto())
            let normalHeaderHeight = FullNavBarHeight + reducedHeaderHeight
            blurContainer.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: normalHeaderHeight)
            
            let titleContainerH: CGFloat = (32 + 22).auto()
            titleLabel.wk.adjust(frame: CGRect(x: 24.auto(), y: (normalHeaderHeight - titleContainerH) * 0.5, width: 0, height: 32.auto()))
            subtitleLabel.wk.adjust(frame: CGRect(x: 24.auto(), y: titleLabel.frame.maxY, width: 0, height: 22.auto()))
            
            headerBlur.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            switchView.snp.makeConstraints { (make) in
                make.bottom.equalTo(-12.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(switchHeight)
            }
            
            let switchWidth = (ScreenWidth - 24.auto() * 2) * 0.5
            switchToMyAssets.snp.makeConstraints { (make) in
                make.top.bottom.left.equalToSuperview()
                make.width.equalTo(switchWidth)
            }
            
            switchToAll.snp.makeConstraints { (make) in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(switchWidth)
            }
            
            switchIndicator.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(4)
                make.left.equalTo(4)
                make.width.equalTo(switchWidth - 4 * 2)
            }
            
            //headerView...e
            
            //contentView...b
            
            contentView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            leftListView.frame = CGRect(x: 24.auto(), y: 0, width: ScreenWidth - 24.auto() * 2, height: ScreenHeight)
            leftListView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: normalHeaderHeight), .clear)
            
            rightListView.frame = CGRect(x: ScreenWidth + 24.auto(), y: 0, width: ScreenWidth - 24.auto() * 2, height: ScreenHeight)
            rightListView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: normalHeaderHeight), .clear)
            rightListView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 20), .clear)
            //contentView...e
        }
    
    }
}
        

extension FxValidatorListViewController {
    
    class ListHeaderView: UIView {
        
        lazy var titleView: UIView = {
            let v = UIView(HDA(0x080A32))
            v.addCorner([.topLeft, .topRight], size: CGSize(width: ScreenWidth - 24.auto() * 2, height: 40.auto()))
            return v
        }()
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium))
        
        lazy var inputBackgroud: UIView = {
            let v = UIView(size: CGSize(width: ScreenWidth, height: 44.auto()))
            v.backgroundColor = .white
            v.autoCornerRadius = 22
            v.borderColor = .clear
            v.borderWidth = 2
            return v
        }()
        
        lazy var inputTF: UITextField = {
            
            let v = UITextField()
            v.font = XWallet.Font(ofSize:16, weight: .medium)
            v.textColor = HDA(0x080A32)
            v.tintColor = HDA(0x0552DC)
            v.attributedPlaceholder = NSAttributedString(string: TR("FXDelegator.SearchValidator"), attributes: [.font: XWallet.Font(ofSize:16), .foregroundColor: HDA(0x080A32).withAlphaComponent(0.5)])
            v.keyboardType = .asciiCapable
            v.backgroundColor = .clear
            return v
        }()
        
        
        lazy var indexLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var nameLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        func isEditing(_ v: Bool) {
            inputBackgroud.borderColor = v ? HDA(0x0552DC) : .clear
        }
        
        private func configuration() {
            backgroundColor = HDA(0xF0F3F5)
            indexLabel.text = "#"
            nameLabel.text = TR("Name")
            apyLabel.text = TR("APY")
        }
        
        func layoutUI() {
            
            
            addSubviews([titleView, titleLabel])
            
            titleView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(40.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(titleView).offset(16.auto())
                make.centerY.equalTo(titleView)
            }
            
            addSubviews([inputBackgroud, inputTF])
            inputBackgroud.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset( (16 + 40).auto())
                make.left.right.equalToSuperview().inset(16.auto())
                make.height.equalTo(44.auto())
            }
            
            inputTF.snp.makeConstraints { (make) in
                make.edges.equalTo(inputBackgroud).inset(UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 16).auto())
            }
            
//            addSubviews([indexLabel, nameLabel, apyLabel])
//
//            indexLabel.snp.makeConstraints { (make) in
//                make.left.equalToSuperview().offset(16.auto())
//                make.top.equalTo(inputBackgroud.snp.bottom).offset(16.auto())
//            }
//
//            nameLabel.snp.makeConstraints { (make) in
//
//                make.left.equalToSuperview().offset(44.auto())
//                make.top.equalTo(inputBackgroud.snp.bottom).offset(16.auto())
//            }
//
//            apyLabel.snp.makeConstraints { (make) in
//                make.right.equalToSuperview().offset(-20.auto())
//                make.top.equalTo(inputBackgroud.snp.bottom).offset(16.auto())
//            }
        }
    }

}
