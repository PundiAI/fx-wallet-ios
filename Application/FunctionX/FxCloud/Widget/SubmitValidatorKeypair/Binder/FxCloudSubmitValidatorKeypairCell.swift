//
//  FxCloudSubmitValidatorKeypairCell.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import FunctionX

//MARK: FxCloudSubmitValidatorKeypairViewController.View
extension FxCloudSubmitValidatorKeypairViewController {
    class SelectKeypairCell: SelectCell {
        
        lazy var view = SelectKeypairItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
    }
}


extension FxCloudSubmitValidatorKeypairViewController {
    class KeypairCell: FxTableViewCell {
        
        lazy var view = KeypairItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            
            view.deleteButton.rx.tap.subscribe(onNext: { [weak self](_) in
                self?.router(event: "delete")
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat { 10 + 64 + 48 }
    }
}





//MARK: FxCloudSubmitValidatorKeypairCompletedViewController.View
extension FxCloudSubmitValidatorKeypairCompletedViewController {
    class KeypairCell: FxTableViewCell {
        
        lazy var view = KeypairItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let publicKey = viewModel as? String else { return  }
            
            view.publicKeyLabel.text = publicKey
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let publicKey = model as? String else { return 93 }
            
            let publicKeyHeight = publicKey.height(ofWidth: ScreenWidth - 108 - 15 - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium)]) + 20 * 2
            return publicKeyHeight + 52
        }
    }
}
