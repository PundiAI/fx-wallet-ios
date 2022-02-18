//
//  CryptoBankHomePurchaseCell.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class PurchaseCell: FxTableViewCell {
        
        lazy var view = PurchaseView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        private var viewModel: PurchaseCellViewModel?
        lazy var listBinder = WKStaticTableViewBinder(view: view.assetListView)
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? PurchaseCellViewModel else { return }
            self.viewModel = vm
            
            for cellVM in vm.items {
                listBinder.push(CryptoBankPurchaseCell.self, vm: cellVM)
            }
            view.allAssertsButton.rx.tap.subscribe(onNext: { [weak self] value in
                self?.router(event: "all", context: [:])
            }).disposed(by: reuseBag)
             
            view.tipButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.showRevWebViewController(url: ThisAPP.WebURL.helpPurchaseURL)
            }).disposed(by: reuseBag) 
        }
        
        override class func height(model: Any?) -> CGFloat { return (model as? PurchaseCellViewModel)?.height ?? 44 }
    }
}
