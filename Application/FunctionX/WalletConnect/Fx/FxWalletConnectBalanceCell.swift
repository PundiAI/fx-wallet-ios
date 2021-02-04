//
//  FxWalletConnectBalanceCell.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension FxWalletConnectViewController {
    class Cell: FxTableViewCell {
        
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            
            view.coinIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
            vm.balance.value.subscribe(onNext: { [weak self]value in
                    
                let amount = value.div10(vm.coin.decimal).thousandth(mb: true)
                self?.view.balanceLabel.text = "\(amount) \(vm.coin.token)"
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat {
            (model as? CellViewModel)?.height ?? 36.auto()
        }
    }
}

