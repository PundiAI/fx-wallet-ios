//
//  CryptoBankHomeNPXSSwapCell.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/1.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class NPXSSwapCell: FxTableViewCell {
        
        let view = NPXSSwapView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        private var viewModel: NPXSSwapCellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? NPXSSwapCellViewModel else { return }
            self.viewModel = vm
            
            view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
            view.rateLabel.text = "1 \(Coin.FxSwapSymbol) = 1000 NPXS"
             
            view.tipButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.showRevWebViewController(url: ThisAPP.WebURL.helpNPXSSwapURL)
            }).disposed(by: reuseBag) 
            
            view.viewButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    
                    if vm.coin.isEmpty {
                        Router.topViewController?.hud?.text(m: "NPXS not found")
                    } else {
                        Router.pushToNPXSSwap(wallet: vm.wallet, coin: vm.coin)
                    }
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat { return (model as? NPXSSwapCellViewModel)?.height ?? 44 }
    }
}
