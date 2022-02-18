

import WKKit

extension BackAlertViewController {
    class ContentCell: FxTableViewCell {
        static var messageString0 = TR("BackAlert.AlertTitle")
        
        private lazy var tipBackground: UIView =  {
            let v = UIView(.white)
            v.autoCornerRadius = 28 
            return v
        }()
        
        private lazy var tipIV = UIImageView(image: IMG("ic_not_notify"))
        
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: ContentCell.messageString0,
                            font: XWallet.Font(ofSize: 20, weight: .medium))
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 2 * 2
            
            let font:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 20, weight: .medium)
                $0.text = messageString0
                $0.autoFont = true }.font
             
            let noticeHeight1 = TR("DeleteWallet.Notice1").height(ofWidth: width, attributes: [.font:font])
            return (32 + 56).auto() + (16.auto() + noticeHeight1)
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1])
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(32.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            noticeLabel1.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension BackAlertViewController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var confirmButton: UIButton { rightActionButton }
            
        var cancelButton: UIButton { leftActionButton }
        
        override func configuration() {
            super.configuration()
            leftActionButton.title = TR("Button.Cancel")
            rightActionButton.title = TR("Button.OK")
        }
    }
}
