import WKKit
extension VerifyAlertViewController {
    static var messageString1 = TR("CheckBackUp.Success.Title")
    static var messageString0 = TR("CheckBackUp.Success.SubTitle")
    class ContentCell: FxTableViewCell {
        private lazy var tipBackground = UIView(.white, cornerRadius: 28)
        private lazy var tipIV = UIImageView(image: IMG("alert.success"))
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: messageString1,
                            font: XWallet.Font(ofSize: 24,
                                               weight: .bold))
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
        private lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: messageString0,
                            font: XWallet.Font(ofSize: 16),
                            textColor: UIColor.white.withAlphaComponent(0.5))
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 2 * 2
            let font0 = UILabel().then {
                $0.font = XWallet.Font(ofSize: 24, weight: .bold)
                $0.text = messageString1
                $0.autoFont = true }.font
            let noticeHeight0 = messageString1.height(ofWidth: width, attributes: [.font: font0 as Any])
            let style = NSMutableParagraphStyle().then { $0.lineSpacing = 4.auto() }
            let font = UILabel().then {
                $0.font = XWallet.Font(ofSize: 16)
                $0.text = messageString0
                $0.autoFont = true }.font
            let noticeHeight1 = messageString0.height(ofWidth: width, attributes: [.font: font as Any, .paragraphStyle: style])
            return (32 + 56).auto() + (16.auto() + noticeHeight0) + (16.auto() + noticeHeight1)
        }
        override func configuration() {
            super.configuration()
            let title = messageString0
            title.lineSpacingLabel(noticeLabel2)
            noticeLabel2.textAlignment = .center
        }
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1, noticeLabel2])
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
            noticeLabel2.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}
extension VerifyAlertViewController {
    class ActionCell: WKTableViewCell.ActionCell {
        var confirmButton: UIButton { submitButton }
        override func configuration() {
            super.configuration()
            confirmButton.title = TR("Button.Confirm")
        }
    }
}
extension VerifyAlertErrorViewController {
    static var messageString0 = TR("CheckBackUp.Failure.SubTitle")
    static var messageString1 = TR("CheckBackUp.Failure.Title")
    class ContentCell: FxTableViewCell {
        private lazy var tipBackground = UIView(.white).then {
            $0.autoCornerRadius = 28
        }
        private lazy var tipIV = UIImageView(image: IMG("alert.error"))
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: messageString1,
                            font: XWallet.Font(ofSize: 24,
                                               weight: .bold))
            v.textAlignment = .center
            v.numberOfLines = 0
            v.autoFont = true
            return v
        }()
        private lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: messageString0,
                            font: XWallet.Font(ofSize: 16),
                            textColor: UIColor.white.withAlphaComponent(0.5))
            v.textAlignment = .center
            v.numberOfLines = 0
            v.autoFont = true
            return v
        }()
        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 2 * 2
            let font1: UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 24, weight: .bold)
                $0.text = messageString1
                $0.autoFont = true }.font
            let font2: UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 16)

                messageString0.lineSpacingLabel($0)
                $0.autoFont = true }.font
            let style = NSMutableParagraphStyle().then { $0.lineSpacing = 4.auto() }
            let noticeHeight1 = messageString1.height(ofWidth: width, attributes: [.font: font1])
            let noticeHeight2 = messageString0.height(ofWidth: width, attributes: [.font: font2, .paragraphStyle: style])
            return (32 + 56).auto() + (16.auto() + noticeHeight1) + (16.auto() + noticeHeight2)
        }
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1, noticeLabel2])
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
            noticeLabel2.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}
extension VerifyAlertErrorViewController {
    class ActionCell: WKTableViewCell.ActionCell {
        var confirmButton: UIButton { submitButton }
        override func configuration() {
            super.configuration()
            confirmButton.title = TR("Button.Restart")
        }
    }
}
extension VerifyStopAlertViewController {
    static var messageString0 = TR("CheckBackUp.Stop.SubTitle")
    static var messageString1 = TR("CheckBackUp.Stop.Title")
    class ContentCell: FxTableViewCell {
        private lazy var tipBackground = UIView(.white).then {
            $0.autoCornerRadius = 28
        }
        private lazy var tipIV = UIImageView(image: IMG("ic_not_notify"))
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: messageString1,
                            font: XWallet.Font(ofSize: 24,
                                               weight: .bold))
            v.textAlignment = .center
            v.numberOfLines = 0
            v.autoFont = true
            return v
        }()
        private lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: messageString0,
                            font: XWallet.Font(ofSize: 16),
                            textColor: UIColor.white.withAlphaComponent(0.5))
            v.textAlignment = .center
            v.numberOfLines = 0
            v.autoFont = true
            return v
        }()
        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 2 * 2
            let font1: UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 24, weight: .bold)
                $0.text = messageString1
                $0.autoFont = true }.font
            let font2: UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 16)

                messageString0.lineSpacingLabel($0)
                $0.autoFont = true }.font
            let style = NSMutableParagraphStyle().then { $0.lineSpacing = 4.auto() }
            let noticeHeight1 = messageString1.height(ofWidth: width, attributes: [.font: font1])
            let noticeHeight2 = messageString0.height(ofWidth: width, attributes: [.font: font2, .paragraphStyle: style])
            return (32 + 56).auto() + (16.auto() + noticeHeight1) + (16.auto() + noticeHeight2)
        }
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1, noticeLabel2])
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
            noticeLabel2.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}
extension VerifyStopAlertViewController {
    class ActionCell: WKTableViewCell.DoubleActionCell {
        var confirmButton: UIButton { leftActionButton }
        var cancelButton: UIButton { rightActionButton }
        override func configuration() {
            super.configuration()
            confirmButton.title = TR("Button.InsistBack")
            cancelButton.title = TR("Button.Cancel")
        }
    }
}
