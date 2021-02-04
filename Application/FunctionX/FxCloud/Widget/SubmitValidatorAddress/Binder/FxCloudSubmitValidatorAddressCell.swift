//
//  FxCloudSubmitValidatorAddressCell.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

//MARK: FxCloudSubmitValidatorAddressViewController.View
extension FxCloudSubmitValidatorAddressViewController {
    class SelectValidatorAddressCell: SelectCell {
        
        lazy var view = SelectValidatorAddressItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
    }
}


extension FxCloudSubmitValidatorAddressViewController {
    class ValidatorAddressCell: FxTableViewCell {
        
        lazy var view = ValidatorAddressItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? [String: String] else { return }
            
            weak var welf = self
            view.walletAddressLabel.text = vm["walletAddress"]
            view.validatorAddressLabel.text = vm["validatorAddress"]
            
            view.copyWalletAddressButton.rx.tap.subscribe(onNext: { (_) in
                welf?.copy(string: vm["walletAddress"])
            }).disposed(by: reuseBag)
            
            view.copyValidatorAddressButton.rx.tap.subscribe(onNext: { (_) in
                welf?.copy(string: vm["validatorAddress"])
            }).disposed(by: reuseBag)
            
            view.deleteButton.rx.tap.subscribe(onNext: { (_) in
                welf?.router(event: "delete")
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? [String: String],
                let walletAddress = vm["walletAddress"],
                let validatorAddress = vm["validatorAddress"] else { return 148 }
            
            let walletAddressH = walletAddress.height(ofWidth: ScreenWidth - 106 - 43 - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium)])
            let validatorAddressH = validatorAddress.height(ofWidth: ScreenWidth - 106 - 43 - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium)])
            return 10 + 20 + walletAddressH + 16 + validatorAddressH + 20
        }
        
        private func copy(string: String?) {
            UIPasteboard.general.string = string
            Router.topViewController?.hud?.text(m: TR("Copied"))
        }
    }
}





//MARK: FxCloudSubmitValidatorAddressCompletedViewController.View
extension FxCloudSubmitValidatorAddressCompletedViewController {
    class ValidatorAddressCell: FxTableViewCell {
        
        lazy var view = ValidatorAddressItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? [String: String] else { return }
            
            view.walletAddressLabel.text = vm["walletAddress"]
            view.validatorAddressLabel.text = vm["validatorAddress"]
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? [String: String],
                let walletAddress = vm["walletAddress"],
                let validatorAddress = vm["validatorAddress"] else { return 148 }
            
            let walletAddressH = walletAddress.height(ofWidth: ScreenWidth - 108 - 15 - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium)])
            let validatorAddressH = validatorAddress.height(ofWidth: ScreenWidth - 108 - 15 - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium)])
            return 20 + walletAddressH + 16 + validatorAddressH + 20
        }
    }
}
