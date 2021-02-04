//
//  TokenInfoSocialCell.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift

extension TokenInfoSocialListBinder {
    class Cell: FxTableViewCell {
        
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            
            view.iconIV.setImage(urlString: vm.img, placeHolderImage: IMG("Dapp.Placeholder"))
            view.titleLabel.text = vm.title
            view.subtitleLabel.text = vm.subtitle
        }
    }
}




