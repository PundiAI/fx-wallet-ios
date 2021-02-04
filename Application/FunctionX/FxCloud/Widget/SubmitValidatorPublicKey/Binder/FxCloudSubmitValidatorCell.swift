//
//  FxCloudSubmitValidatorPublicKeyView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

//MARK: FxCloudSubmitValidatorPublicKeyViewController.View
extension FxCloudSubmitValidatorPublicKeyViewController {
    class PublicKeyCell: AddressCell {
        
        var publicKeyLabel: UILabel { view.addressLabel }
        
        override func configuration() {
            super.configuration()
            
            view.relayout(hideRemark: true)
        }
    }
}















//MARK: FxCloudSubmitValidatorPublicKeyCompletedViewController.View
extension FxCloudSubmitValidatorPublicKeyCompletedViewController {
    class PublicKeyCell: FxTableViewCell {
        
        lazy var view = InfoItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let publicKey = viewModel as? String else { return }
            
            view.contentLabel.text = publicKey
        }
        
        override func configuration() {
            super.configuration()
            
            view.titleLabel.text = TR("CloudWidget.PublicKey")
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let text = model as? String else { return 93 }
            
            return text.height(ofWidth: ScreenWidth - 108 - 15 - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium)]) + 20 * 2
        }
    }
}
