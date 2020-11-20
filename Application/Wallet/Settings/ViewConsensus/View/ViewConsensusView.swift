import WKKit
extension ViewConsensusViewController {
    class View: UIView {
        fileprivate lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("ViewConsensus.Title")
            v.font = XWallet.Font(ofSize: 32, weight: .bold)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()

        fileprivate lazy var noteLabel: UILabel = {
            let v = UILabel()
            v.text = TR("ViewConsensus.Subtitle")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x999999)
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()

        lazy var startButton = UIButton().doGradient(title: TR("Mnemonic.Prepare.Start"))
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = COLOR.backgroud
        }

        private func layoutUI() {
            addSubview(titleLabel)
            addSubview(noteLabel)
            addSubview(startButton)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(20 + FullNavBarHeight)
                make.left.right.equalToSuperview().inset(24)
            }
            noteLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(24)
            }
            startButton.snp.makeConstraints { make in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-88)
                make.centerX.equalToSuperview()
                make.size.equalTo(UIButton.gradientSize())
            }
        }
    }
}

extension ViewConsensusCompletedViewController {
    class View: UIView {
        fileprivate lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("ViewConsensus.Title")
            v.font = XWallet.Font(ofSize: 18, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()

        fileprivate lazy var publicKeyTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("CloudWidget.PublicKey")
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()

        lazy var copyPublicKeyButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Dapp.CopyAddress")
            return v
        }()

        lazy var publicKeyLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()

        fileprivate lazy var privateKeyTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("CloudWidget.PrivateKey")
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()

        lazy var privateKeyLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()

        lazy var copyPrivateKeyButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Dapp.CopyAddress")
            return v
        }()

        lazy var keypairBackground: UIView = {
            let v = UIView()
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            return v
        }()

        lazy var doneButton = UIButton().doGradient(title: TR("Done_U"))
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = COLOR.backgroud
        }

        private func layoutUI() {
            addSubviews([titleLabel, doneButton, keypairBackground])
            keypairBackground.addSubviews([publicKeyTitleLabel, publicKeyLabel, copyPublicKeyButton, privateKeyTitleLabel, privateKeyLabel, copyPrivateKeyButton])
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(20 + FullNavBarHeight)
                make.left.equalTo(16)
            }
            doneButton.snp.makeConstraints { make in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-88)
                make.centerX.equalToSuperview()
                make.size.equalTo(UIButton.gradientSize())
            }
            keypairBackground.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(160)
            }
            publicKeyTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(21)
                make.left.equalTo(15)
            }
            publicKeyLabel.snp.makeConstraints { make in
                make.top.equalTo(21)
                make.left.equalTo(106)
                make.right.equalTo(-43)
            }
            copyPublicKeyButton.snp.makeConstraints { make in
                make.top.equalTo(21)
                make.right.equalTo(-10)
                make.size.equalTo(CGSize(width: 25, height: 25))
            }
            privateKeyTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(publicKeyLabel.snp.bottom).offset(24)
                make.left.equalTo(15)
            }
            privateKeyLabel.snp.makeConstraints { make in
                make.top.equalTo(publicKeyLabel.snp.bottom).offset(24)
                make.left.equalTo(106)
                make.right.equalTo(-43)
            }
            copyPrivateKeyButton.snp.makeConstraints { make in
                make.top.equalTo(privateKeyTitleLabel)
                make.right.equalTo(-10)
                make.size.equalTo(CGSize(width: 25, height: 25))
            }
        }
    }
}
