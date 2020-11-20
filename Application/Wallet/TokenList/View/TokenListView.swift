
import Hero
import pop
import WKKit
extension TokenListViewController {
    class TokenNavigationBar: WKNavigationBar {
        lazy var backgroundBlurView: UIView = { VisualEffectView().then {
            $0.colorTint = HDA(0x080A32)
            $0.colorTintAlpha = 0.95 $0.blurRadius = 5
        }
        }()

        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("My Assets")
            v.font = XWallet.Font(ofSize: 18, weight: .regular)
            v.autoFont = true
            v.textColor = .white
            return v
        }()

        lazy var settingsButton: UIButton = {
            let v = UIButton(type: .custom)
            v.image = IMG("Wallet.Settings")
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .right
            v.tintColor = UIColor.white
            return v
        }()

        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = "$ --"
            v.font = XWallet.Font(ofSize: 48)
            v.autoFont = true
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            v.adjustsFontForContentSizeCategory = true
            return v
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)
            layoutView()
        }

        override init() {
            super.init()
            layoutView()
        }

        func layoutView() {
            addView(titleLabel, amountLabel, settingsButton)
            titleLabel.snp.makeConstraints { make in
                make.left.equalTo(24.auto())
                make.height.equalTo(22.auto())
                make.bottom.equalToSuperview()
            }
            settingsButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.right.equalToSuperview().inset(24.auto())
                make.size.equalTo(CGSize(width: NavBarHeight, height: NavBarHeight))
            }
            insertSubview(backgroundBlurView, at: 0)
            backgroundBlurView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            sendSubviewToBack(backgroundBlurView)
        }
    }
}

extension TokenListViewController {
    class View: UIView {
        var amountLabelHeight: CGFloat = 58.auto()
        var tableFooterHeight: CGFloat = (32 + 56 + 100).auto() + 100
        let navBarView = UIImageView().then {
            $0.inch(.iFull)?.addCorner([.topLeft, .topRight], radius: 36.auto())
        }

        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("My Assets")
            v.font = XWallet.Font(ofSize: 18, weight: .regular)
            v.autoFont = true
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            v.isHidden = true
            return v
        }()

        lazy var settingsButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Wallet.Settings")
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .right
            v.isHidden = true
            return v
        }()

        lazy var bgroundColorView = UIView(HDA(0x080A32))
        lazy var bgroundView = UIView(UIColor.white)
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        lazy var listHeaderView = UIView()
        private lazy var listHeaderArcView: UIView = {
            let v = UIView(.clear)
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: 60)
            return v
        }()

        private lazy var listFooter = UIView(.clear)
        lazy var addWalletButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Wallet.Add")
            v.title = TR("TokenList.AddWallet")
            v.titleFont = XWallet.Font(ofSize: 16)
            v.titleColor = HDA(0x080A32)
            v.autoCornerRadius = 28
            v.setTitlePosition(.right, withAdditionalSpacing: 10.auto())
            v.backgroundColor = HDA(0xF0F3F5)
            return v
        }()

        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = "$ --"
            v.font = XWallet.Font(ofSize: 48)
            v.autoFont = true
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            v.adjustsFontForContentSizeCategory = true
            return v
        }()

        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = UIColor.white.withAlphaComponent(0.5)
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
            backgroundColor = .clear
            listView.backgroundColor = .clear
            bgroundView.autoCornerRadius = 36
        }

        private func layoutUI() {
            insertSubview(bgroundView, at: 0)
            insertSubview(bgroundColorView, at: 0)
            insertSubview(navBarView, aboveSubview: bgroundView)
            bgroundColorView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            navBarView.snp.remakeConstraints { make in
                make.left.right.top.equalTo(bgroundView)
                make.height.equalTo(FullNavBarHeight)
            }
            addSubviews([listView]) let padding: CGFloat = (NavBarHeight - 20) / 2.0
            listHeaderView.clipsToBounds = true listHeaderView.size = CGSize(width: ScreenWidth, height: FullNavBarHeight + 156.auto() + 16.auto() - padding)
            listView.tableHeaderView = listHeaderView
            listHeaderView.addSubviews([listHeaderArcView, titleLabel, settingsButton, amountLabel, nameLabel])
            listFooter.size = CGSize(width: ScreenWidth, height: tableFooterHeight)
            listView.tableFooterView = listFooter
            listFooter.addSubview(addWalletButton)

            let arcViewHeight: CGFloat = 60
            listHeaderArcView.snp.makeConstraints { make in
                make.bottom.equalTo(arcViewHeight - 30)
                make.left.right.equalToSuperview()
                make.height.equalTo(arcViewHeight)
            }
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalTo(settingsButton)
                make.left.equalTo(24.auto())
            }
            settingsButton.snp.makeConstraints { make in
                make.top.equalTo(StatusBarHeight + 16.auto())
                make.right.equalTo(-(24 - padding).auto())
                make.size.equalTo(CGSize(width: NavBarHeight, height: NavBarHeight))
            }
            amountLabel.snp.makeConstraints { make in
                make.top.equalTo(settingsButton.snp.bottom).offset((32 - padding).auto())
                make.height.equalTo(58.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(amountLabel.snp.bottom).offset(4.auto())
                make.left.equalToSuperview().inset(24.auto())
            }
            addWalletButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(32.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            listView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.bottom.left.right.equalToSuperview()
            }
        }

        func layoutNotif(_ show: Bool) {
            let listView = self.listView
            if show, listView.contentInset.top != 100.auto() {
                if let anim = POPSpringAnimation(propertyNamed: kPOPScrollViewContentInset) {
                    anim.toValue = UIEdgeInsets(top: 100.auto(), left: 0, bottom: 0, right: 0)
                    listView.pop_add(anim, forKey: "kPOPScrollViewContentInset")
                    let anim1 = POPSpringAnimation(propertyNamed: kPOPScrollViewContentOffset)
                    anim1?.toValue = CGPoint(x: 0, y: -1 * 100.auto())
                    listView.pop_add(anim1, forKey: "kPOPScrollViewContentOffset")
                }
            }
            if !show, listView.contentInset.top > 0 {
                if let anim = POPSpringAnimation(propertyNamed: kPOPScrollViewContentInset) {
                    anim.toValue = UIEdgeInsets.zero
                    listView.pop_add(anim, forKey: "kPOPScrollViewContentInset")
                    let anim1 = POPSpringAnimation(propertyNamed: kPOPScrollViewContentOffset)
                    anim1?.toValue = CGPoint.zero
                    listView.pop_add(anim1, forKey: "kPOPScrollViewContentOffset")
                    anim1?.completionBlock = { [weak listView] _, _ in listView?.setContentOffset(CGPoint(x: 0, y: 1), animated: false)
                    }
                }
            }
        }
    }
}
