
import WKKit
extension SendTokenCommitViewController {
    class View: UIView {
        lazy var backgroundView = UIView(HDA(0x080A32), cornerRadius: 36).then { $0.autoCornerRadius = 36 }
        var headerHeight: CGFloat { 277.auto() + StatusBarHeight }
        lazy var header: UIView = {
            let v = UIView(.white)
            v.size = CGSize(width: ScreenWidth, height: headerHeight)
            v.addCorner([.bottomLeft, .bottomRight], radius: 36.auto())
            return v
        }()

        lazy var headerContentView: UIView = {
            let v = UIView(.clear)
            return v
        }()

        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.standard()
            v.titleLabel.text = TR("Recipient")
            v.titleLabel.font = XWallet.Font(ofSize: 18)
            return v
        }()

        lazy var titleLabel = UILabel(text: TR("SendToken.Commit.Title"),
                                      font: XWallet.Font(ofSize: 24, weight: .bold),
                                      textColor: HDA(0x080A32)).then { $0.autoFont = true }
        fileprivate lazy var inputBackgroud: UIView = {
            let v = UIView(size: CGSize(width: ScreenWidth, height: 56.auto()))
            v.backgroundColor = HDA(0xF0F3F5).withAlphaComponent(0.5)
            v.autoCornerRadius = 28
            v.borderColor = .clear
            v.borderWidth = 2
            return v
        }()

        lazy var inputTF: UITextField = {
            let v = UITextField()
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = HDA(0x080A32)
            v.tintColor = HDA(0x0552DC)
            v.attributedPlaceholder = NSAttributedString(string: TR("SendToken.Commit.Placeholder"),
                                                         attributes: [.font: XWallet.Font(ofSize: 16), .foregroundColor: HDA(0x080A32).withAlphaComponent(0.5)])
            v.keyboardType = .emailAddress
            v.backgroundColor = .clear
            v.autoFont = true
            return v
        }()

        lazy var scanButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Menu.Scan")
            v.contentHorizontalAlignment = .right
            return v
        }()

        lazy var nextButton: UIButton = {
            let v = UIButton() v.title = TR("Next")
            v.bgImage = UIImage.createImageWithColor(color: HDA(0x080A32))
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.disabledBGImage = UIImage.createImageWithColor(color: HDA(0xF0F3F5).withAlphaComponent(0.5))
            v.disabledTitleColor = HDA(0x080A32).withAlphaComponent(0.2)
            v.autoCornerRadius = 28
            v.titleLabel?.autoFont = true
            return v
        }()

        lazy var mainListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = UIColor.clear
            return v
        }()

        lazy var searchListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = .white
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
            backgroundColor = UIColor.clear searchListView.isHidden = true
        }

        var isEditing: Bool = false {
            didSet {
                inputBackgroud.borderColor = isEditing ? HDA(0x0552DC) : .clear
            }
        }

        func showInputError() {
            inputBackgroud.borderColor = HDA(0xFA6237)
        }

        private func layoutUI() {
            addSubviews([backgroundView, mainListView, header, headerContentView, searchListView])
            headerContentView.addSubviews([navBar, titleLabel, inputBackgroud, inputTF, scanButton, nextButton])
            backgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            header.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(headerHeight)
            }
            headerContentView.snp.makeConstraints { make in
                make.edges.equalTo(header)
            }
            navBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(navBar.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(30.auto())
            }
            inputBackgroud.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            inputTF.snp.makeConstraints { make in
                make.edges.equalTo(inputBackgroud).inset(UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 60).auto())
            }
            scanButton.snp.makeConstraints { make in
                make.centerY.equalTo(inputBackgroud)
                make.right.equalTo(inputBackgroud).offset(-24.auto())
                make.size.equalTo(CGSize(width: 30, height: 30).auto())
            }
            nextButton.snp.makeConstraints { make in
                make.top.equalTo(inputBackgroud.snp.bottom).offset(32.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }

            mainListView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: headerHeight), UIColor.clear)
            mainListView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            searchListView.snp.makeConstraints { make in
                make.top.equalTo(FullNavBarHeight + (30 + 8).auto() + (32 + 56).auto())
                make.bottom.left.right.equalToSuperview()
            }
        }
    }
}

extension SendTokenCommitViewController {
    class SectionView: UIView {
        let titleLabel = UILabel(font: XWallet.Font(ofSize: 24, weight: .bold)).then { $0.autoFont = true }
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        init(frame: CGRect, text: String) {
            super.init(frame: frame)
            backgroundColor = COLOR.title
            addSubview(titleLabel)
            titleLabel.text = text
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.centerY.equalToSuperview()
            }
        }
    }
}
