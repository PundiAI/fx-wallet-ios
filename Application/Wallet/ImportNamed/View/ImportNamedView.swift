import WKKit
extension ImportNamedViewController {
    class View: UIView {
        var closeButton: UIButton { navBar.backButton }
        lazy var navBar = FxBlurNavBar.standard()
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("ImportNamed.Title")
            v.font = XWallet.Font(ofSize: 40, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            v.backgroundColor = .clear
            return v
        }()

        lazy var subtitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("ImportNamed.SubTitle")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()

        lazy var nickNameLabel: UILabel = {
            let v = UILabel()
            v.text = TR("@")
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            v.backgroundColor = .clear
            return v
        }()

        lazy var tipLabel: UILabel = {
            let v = UILabel()
            v.text = TR("ImportNamed.Tip")
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = COLOR.title.withAlphaComponent(0.3)
            v.backgroundColor = .clear
            return v
        }()

        lazy var doneButton = UIButton().doNormal(title: TR("Next"))
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
            doneButton.autoCornerRadius = 28
            doneButton.clipsToBounds = true
        }

        private func layoutUI() {
            addSubview(navBar)
            navBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            addView(titleLabel, subtitleLabel, nickNameLabel, tipLabel, doneButton)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(8.auto() + FullNavBarHeight)
                make.left.right.equalToSuperview().inset(24.auto())
            }
            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            nickNameLabel.snp.makeConstraints { make in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(40.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            tipLabel.snp.makeConstraints { make in
                make.top.equalTo(nickNameLabel.snp.bottom).offset(12.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            doneButton.snp.makeConstraints { make in
                make.top.equalTo(tipLabel.snp.bottom).offset(56.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    }
}
