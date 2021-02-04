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

extension CryptoBankAssetsOverviewViewController {
    class Cell: FxTableViewCell {
        
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        private var viewModel: CellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            
            weak var welf = self
            let coin = vm.coin
            view.addressIndexLabel.text = TR("AssetsOverview.DepositsAddress$", vm.index + 1)
            view.addressLabel.text = vm.account.address
            
            vm.balance.value.subscribe(onNext: { value in
                welf?.view.myBalanceLabel.text = "\(value.div10(coin.decimal).thousandth()) \(coin.token)"
            }).disposed(by: reuseBag)
            
            vm.legalBalance.value.subscribe(onNext: { value in
                welf?.view.myLegalBalanceLabel.text = "$\(value)"
            }).disposed(by: reuseBag)
            
            vm.aTokenBalance.value.subscribe(onNext: { value in
                welf?.view.depositBalanceLabel.text = "\(value.div10(coin.decimal).thousandth()) \(coin.aToken?.symbol ?? "")"
            }).disposed(by: reuseBag)
            
            vm.aTokenLegalBalance.value.subscribe(onNext: { value in
                welf?.view.depositLegalBalanceLabel.text = "$\(value)"
            }).disposed(by: reuseBag)
            
            view.withdrawButton.rx.tap.subscribe(onNext: { value in
                Router.pushToCryptoBankWithdraw(wallet: vm.wallet, coin: vm.coin, account: vm.account)
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat {
            return (model as? CellViewModel)?.height ?? 44
        }
    }
}
                
