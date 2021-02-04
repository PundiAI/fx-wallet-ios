//
//
//  XWallet
//
//  Created by May on 2020/12/25.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension OxSwapConfirmViewController {
    class TokenPanelCell: FxTableViewCell {
        
        private var viewModel: OxAmountsModel?
        lazy var view = TokenPanel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? OxAmountsModel else { return }
            self.viewModel = vm
            let from = vm.from
            let to = vm.to
            view.fromToken.tokenIV.setImage(urlString: from.token.imgUrl, placeHolderImage: from.token.imgPlaceholder)
            view.fromToken.tokenLabel.text = from.token.symbol
            
            view.toToken.tokenIV.setImage(urlString: to.token.imgUrl, placeHolderImage: to.token.imgPlaceholder)
            view.toToken.tokenLabel.text = to.token.symbol
            
            view.fromToken.amountLabel.text = from.inputformatValue.thousandth()
            view.toToken.amountLabel.text = to.inputformatValue.thousandth()
        }
        
        override class func height(model: Any?) -> CGFloat {
            return (8 + 178).auto()
        }
    }
}            

extension OxSwapConfirmViewController {
    
    class FeeCell: FxTableViewCell {
        
        private var viewModel: Any?
        lazy var view = FeeContent(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func configuration() {
            super.configuration()
        }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? OxAmountsModel, let quote = vm.quote else { return }
            
            view.rateLabel.text = vm.rantMsg

            let fee = quote.gasPrice.mul(quote.gas)
            view.estimatedLabel.text = "$ " + fee.div10(Coin.ethereum.decimal).mul(Coin.ethereum.symbol.exchangeRate().value.value.value).thousandth(2)
        }
        
        override class func height(model: Any?) -> CGFloat {
            return  PanelView.contentHeight + 24.auto()
        }
    }
}
