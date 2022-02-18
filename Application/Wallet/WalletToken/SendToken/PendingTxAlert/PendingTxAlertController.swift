//
//  PendingTxAlertController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/6/15.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension WKWrapper where Base == PendingTxAlertController {
    var view: Base.ActionView { return base.view as! Base.ActionView }
}

extension PendingTxAlertController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        let vc = PendingTxAlertController()
        vc.confirmHandler = context["handler"] as? (WKError?, UIViewController?) -> Void
        return vc
    }
}

class PendingTxAlertController: FxRegularPopViewController {
    
    var confirmHandler: ((WKError?, UIViewController?) -> Void)?
    override func bindListView() {
        
        listBinder.push(ContentCell.self).waittingView.loading()
        listBinder.push(ActionCell.self).submitButton.action { [weak self] in
            self?.confirmHandler?(nil, self)
        }
    }
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.confirmHandler?(.canceled, self)
    }
}







//MARK: View
extension PendingTxAlertController {
    class ContentCell: FxTableViewCell {
        
        private lazy var titleLabel = UILabel(text: TR("PendingAlert.Title"), font: XWallet.Font(ofSize: 24, weight: .medium), alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        private lazy var noticeLabel = UILabel(text: TR("Pay.Pending.Cancelled"), font: XWallet.Font(ofSize: 14), lines: 0)
        
        lazy var waittingBGView = UIView(.white, cornerRadius: 28)
        lazy var waittingView = FxTxLoadingView.loading24()
        
        override class func height(model: Any?) -> CGFloat {
        
            let width = ScreenWidth - 24.auto() * 4
            let noticeHeight = TR("Pay.Pending.Cancelled").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
            return (56 + 16).auto() + (29 + 8).auto() + noticeHeight
        }
        
        override func layoutUI() {
            contentView.addSubviews([waittingBGView, waittingView, titleLabel, noticeLabel])
            
            waittingBGView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            waittingView.snp.makeConstraints { (make) in
                make.center.equalTo(waittingBGView)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(waittingBGView.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(29.auto())
            }
            
            noticeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension PendingTxAlertController {

    class ActionCell: WKTableViewCell.ActionCell {

        override func configuration() {
            super.configuration()

            submitButton.title = TR("Continue")
        }
    }
}


