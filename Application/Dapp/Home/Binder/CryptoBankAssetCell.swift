//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

class CryptoBankAssetCell: FxTableViewCell {
    
    private var viewModel: CryptoBankAssetCellViewModel?
    let view = CryptoBankAssetItemView(frame: ScreenBounds)
    override func getView() -> UIView { view }
    
    override func bind(_ viewModel: Any?) {
        guard let vm = viewModel as? CryptoBankAssetCellViewModel else { return }
        self.viewModel = vm
        
        view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
        view.tokenLabel.text = vm.coin.token
        vm.reserveData.value.subscribe(onNext: { [weak self]value in
            self?.view.apyLabel.text = vm.apy
        }).disposed(by: reuseBag)
    }
    
    override class func height(model: Any?) -> CGFloat { return (model as? CryptoBankAssetCellViewModel)?.height ?? 44 }
}







class CryptoBankPurchaseCell: FxTableViewCell {
    
    private var viewModel: CryptoBankPurchaseCellViewModel?
    let view = CryptoBankPurchaseItemView(frame: ScreenBounds)
    override func getView() -> UIView { view }
    
    override func bind(_ viewModel: Any?) {
        guard let vm = viewModel as? CryptoBankPurchaseCellViewModel else { return }
        self.viewModel = vm
        
        view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
        view.tokenLabel.text = vm.coin.token
        view.buyButton.rx.tap.subscribe(onNext: { [weak self] value in
            self?.router(event: "buy", context: ["coin": vm.coin])
        }).disposed(by: reuseBag)
    }
    
    override class func height(model: Any?) -> CGFloat { return (model as? CryptoBankPurchaseCellViewModel)?.height ?? 44 }
}
