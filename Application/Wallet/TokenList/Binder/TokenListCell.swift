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

extension TokenListViewController {
    class Cell: FxTableViewCell {
        
        private(set) var viewModel: CellViewModel?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            self.predisplay(vm)
            
            weak var welf = self
            let coin = vm.coin
            view.tokenLabel.text = vm.coin.token
            view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
            view.tokenIV.bind(coin)
            
//            vm.priceText.asDriver()
//                .drive(view.priceLabel.rx.text)
//                .disposed(by: reuseBag)
//
//            vm.rateText.asDriver()
//                .drive(view.rateLabel.rx.attributedText)
//                .disposed(by: reuseBag)
            
            vm.balance.value.asDriver()
                .drive(onNext: { 
                    welf?.view.relayout(byAmount: $0)
                    welf?.view.balanceLabel.wk.set(amount: $0, symbol: "", power: coin.decimal, thousandth: 8, mb: true)
                })
                .disposed(by: reuseBag)
            
            vm.legalBalance.value.asDriver()
                .drive(onNext: { welf?.view.legalBalanceLabel.wk.set(amount: $0, thousandth: ThisAPP.CurrencyDecimal, mb: true) })
                .disposed(by: reuseBag)
            
            if ServerENV.current == .dev {
                self.accessibilityIdentifier = "\(vm.coin.name)"
            }
        }
        
        private func predisplay(_ vm: CellViewModel) {
            view.balanceLabel.wk.set(amount: vm.balance.value.value, symbol: "", power: vm.coin.decimal, thousandth: 8, mb: true, animated: false)
            view.legalBalanceLabel.wk.set(amount: vm.legalBalance.value.value, thousandth: ThisAPP.CurrencyDecimal, mb: true, animated: false)
        }
        
        override class func height(model: Any?) -> CGFloat { return 80.auto() }
    }
}

