//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SetCurrencyViewController {
    class Cell: FxTableViewCell {
        
        private var viewModel: CellViewModel?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            view.titleLabel.text = vm.item.currency
            
            vm.selected.asDriver().distinctUntilChanged().drive(onNext: { [weak self] (state) in
                self?.view.selectIcon.isHidden = !state
                self?.view.titleLabel.textColor = state ? COLOR.title : COLOR.title.withAlphaComponent(0.6)
                self?.view.titleLabel.font = state ? XWallet.Font(ofSize: 18, weight: .bold) : XWallet.Font(ofSize: 18)
                
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 56.auto()
        }
    }
}
                
