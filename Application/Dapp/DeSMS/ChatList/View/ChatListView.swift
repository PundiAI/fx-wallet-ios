import WKKit
extension ChatListViewController {
    class View: UIView {
        lazy var navBar = FxBlurNavBar(size: CGSize(width: ScreenWidth, height: StatusBarHeight + 56))
        lazy var newMessageButton: UIButton = {
            let v = UIButton(size: CGSize(width: 217, height: 44))
            v.image = IMG("Chat.Add")
            v.title = TR("ChatList.Title")
            v.titleColor = HDA(0x1A7CEB)
            v.titleFont = XWallet.Font(ofSize: 16, weight: .bold)
            v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            v.layer.cornerRadius = 22
            v.layer.masksToBounds = true
            v.setTitlePosition(.right, withAdditionalSpacing: 10)
            return v
        }()

        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        lazy var listHeaderView = UIView(COLOR.backgroud)
        lazy var avatarIV: ChatAvatarBinder = {
            let v = ChatAvatarBinder(size: CGSize(width: 60, height: 60))
            v.layer.borderColor = UIColor.white.cgColor
            v.layer.borderWidth = 1
            return v
        }()

        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 20, weight: .bold)
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            return v
        }()

        lazy var addressButton: UIButton = {
            let v = UIButton(size: CGSize(width: ScreenWidth - 20, height: 30))
            v.image = IMG("Chat.Copy_clear")
            v.title = "--"
            v.titleColor = UIColor.white.withAlphaComponent(0.5)
            v.titleFont = XWallet.Font(ofSize: 12)
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
            backgroundColor = COLOR.backgroud
            listView.backgroundColor = COLOR.backgroud
        }

        private func layoutUI() {
            addSubview(listView)
            let navBarHeight = navBar.height
            navBar.navigationArea.addSubview(newMessageButton)
            addSubview(navBar)
            navBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(navBarHeight)
            }
            newMessageButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 217, height: 44))
            }
            listView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            listHeaderView.addSubviews([avatarIV, nameLabel, addressButton])
            listHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: navBarHeight + 194)
            listView.tableHeaderView = listHeaderView
            avatarIV.snp.makeConstraints { make in
                make.top.equalTo(navBarHeight + 32)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 60, height: 60))
            }
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(avatarIV.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.height.equalTo(24)
            }
            addressButton.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(10)
                make.height.equalTo(30)
            }
        }
    }
}
