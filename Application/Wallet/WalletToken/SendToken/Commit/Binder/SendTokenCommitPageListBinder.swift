//
//  SendTokenCommitPageListBinder.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/4/13.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import XLPagerTabStrip

class SendTokenCommitPageListBinder: WKViewController {
    
    static var topEdge: CGFloat { 66 }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        self.coin = coin
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        
        self.logWhenDeinit()
        
        self.layoutUI()
        self.configuration()
        
        self.bind()
    }
    
    let coin: Coin
    let wallet: WKWallet
    
    let contentOffset = BehaviorRelay<CGPoint?>(value: nil)
    
    func refresh() {}
    func bind() { bindListResponder() }
    
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
    
    var listTop: CGFloat { SendTokenCommitPageListBinder.topEdge + 8 }
    var listView: WKTableView { fatalError("listView has not been implemented") }
}

