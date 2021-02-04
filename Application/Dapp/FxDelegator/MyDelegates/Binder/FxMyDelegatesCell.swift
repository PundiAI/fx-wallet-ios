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

extension FxMyDelegatesViewController {
    class Cell: FxTableViewCell {
        
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        private var viewModel: CellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            
            view.relayout(isLast: vm.isLast)
            view.validatorIV.setImage(urlString: vm.validator.imageURL, placeHolderImage: IMG("Dapp.Placeholder"))
            view.validatorNameLabel.text = vm.validator.validatorName
            view.delegateAmountLabel.text = vm.validator.delegateAmount.div10(vm.coin.decimal).thousandth(4)
            view.rewardsAmountLabel.text = "+ \(vm.validator.delegateReward.div10(vm.coin.decimal).thousandth(4))"
            view.apyLabel.text = "\(vm.validator.rewards)%"
        }
    }
}
                
