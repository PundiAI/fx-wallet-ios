import WKKit
extension SelectOrAddAccountViewController {
    class View: UIView {
        lazy var aBackgroundView = UIView(UIColor.white)
        lazy var blurContainer = UIView(UIColor.white.withAlphaComponent(0.68))
        lazy var headerBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.standard()
            v.backButton.image = IMG("Menu.Close")
            return v
        }()

        var closeButton: UIButton { navBar.backButton }
        lazy var titleLabel = UILabel(text: TR("Receive"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: HDA(0x080A32))
        lazy var subtitleLabel = UILabel(text: TR("SelectAccount.Title"), font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5))
        lazy var titleAnimator: ScrollScaleAnimator = {
            let v = ScrollScaleAnimator(offset: FullNavBarHeight)
            let s: CGFloat = 0.75
            v.add(PanScaleAnimator(view: titleLabel, endY: StatusBarHeight + (NavBarHeight - titleLabel.height * s) * 0.5 - 4, scale: s))
            v.add(PanScaleAnimator(view: subtitleLabel, endY: StatusBarHeight + (NavBarHeight - subtitleLabel.height * s) * 0.5 + 12, scale: s))
            return v
        }()

        lazy var switchView = UIView(HDA(0xE7E8EB), cornerRadius: 28)
        lazy var switchIndicator = UIView(.white, cornerRadius: 24)
        lazy var switchToMyAssets: UIButton = {
            let v = UIButton(.clear)
            v.titleColor = HDA(0x080A32)
            v.setAttributedTitle(NSAttributedString(string: TR("SelectOrAddAccount.MyAssets"), attributes: [.font: XWallet.Font(ofSize: 16)]), for: .normal)
            v.setAttributedTitle(NSAttributedString(string: TR("SelectOrAddAccount.MyAssets"), attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium)]), for: .selected)
            return v
        }()

        lazy var switchToAll: UIButton = {
            let v = UIButton(.clear)
            v.titleColor = HDA(0x080A32)
            v.setAttributedTitle(NSAttributedString(string: TR("SelectOrAddAccount.AllAvailable"), attributes: [.font: XWallet.Font(ofSize: 16)]), for: .normal)
            v.setAttributedTitle(NSAttributedString(string: TR("SelectOrAddAccount.AllAvailable"), attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium)]), for: .selected)
            return v
        }()

        lazy var contentView: UIScrollView = {
            let v = UIScrollView(.clear)
            v.contentSize = CGSize(width: ScreenWidth * 2, height: 0)
            v.isScrollEnabled = false
            return v
        }()

        lazy var leftListView: UITableView = {
            let v = UITableView(frame: ScreenBounds, style: .grouped)
            v.separatorStyle = .none
            v.backgroundColor = .clear
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            v.contentInsetAdjustmentBehavior = .never
            v.estimatedRowHeight = 0
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionHeaderHeight = 0
            return v
        }()

        lazy var rightListTitleView: UIView = {
            let v = UIView(HDA(0x080A32))
            v.addCorner([.topLeft, .topRight], size: CGSize(width: ScreenWidth - 24.auto() * 2, height: 40.auto()))
            return v
        }()

        lazy var rightListTitleLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium))
        lazy var searchView = AddCoinListHeaderView(size: CGSize(width: ScreenWidth, height: 44 + 24))
        lazy var rightListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .grouped)
            v.backgroundColor = HDA(0xF0F3F5)
            v.estimatedRowHeight = 0
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionHeaderHeight = 0
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
            addSubviews([aBackgroundView, contentView, blurContainer, navBar, titleLabel, subtitleLabel])
            switchView.addSubviews([switchIndicator, switchToMyAssets, switchToAll])
            blurContainer.addSubviews([headerBlur, switchView])
            wk.addLineShadow(below: blurContainer)
            contentView.addSubviews([leftListView, rightListTitleView, rightListTitleLabel, rightListView])
            aBackgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            navBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }

            let switchHeight: CGFloat = 56.auto()
            let reducedHeaderHeight = FullNavBarHeight + (switchHeight + 12.auto())
            let normalHeaderHeight = FullNavBarHeight + reducedHeaderHeight
            blurContainer.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: normalHeaderHeight)
            let titleContainerH: CGFloat = (32 + 22).auto()
            titleLabel.wk.adjust(frame: CGRect(x: 24.auto(), y: (normalHeaderHeight - titleContainerH) * 0.5, width: 0, height: 32.auto()))
            subtitleLabel.wk.adjust(frame: CGRect(x: 24.auto(), y: titleLabel.frame.maxY, width: 0, height: 22.auto()))
            headerBlur.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            switchView.snp.makeConstraints { make in
                make.bottom.equalTo(-12.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(switchHeight)
            }
            let switchWidth = (ScreenWidth - 24.auto() * 2) * 0.5
            switchToMyAssets.snp.makeConstraints { make in
                make.top.bottom.left.equalToSuperview()
                make.width.equalTo(switchWidth)
            }
            switchToAll.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(switchWidth)
            }
            switchIndicator.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(4)
                make.left.equalTo(4)
                make.width.equalTo(switchWidth - 4 * 2)
            }

            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            leftListView.frame = CGRect(x: 24.auto(), y: 0, width: ScreenWidth - 24.auto() * 2, height: ScreenHeight)
            leftListView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: normalHeaderHeight), .clear)
            rightListTitleView.frame = CGRect(x: ScreenWidth + 24.auto(), y: reducedHeaderHeight, width: ScreenWidth - 24 * 2.auto(), height: 40.auto())
            rightListTitleLabel.snp.makeConstraints { make in
                make.left.equalTo(rightListTitleView).offset(16.auto())
                make.centerY.equalTo(rightListTitleView)
            }
            rightListView.frame = CGRect(x: ScreenWidth + 24.auto(), y: rightListTitleView.frame.maxY, width: ScreenWidth - 24.auto() * 2, height: ScreenHeight - rightListTitleView.frame.maxY)
            rightListView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.1), .clear)
            rightListView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 20), .clear)
        }
    }
}
