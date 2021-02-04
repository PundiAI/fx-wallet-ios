//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension SelectAccountViewController {
    class View: UIView {
        
        lazy var backgroundBlur = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        lazy var contentView: UIView = {
            let v = UIView(.white)
            v.size = CGSize(width: ScreenWidth, height: ScreenHeight)
            v.addCorner([.topLeft, .topRight], radius: 36.auto())
            v.layer.masksToBounds = true
            return v
        }()
        
        lazy var navBarHeight: CGFloat = 72.auto()
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.white()
            v.backButton.image = IMG("Menu.Close")
            return v
        }()
        var closeButton: UIButton { navBar.backButton }
        
        lazy var titleLabel = UILabel(text: TR("SelectAccount.Title"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: HDA(0x080A32)).then {
            $0.autoFont = true
        }
        
        lazy var titleAnimator: ScrollScaleAnimator = {
            let scale: CGFloat = 0.65
            let v = ScrollScaleAnimator(view: titleLabel, endOrigin: CGPoint(x: 64.auto(), y: (72.auto() - scale * titleLabel.height) * 0.5), maxOffset: navBarHeight, scale: scale)
            return v
        }()
        
        lazy var listView: UITableView = {
            let v = UITableView(frame: ScreenBounds, style: .grouped)
            v.separatorStyle = .none
            v.backgroundColor = .clear
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            v.contentInsetAdjustmentBehavior = .never
            
            v.estimatedRowHeight = 4 + 90 + 4
            v.estimatedSectionFooterHeight = 12 + 40
            v.estimatedSectionHeaderHeight = 12
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        func configuration() {
            backgroundColor = HDA(0xF4F4F4).withAlphaComponent(0.88)
        }
        
        private func layoutUI() {
            addSubviews([backgroundBlur, contentView])
            contentView.addSubviews([listView, navBar, titleLabel])
            
            backgroundBlur.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            contentView.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(ScreenHeight - 100.auto())
            }
            
            navBar.relayout(statusHeight: 0)
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(navBarHeight)
            }
            
            titleLabel.wk.adjust(frame: CGRect(x: 24, y: 72, width: 0, height: 32).auto())
            
            listView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: navBarHeight + (29 + 8 + 20).auto()), .clear)
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 24.auto()), .clear)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
        }
    
    }
}
        
