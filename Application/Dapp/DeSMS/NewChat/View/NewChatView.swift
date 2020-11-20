import WKKit
extension NewChatViewController {
    class View: UIView {
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar(size: CGSize(width: ScreenWidth, height: StatusBarHeight + 56))
            v.blur.isHidden = true
            v.backgroundColor = HDA(0x222222)
            v.backButton.image = IMG("Chat.NavLeft")
            v.rightButton.image = IMG("ic_close_white")
            return v
        }()

        var closeButton: UIButton { navBar.rightButton }
        fileprivate lazy var navTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("ChatList.Title")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = .white
            return v
        }()

        fileprivate lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("NewChat.Title")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x999999)
            v.backgroundColor = .clear
            return v
        }()

        fileprivate lazy var inputTFContainer = FxLineTextField(background: HDA(0x1A7CEB))
        var inputTF: UITextField { return inputTFContainer.interactor }
        lazy var searchButton = UIButton().doGradient(title: TR("Search_U"))
        lazy var recordCountLabel: UILabel = {
            let v = UILabel()
            v.text = TR("NewChat.TotalRecord$", "0")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()

        fileprivate lazy var noDataLabel: UILabel = {
            let v = UILabel()
            v.text = TR("NewChat.NoData")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = UIColor.white.withAlphaComponent(0.32)
            v.backgroundColor = .clear
            return v
        }()

        lazy var userContainer: UIView = {
            let v = UIView(size: CGSize(width: ScreenWidth - 18 * 2, height: 80))
            v.gradientBGLayer.size = v.size
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            return v
        }()

        lazy var userAddressLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.backgroundColor = .clear
            v.numberOfLines = 2

            return v
        }()

        lazy var userNameLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()

        lazy var userUpdateDateLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.backgroundColor = .clear
            v.alpha = 0.5
            return v
        }()

        lazy var addUserButton: UIButton = {
            let v = UIButton(size: CGSize(width: 48, height: 48))
            v.image = IMG("Chat.Add_white")
            v.backgroundColor = .clear
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
            backgroundColor = HDA(0x272727)
            userContainer.isHidden = true
            inputTFContainer.backgroundColor = HDA(0x303030)
        }

        private func layoutUI() {
            let navBarHeight = navBar.height
            navBar.navigationArea.addSubview(navTitleLabel)
            addSubview(navBar)
            navBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(navBarHeight)
            }
            navBar.backButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview().offset(2)
                make.left.equalTo(4)
                make.size.equalTo(CGSize(width: 53, height: 53))
            }
            navTitleLabel.snp.makeConstraints { make in
                make.left.equalTo(navBar.backButton.snp.right).offset(6)
                make.centerY.equalToSuperview()
            }
            addSubview(titleLabel)
            addSubview(inputTFContainer)
            addSubview(searchButton)
            addSubview(recordCountLabel)
            addSubview(noDataLabel)
            userContainer.addSubviews([userAddressLabel, userNameLabel, userUpdateDateLabel, addUserButton])
            addSubview(userContainer)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(20 + navBarHeight)
                make.left.right.equalToSuperview().inset(24)
            }
            inputTFContainer.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(18)
                make.left.right.equalToSuperview()
                make.height.equalTo(48)
            }
            searchButton.snp.makeConstraints { make in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(11)
                make.centerX.equalToSuperview()
                make.size.equalTo(UIButton.gradientSize())
            }
            recordCountLabel.snp.makeConstraints { make in
                make.top.equalTo(searchButton.snp.bottom).offset(55)
                make.left.equalTo(18)
                make.height.equalTo(20)
            }
            noDataLabel.snp.makeConstraints { make in
                make.top.equalTo(recordCountLabel.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
            }
            userContainer.snp.makeConstraints { make in
                make.top.equalTo(recordCountLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(18)
                make.height.equalTo(80)
            }

            userNameLabel.snp.makeConstraints { make in
                make.top.equalTo(10)
                make.left.equalTo(12)
                make.right.equalTo(-48)
                make.height.equalTo(18)
            }
            userAddressLabel.snp.makeConstraints { make in
                make.top.equalTo(userNameLabel.snp.bottom).offset(4)
                make.left.equalTo(12)
                make.right.equalTo(-48)
            }
            userUpdateDateLabel.isHidden = true
            addUserButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48))
            }
        }
    }
}
