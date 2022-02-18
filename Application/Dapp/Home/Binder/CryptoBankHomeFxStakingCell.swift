//
//  CryptoBankHomeFxStakeCell.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/8.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class FxStakingCell: FxTableViewCell {
        
        let view = FxStakingView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        private var viewModel: FxStakingCellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? FxStakingCellViewModel else { return }
            self.viewModel = vm
            
            view.fxIV.setImage(urlString: vm.fx.imgUrl, placeHolderImage: vm.fx.imgPlaceholder)
            view.npxsIV.setImage(urlString: vm.npxs.imgUrl, placeHolderImage: vm.npxs.imgPlaceholder)
            
            vm.fxAPYText.asDriver()
                .drive(view.fxAPYLabel.rx.attributedText)
                .disposed(by: reuseBag)
            
            vm.npxsAPYText.asDriver()
                .drive(view.npxsAPYLabel.rx.attributedText)
                .disposed(by: reuseBag)
            
            view.tipButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.showRevWebViewController(url: ThisAPP.WebURL.helpFxStakingURL)
            }).disposed(by: reuseBag) 
            
            view.viewButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    if vm.npxs.isEmpty || vm.fx.isEmpty { 
                        Router.topViewController?.hud?.text(m: "\(Coin.FxSwapSymbol.lowercased()) or FX not found")
                    } else {
                        Router.pushToFxStaking(wallet: vm.wallet, npxs: vm.npxs, fx: vm.fx)
                    }
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat { return (model as? FxStakingCellViewModel)?.height ?? 44 }
    }
}
