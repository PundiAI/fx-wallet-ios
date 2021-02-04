//
//  FxCloudWidgetAddressCell.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/20.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

//MARK: TitleCell
extension FxCloudWidgetActionViewController {
    class TitleCell: WKTableViewCell.TitleCell {
        override func configuration() {
            super.configuration()
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .left
        }
        
        override func layoutUI() {
            super.layoutUI()
            
            titleLabel.snp_remakeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24))
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let text = model as? String else { return 114 }
            
            return text.height(ofWidth: ScreenWidth - 24 * 2, attributes: [.font: XWallet.Font(ofSize: 32, weight: .bold)]) + 10
        }
    }
}

//MARK: SubtitleCell
extension FxCloudWidgetActionViewController {
    class SubtitleCell: TitleCell {
        override func configuration() {
            super.configuration()
            titleLabel.font = XWallet.Font(ofSize: 16)
            titleLabel.textColor = HDA(0x999999)
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let text = model as? String else { return 114 }
            
            return text.height(ofWidth: ScreenWidth - 24 * 2, attributes: [.font: XWallet.Font(ofSize: 16)]) + 4
        }
    }
}


//MARK: AddressCell
extension FxCloudWidgetActionViewController {
    class AddressCell: FxTableViewCell {
        
        lazy var view = AddressItemView(frame: ScreenBounds)
        override func getView() -> UIView { return view }
        
        override class func height(model: Any?) -> CGFloat { 64 + 10 }
    }
}

extension FxCloudWidgetActionViewController {
    class SelectCell: FxTableViewCell {
        
        override class func height(model: Any?) -> CGFloat { 88 }
    }
}
