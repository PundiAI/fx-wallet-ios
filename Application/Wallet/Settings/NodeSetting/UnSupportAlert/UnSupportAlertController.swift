//
//  RemoveTokenViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit
import RxSwift
import TrustWalletCore

extension UnSupportAlertController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin else { return nil }
        
        let vc = UnSupportAlertController(coin: coin)
        return vc
    }
}

class UnSupportAlertController: FxRegularPopViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init( coin: Coin) {
        self.coin = coin
        super.init(nibName: nil, bundle: nil)
    }
    
    let coin: Coin
    override var dismissWhenTouch: Bool { true }
    override var interactivePopIsEnabled: Bool { false }
    
    override func bindListView() {
        
        listBinder.push(ContentCell.self, vm: coin)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.submitButton.rx.tap.subscribe(onNext: { (_) in
            Router.pop(welf)
        }).disposed(by: cell.defaultBag)
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}

 
