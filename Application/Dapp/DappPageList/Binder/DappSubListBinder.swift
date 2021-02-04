//
//  DappSubListBinder.swift
//  XWallet
//
//  Created by May on 2020/8/7.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import XLPagerTabStrip

class DappSubListBinder: WKViewController {
    
    static var topEdge: CGFloat { 59.auto() + 19.auto() + StatusBarHeight }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        self.logWhenDeinit()
        
        self.layoutUI()
        self.configuration()
    }
    
    func refresh() {}

    func configuration() {
        self.view.backgroundColor = .clear
    }
    
    func layoutUI() {
        self.navigationBar.isHidden = true
    }
    
    var listTop: CGFloat { DappSubListBinder.topEdge + 24.auto()}
    var listBottom:CGFloat { TabBarHeight + 24.auto() }
    var listView: WKTableView { fatalError("listView has not been implemented") }
}
