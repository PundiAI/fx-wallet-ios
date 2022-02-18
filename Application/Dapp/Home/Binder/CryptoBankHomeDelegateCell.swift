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
            
            weak var welf = self
            view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
            view.tokenLabel.text = vm.coin.token
            view.ethButton.bind(CoinService.current.ethereum)
            view.functionXButton.bind(CoinService.current.fxCore)
            
            vm.apy.asDriver().drive(onNext: { v in
                welf?.view.apyLabel.text = v.isUnknownAmount ? "~%" : String(format: "%.2f%@", v.f, "%")
            }).disposed(by: reuseBag)
             
            view.tipButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.showRevWebViewController(url: ThisAPP.WebURL.helpDelegateURL)
            }).disposed(by: reuseBag) 
            
            view.delegateButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.pushToValidatorList(wallet: vm.wallet, coin: vm.coin)
            }).disposed(by: reuseBag)
            
            view.myDelegatesButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    Router.pushToFxMyDelegates(wallet: vm.wallet, coin: vm.coin)
            }).disposed(by: reuseBag)
            
            view.detailButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    vm.showDetail()
                    welf?.view.showDetail()
                    welf?.router(event: "DelegateDetail")
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat { return (model as? DelegateCellViewModel)?.height ?? 44 }
    }
}
