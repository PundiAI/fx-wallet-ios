import WKKit
extension SwapApproveViewController {
    class View: UIView {
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        lazy var startButton = UIButton().doNormal(title: TR("Button.Confirm"))
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = .white
            listView.backgroundColor = .clear
            startButton.autoCornerRadius = 28
        }

        private func layoutUI() {
            addSubview(listView)
            addSubview(startButton)
            listView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(FullNavBarHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(startButton.snp.top).offset(-16.auto())
            }
            startButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
            }
        }
    }
}

extension SwapApproveViewController {
    class InfoView: UIView {
        lazy var iconIV = UIImageView()
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = COLOR.title
            v.numberOfLines = 0
            v.textAlignment = .center
            return v
        }()

        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
            v.textAlignment = .center
            return v
        }()

        lazy var editButton: UIButton = {
            let v = UIButton()
            v.title = TR("Swap.Edit.Permission")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .bold)
            v.setTitleColor(COLOR.title, for: .normal)
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
            addSubviews([iconIV, titleLabel, subTitleLabel, editButton])
            iconIV.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 42, height: 45).auto())
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(13.auto())
            }
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(iconIV.snp.bottom).offset(12.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
            }
            editButton.snp.makeConstraints { make in
                make.top.equalTo(subTitleLabel.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(19.auto())
            }
        }
    }
}

extension SwapApproveViewController {
    class FeePanel: BasePanel {
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            return v
        }()

        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
            return v
        }()

        lazy var currencyLalel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            v.textAlignment = .right
            return v
        }()

        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
            v.textAlignment = .right
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
            contentView.addSubviews([titleLabel, subTitleLabel, currencyLalel, amountLabel])
            titleLabel.snp.makeConstraints { make in
                make.left.equalTo(16.auto())
                make.top.equalTo(24.auto())
                make.height.equalTo(19.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.left.equalTo(titleLabel.snp.left)
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.width.equalTo(contentView.snp.width).multipliedBy(0.5)
            }
            currencyLalel.snp.makeConstraints { make in
                make.top.equalTo(24.auto())
                make.right.equalToSuperview().offset(-16.auto())
                make.height.equalTo(19.auto())
            }
            amountLabel.snp.makeConstraints { make in
                make.right.equalTo(currencyLalel.snp.right)
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(subTitleLabel.snp.right).offset(4.auto())
            }
        }
    }
}
