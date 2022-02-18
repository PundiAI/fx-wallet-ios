//
//  CryptoBankHomeDepositCell.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class DepositCell: FxTableViewCell {
        
        let view = DepositView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        var viewModel: DepositCellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? DepositCellViewModel else { return }
            self.viewModel = vm
            
            view.assetListView.viewModels = { _ in NSMutableArray.viewModels(from: vm.items, CryptoBankAssetCell.self) }
            view.assetListView.didSeletedBlock = { (_,indexPath) in
                let cellVM = vm.items[indexPath.row]
                Router.pushToCryptoBankAssetsOverview(wallet: vm.wallet, coin: cellVM.coin)
            }
             
            view.tipButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.showRevWebViewController(url: ThisAPP.WebURL.helpDepositURL) 
            }).disposed(by: reuseBag) 
            
            view.allAssertsButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.pushToCryptoBankAllAsserts(wallet: vm.wallet)
            }).disposed(by: reuseBag)
            
            view.myDepositsButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.pushToCryptoBankMyDeposits(wallet: vm.wallet)
            }).disposed(by: reuseBag)
        }
        
        func reloadIfNeed() {
            guard viewModel?.reloadIfNeed() == true else { return }
            
            view.assetListView.reloadData()
        }
        
        override class func height(model: Any?) -> CGFloat { return (model as? DepositCellViewModel)?.height ?? 44 }
    }
}


