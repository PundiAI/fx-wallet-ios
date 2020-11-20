import WKKit
extension ChatListViewController {
    class ItemView: UIView {
        fileprivate lazy var lineView = UIView(HDA(0x373737))
        lazy var avatarIV: ChatAvatarBinder = {
            let v = ChatAvatarBinder(size: CGSize(width: 46, height: 46))
            v.textLabel.font = XWallet.Font(ofSize: 24, weight: .bold)
            return v
        }()

        lazy var badgeView = ChatBadgeBinder.standard
        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            return v
        }()

        lazy var textLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.numberOfLines = 2
            return v
        }()

        lazy var dateLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.textAlignment = .right
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
            lineView.alpha = 0.4
            badgeView.isHidden = true
        }

        private func layoutUI() {
            addSubviews([avatarIV, nameLabel, textLabel, dateLabel, lineView, badgeView])
            lineView.snp.makeConstraints { make in
                make.top.equalTo(0.75)
                make.left.right.equalToSuperview()
                make.height.equalTo(0.75)
            }
            avatarIV.snp.makeConstraints { make in
                make.left.equalTo(18)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 46, height: 46))
            }
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(avatarIV)
                make.left.equalTo(avatarIV.snp.right).offset(11)
                make.right.equalTo(dateLabel.snp.left)
                make.height.equalTo(19)
            }
            textLabel.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(2)
                make.left.equalTo(avatarIV.snp.right).offset(11)
                make.right.equalTo(-16)
            }
            dateLabel.snp.makeConstraints { make in
                make.top.equalTo(avatarIV)
                make.right.equalTo(-15)
                make.size.equalTo(CGSize(width: 100, height: 19))
            }
            let badgeSize = badgeView.size
            badgeView.snp.makeConstraints { make in
                make.top.equalTo(avatarIV).offset(-2)
                make.left.equalTo(avatarIV).offset(-10)
                make.size.equalTo(badgeSize)
            }
        }
    }
}
