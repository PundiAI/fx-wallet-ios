import WKKit
extension SwapApproveViewController {
    class ApproveDetailsSwitch: UIView {
        lazy var editButton: UIButton = {
            let v = UIButton()
            v.title = TR("Swap.ApproveDetails.Switch")
            v.titleFont = XWallet.Font(ofSize: 14)
            v.setTitleColor(COLOR.title, for: .normal)
            return v
        }()

        var unfold: Bool = false {
            didSet {
                let image = unfold ? IMG("Swap.Up") : IMG("Swap.Down")
                editButton.setImage(image, for: .normal)
            }
        }

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
            editButton.isUserInteractionEnabled = false
        }

        private func layoutUI() {
            addSubview(editButton)
            editButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.top.bottom.equalToSuperview()
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            editButton.imagePosition(at: .right, space: 4)
        }
    }
}

extension SwapApproveViewController {
    class PermissionPanel: UIView {
        lazy var contentView = UIView(HDA(0xF0F3F5))
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

        lazy var amountTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            return v
        }()

        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = COLOR.title
            v.numberOfLines = 2
            v.textAlignment = .right
            return v
        }()

        lazy var toTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.title
            return v
        }()

        lazy var toLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = COLOR.title
            v.textAlignment = .right
            v.lineBreakMode = .byTruncatingMiddle
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
            contentView.autoCornerRadius = 16
        }

        private func layoutUI() {
            addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
            contentView.addSubviews([titleLabel, subTitleLabel, amountTitleLabel, amountLabel, toTitleLabel, toLabel])
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(16.auto())
                make.top.equalTo(24.auto())
                make.height.equalTo(19.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(16.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
            }
            amountTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(subTitleLabel.snp.bottom).offset(42.auto())
                make.left.equalToSuperview().offset(16.auto())
                make.height.equalTo(17.auto())
            }
            amountLabel.snp.makeConstraints { make in
                make.left.equalTo(amountTitleLabel.snp.right).offset(20.auto())
                make.right.equalToSuperview().offset(-16.auto())
                make.top.equalTo(amountTitleLabel.snp.top)
            }
            toTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(amountTitleLabel.snp.bottom).offset(42.auto())
                make.left.equalToSuperview().offset(16.auto())
                make.width.lessThanOrEqualTo(40)
                make.height.equalTo(17.auto())
            }
            toLabel.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16.auto())
                make.centerY.equalTo(toTitleLabel)
                make.left.equalTo(toTitleLabel.snp.right).offset(20.auto())
            }
        }
    }
}

extension SwapApproveViewController {
    class BasePanel: UIView {
        lazy var contentView = UIView(HDA(0xF0F3F5))
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
            contentView.autoCornerRadius = 16
        }

        private func layoutUI() {
            addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
        }
    }
}

extension SwapApproveViewController {
    class DataPanel: BasePanel {
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            return v
        }()

        lazy var typeTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            return v
        }()

        lazy var typeLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.title
            v.textAlignment = .right
            return v
        }()

        lazy var hashLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
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
            contentView.addSubviews([titleLabel, typeTitleLabel, typeLabel, hashLabel])
            titleLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16.auto())
                make.top.equalToSuperview().offset(24.auto())
            }
            typeTitleLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(40.auto())
                make.height.equalTo(17.auto())
            }
            typeLabel.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16.auto())
                make.centerY.equalTo(typeTitleLabel.snp.centerY)
                make.height.equalTo(17.auto())
            }
            hashLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(16.auto())
                make.top.equalTo(typeTitleLabel.snp.bottom).offset(40.auto())
            }
        }
    }
}
