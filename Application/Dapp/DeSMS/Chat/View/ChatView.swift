import WKKit
extension ChatViewController {
    class View: UIView {
        lazy var contentView = UIView(COLOR.backgroud)
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        var textInputTV: FxTextView { return textInputPanel.textInputTV }
        lazy var textInputPanel = TextInputPanel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        lazy var navBar = FxBlurNavBar(size: CGSize(width: ScreenWidth, height: StatusBarHeight + 56))
        var lockButton: UIButton { navBar.rightButton }
        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()

        lazy var updateDateLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12, weight: .bold)
            v.textColor = HDA(0x1A7CEB)
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
            backgroundColor = HDA(0x1D1D1D)
            listView.backgroundColor = HDA(0x1D1D1D)
            lockButton.image = IMG("Chat.Lock")
        }

        private func layoutUI() {
            addSubview(contentView)
            contentView.addSubview(textInputPanel)
            contentView.addSubview(listView)
            let navBarHeight = navBar.height
            navBar.navigationArea.addSubviews([nameLabel, updateDateLabel])
            contentView.addSubview(navBar)
            navBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(navBarHeight)
            }
            nameLabel.snp.makeConstraints { make in
                make.left.equalTo(navBar.backButton.snp.right)
                make.centerY.equalToSuperview().offset(-10)
                make.height.equalTo(16)
            }
            updateDateLabel.snp.makeConstraints { make in
                make.left.equalTo(navBar.backButton.snp.right)
                make.centerY.equalToSuperview().offset(10)
                make.height.equalTo(14)
            }
            contentView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            textInputPanel.snp.makeConstraints { make in
                make.bottom.equalTo(contentView.safeAreaLayout.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(56)
            }
            let navBarSpace = UIView(.clear)
            navBarSpace.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: navBarHeight + 10)
            listView.tableHeaderView = navBarSpace
            listView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.bottom.equalTo(textInputPanel.snp.top)
                make.left.right.equalToSuperview()
            }
        }
    }
}
