//
//  CryptoBankHomeDelegateCell.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/25.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class DelegateCell: FxTableViewCell {
        
        let view = DelegateView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        private var viewModel: DelegateCellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? DelegateCellViewModel else { return }
            self.viewModel = vm
            
            view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
            view.apyLabel.text = "~%"
            view.tokenLabel.text = vm.coin.token
            
            view.tipButton.isEnabled = false
            view.tipButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.showWebViewController(url: ThisAPP.WebURL.helpDelegateURL)
            }).disposed(by: reuseBag)
            
            view.delegateButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.pushToValidatorList(wallet: vm.wallet, coin: vm.coin)
            }).disposed(by: reuseBag)
            
            view.myDelegatesButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.pushToFxMyDelegates(wallet: vm.wallet, coin: vm.coin)
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat { return (model as? DelegateCellViewModel)?.height ?? 44 }
    }
}
