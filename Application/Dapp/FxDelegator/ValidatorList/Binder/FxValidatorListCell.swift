//
//
//  XWallet
//
//  Created by May on 2021/1/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension FxValidatorListViewController {

    class ValidatorsCell: FxTableViewCell {
        
        var viewModel: ValidatorsCellViewModel?
        lazy var view = ValidatorItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? ValidatorsCellViewModel else { return }
            self.viewModel = vm
            let coin = vm.rawValue
            view.nameLabel.text = coin.validatorName
            
            view.apyLabel.attributedText = vm.rewardsFormatter
            view.indexLabel.text = coin.index
            view.tokenIV.setImage(urlString: coin.imageURL, placeHolderImage: IMG("Dapp.Placeholder"))
            view.layoutCorner(vm.corners, size: vm.size)
        }
        
        override class func height(model: Any?) -> CGFloat { 74.auto() }
    }
}
                
