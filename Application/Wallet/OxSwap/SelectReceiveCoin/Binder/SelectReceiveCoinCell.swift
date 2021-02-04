//
//
//  XWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SelectReceiveCoinViewController {
    class AddCoinListCell: FxTableViewCell {
        var viewModel: AddCoinCellViewModel?
        lazy var view = AddCoinListItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? AddCoinCellViewModel else { return }
            self.viewModel = vm
            let coin = vm.rawValue
            view.tokenLabel.text = coin.symbol
            view.contractLabel.text = coin.name
            view.tokenIV.setImage(urlString: coin.icon,
                                  placeHolderImage: coin.imgPlaceholder)
//            view.tokenIV.bind(coin)
        }
        
        override class func height(model: Any?) -> CGFloat { (80 + 16).auto() }
    }
}
      
