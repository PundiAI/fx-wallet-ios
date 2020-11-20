import WKKit
extension ResetWalletNoticeAlertController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        let vc = ResetWalletNoticeAlertController()
        vc.completionHandler = context["handler"] as? (WKError?) -> Void
        return vc
    }
}

class ResetWalletNoticeAlertController: FxRegularPopViewController {
    var completionHandler: ((WKError?) -> Void)?
    override var dismissWhenTouch: Bool { true }
    override var interactivePopIsEnabled: Bool { false }
    override func bindListView() {
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }

    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { _ in
            Router.pop(welf)
        }).disposed(by: cell.defaultBag)
        let handler = completionHandler
        cell.confirmButton.action {
            Router.pop(welf) {
                handler?(nil)
            }
        }
    }

    override func layoutUI() {
        hideNavBar()
    }
}

extension ResetWalletNoticeAlertController: NotificationToastProtocol {
    func allowToast(notif _: FxNotification) -> Bool { false }
}

extension ResetWalletNoticeAlertController {
    class ContentCell: FxTableViewCell {
        private lazy var tipBackground = UIView(.white, cornerRadius: 28)
        private lazy var tipIV = UIImageView(image: IMG("ic_not_notify"))
        private lazy var noticeLabel1 = UILabel(text: TR("ResetWallet.Title"), font: XWallet.Font(ofSize: 20, weight: .medium), alignment: .center)
        private lazy var noticeLabel2 = UILabel(text: TR("SecurityVerify.ResetWalletNotice"), font: XWallet.Font(ofSize: 16), textColor: UIColor.white.withAlphaComponent(0.5), lines: 0, alignment: .center)
        override class func height(model _: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 4 - 24 * 2
            let noticeHeight2 = TR("SecurityVerify.ResetWalletNotice").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 16)])
            return (32 + 56).auto() + (16 + 24).auto() + (16.auto() + noticeHeight2)
        }

        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1, noticeLabel2])
            tipBackground.snp.makeConstraints { make in
                make.top.equalTo(32.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            tipIV.snp.makeConstraints { make in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            noticeLabel1.snp.makeConstraints { make in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(24.auto())
            }
            noticeLabel2.snp.makeConstraints { make in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}

extension ResetWalletNoticeAlertController {
    class ActionCell: WKTableViewCell.DoubleActionCell {
        var cancelButton: UIButton { leftActionButton }
        var confirmButton: UIButton { rightActionButton }
        override func configuration() {
            super.configuration()
            confirmButton.title = TR("Reset")
            confirmButton.titleColor = .white
            confirmButton.backgroundColor = HDA(0xFA6237)
        }
    }
}
