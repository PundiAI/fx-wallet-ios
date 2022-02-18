//
//  FxClaimAlertController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/18.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

class FxClaimAlertController: FxRegularPopViewController {
    
    var confirmHandler: ((UIViewController?) -> ())?
    override func bindListView() {
        
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self).submitButton.action { [weak self] in
            if let handler = self?.confirmHandler {
                handler(self)
            } else {
                Router.pop(self)
            }
        }
    }
}







//MARK: View
extension FxClaimAlertController {
    class ContentCell: FxTableViewCell {
        
        private lazy var titleLabel = UILabel(text: TR("FxStaking.AboutClaim"), font: XWallet.Font(ofSize: 24, weight: .medium))
        private lazy var noticeLabel = UILabel(text: TR("FxStaking.ClaimDesc"), font: XWallet.Font(ofSize: 14), lines: 0)
        
        override class func height(model: Any?) -> CGFloat {
        
            let width = ScreenWidth - 24.auto() * 4
            let noticeHeight = TR("FxStaking.ClaimDesc").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
            return (29 + 8).auto() + noticeHeight
        }
        
        override func layoutUI() {
            contentView.addSubviews([titleLabel, noticeLabel])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(24.auto())
                make.height.equalTo(29.auto())
            }
            
            noticeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension FxClaimAlertController {
    
    class ActionCell: WKTableViewCell.ActionCell {
        
        override func configuration() {
            super.configuration()
            
            submitButton.title = TR("OK")
        }
    }
}
