import WKKit
extension BiometricsAlertViewController {
    class ContentView: UIView {
        private lazy var tipBackground = UIView(.white).then { $0.autoCornerRadius = 28 }
        private lazy var tipIV = UIImageView(image: IMG("ic_not_notify"))
        lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: TR(""), font: XWallet.Font(ofSize: 20, weight: .medium))
            v.textAlignment = .center
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()

        lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: TR(""), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.textAlignment = .center
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()

        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = .clear
        }

        private func layoutUI() {
            addSubviews([tipBackground, tipIV, noticeLabel1, noticeLabel2])
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
            }
            noticeLabel2.snp.makeConstraints { make in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}

extension BiometricsAlertViewController {
    class ActionCell: WKTableViewCell.DoubleActionCell {
        var cancelButton: UIButton { leftActionButton }
        var confirmButton: UIButton { rightActionButton }
        override func configuration() {
            super.configuration()
            confirmButton.titleColor = COLOR.title
            confirmButton.backgroundColor = .white
        }

        override func update(model: Any?) {
            guard let vm = model as? ViewModel else { return }
            cancelButton.title = vm.leftBTitle
            confirmButton.title = vm.rightBTitle
        }
    }
}
