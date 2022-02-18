//
//  TokenInfoSubListBinder.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/17.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import XLPagerTabStrip

class TokenInfoSubListBinder: WKViewController {
    
    static var topEdge: CGFloat { 70 }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        self.logWhenDeinit()
        
        self.layoutUI()
        self.configuration()
        
        self.bindListResponder()
    }
    
    let contentOffset = BehaviorRelay<CGPoint?>(value: nil)
    
    func refresh() {}
    func bindListResponder() {

        self.listView.isFirstScrollResponder = false
        self.listView.scrollViewDidScroll = { [weak self] _ in
            guard let this = self else { return }
            
            if this.contentOffset.value != this.listView.contentOffset {
                this.contentOffset.accept(this.listView.contentOffset)
            }
            
            if (!this.listView.isFirstScrollResponder || this.listView.contentOffset.y <= 0) {
                this.listView.contentOffset = .zero
            }
        }
    }

    func configuration() {
        self.view.backgroundColor = HDA(0x080A32)
    }
    
    func layoutUI() {
        self.navigationBar.isHidden = true
    }
    
    var listTop: CGFloat { TokenInfoSubListBinder.topEdge }
    var listView: WKTableView { fatalError("listView has not been implemented") }
}
