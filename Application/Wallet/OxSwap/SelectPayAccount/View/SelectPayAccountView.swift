//
//
//  XWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension SelectPayAccountViewController {

    class View: UIView {
        
        lazy var contentView: UIView = {
            let v = UIView(.white)
            v.size = CGSize(width: ScreenWidth, height: ScreenHeight)
            return v
        }()
        
        lazy var navBarHeight: CGFloat = 72.auto()
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.white()
            v.backButton.image = IMG("Menu.Close")
            return v
        }()
        var closeButton: UIButton { navBar.backButton }
        
        lazy var searchView = OxHeaderView(size: CGSize(width: ScreenWidth, height: (56 + 16).auto()))
        
        lazy var listView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .grouped)
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
        
        lazy var noDataView = NoDataView(frame: ScreenBounds)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        func configuration() {
            backgroundColor = .white
            navBar.titleLabel.text = TR("Ox.Select.Token")
            noDataView.isHidden = true
            navBar.titleLabel.font = XWallet.Font(ofSize: 18, weight: .medium)
        }
        
        private func layoutUI() {
            addSubviews([contentView])
            contentView.addSubviews([listView, navBar, noDataView])
            
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
            
            noDataView.snp.makeConstraints { (make) in
                make.top.equalTo(reducedHeaderHeight)
                make.left.right.bottom.equalToSuperview()
            }
        }
    
    }
}
        
