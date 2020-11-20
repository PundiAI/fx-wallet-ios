import WKKit
extension WKWrapper where Base == WalletConnectAuthorizeController {
    var view: Base.View { return base.view as! Base.View }
}

extension WalletConnectAuthorizeController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let dapp = context["dapp"] as? Dapp,
            let types = context["types"] as? [Int] else { return nil }
        let account = context["account"] as? Keypair
        let vc = WalletConnectAuthorizeController(dapp: dapp, authorizeTypes: types.map { AuthorizeCell.Types(rawValue: $0)! }, account: account)
        if let completionHandler = context["handler"] as? (UIViewController?, Bool) -> Void {
            vc.completionHandler = completionHandler
        }
        return vc
    }
}

class WalletConnectAuthorizeController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(dapp: Dapp, authorizeTypes: [AuthorizeCell.Types], account: Keypair? = nil) {
        self.dapp = dapp
        self.account = account
        self.authorizeTypes = authorizeTypes
        super.init(nibName: nil, bundle: nil)
    }

    let dapp: Dapp
    var completionHandler: ((UIViewController?, Bool) -> Void)?
    private var authorizeTypes: [AuthorizeCell.Types]
    private var account: Keypair?
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    override var interactivePopIsEnabled: Bool { false }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindListView()
        bindAction()
    }

    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.action(.title, title: "Wallet Connect")
        navigationBar.hideLine()
    }

    lazy var dappCell = DappInfoCell(DappInfoCellViewModel(dapp: dapp, authorizeTypes: authorizeTypes))
    func bindListView() {
        listBinder.push(dappCell, vm: dappCell.viewModel)
        if let account = account {
            listBinder.push(WCInfoCell.self, vm: WCInfoCellViewModel(title: TR("WalletConnect.TSelectAddress"), subtitle: account.address))
        }
    }

    private func bindAction() {
        weak var welf = self
        wk.view.cancelButton.action { welf?.dismiss(userCanceled: true) }
        wk.view.authButton.action { welf?.dismiss(userCanceled: false) }
    }

    override func onClickBack() { dismiss(userCanceled: true) }
    func dismiss(userCanceled: Bool = false, animated _: Bool = true, completion _: (() -> Void)? = nil) {
        if let handler = completionHandler {
            handler(self, !userCanceled)
        } else {
            Router.pop(self, animated: true, completion: nil)
        }
    }
}

extension WalletConnectAuthorizeController {
    class View: UIView {
        lazy var listView = WKTableView(frame: ScreenBounds, .white)
        lazy var authButton: UIButton = {
            let v = UIButton()
            v.title = TR("Authorize")
            v.bgImage = UIImage.createImageWithColor(color: COLOR.title)
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.autoCornerRadius = 28
            return v
        }()

        lazy var cancelButton: UIButton = {
            let v = UIButton()
            v.title = TR("Cancel")
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = COLOR.title
            v.backgroundColor = HDA(0xF0F3F5)
            v.autoCornerRadius = 28
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
            backgroundColor = .white
        }

        private func layoutUI() {
            addSubviews([listView, authButton, cancelButton])
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 16.auto()), .clear)
            listView.snp.makeConstraints { make in
                make.top.equalTo(FullNavBarHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(authButton.snp.top).offset(-16.auto())
            }
            cancelButton.snp.makeConstraints { make in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            authButton.snp.makeConstraints { make in
                make.bottom.equalTo(cancelButton.snp.top).offset(-16.auto())
                make.left.right.height.equalTo(cancelButton)
            }
        }
    }
}

extension WalletConnectAuthorizeController {
    class DappInfoCellViewModel {
        let dapp: Dapp
        let authorizeTypes: [AuthorizeCell.Types]
        var height: CGFloat = 0
        init(dapp: Dapp, authorizeTypes: [AuthorizeCell.Types]) {
            self.dapp = dapp
            self.authorizeTypes = authorizeTypes
            var contentHeight: CGFloat = (24 + 195).auto()
            if authorizeTypes.count > 0 {
                let titleHeight = TR("AuthorizeDapp.Tip").height(ofWidth: ScreenWidth - 48.auto() * 2, attributes: [.font: XWallet.Font(ofSize: 14)])
                var typesHeight: CGFloat = 0
                for t in authorizeTypes {
                    typesHeight += t.height
                }
                contentHeight += (titleHeight + typesHeight + 24.auto())
            }
            height = contentHeight
        }
    }

    class DappInfoCell: FxTableViewCell {
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        init(_ viewModel: DappInfoCellViewModel) {
            self.viewModel = viewModel
            super.init(style: .default, reuseIdentifier: "")
        }

        private lazy var view = WalletConnectDappView(size: CGSize(width: ScreenWidth - 24.auto(), height: 195.auto()))
        private lazy var typeTitleLabel = UILabel(text: TR("AuthorizeDapp.Tip"), font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 0)
        let viewModel: DappInfoCellViewModel
        override func bind(_: Any?) {
            view.bind(viewModel.dapp)
        }

        override class func height(model: Any?) -> CGFloat { (model as? DappInfoCellViewModel)?.height ?? 330.auto() }
        override func configuration() {
            super.configuration()
            backgroundColor = .white
            contentView.backgroundColor = .white
        }

        override func layoutUI() {
            contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 24, bottom: 0, right: 24).auto())
            }
            view.logoIV.isHidden = true
            view.linkIV.isHidden = true
            view.dappIV.snp.remakeConstraints { make in
                make.top.equalTo(40.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            if viewModel.authorizeTypes.count > 0 {
                view.addSubview(typeTitleLabel)
                typeTitleLabel.snp.makeConstraints { make in
                    make.top.equalTo(view.dappUrlLabel.snp.bottom).offset(32.auto())
                    make.left.right.equalToSuperview().inset(24.auto())
                }
                var topView: UIView = typeTitleLabel
                for t in viewModel.authorizeTypes {
                    let height = t.height
                    let cell = AuthorizeCell(size: CGSize(width: ScreenWidth - 24.auto() * 2, height: height))
                    cell.bind(t)
                    view.addSubview(cell)
                    cell.snp.makeConstraints { make in
                        make.top.equalTo(topView.snp.bottom)
                        make.left.right.equalToSuperview()
                        make.height.equalTo(height)
                    }
                    topView = cell
                }
            }
        }
    }
}

extension WalletConnectAuthorizeController {
    class AuthorizeCell: UIView {
        enum Types: Int {
            case wallet = 0
            case sign = 1
            var info: (text: String, img: String) {
                switch self {
                case .wallet: return (TR("AuthorizeDapp.AuthorityOfWallet"), "Dapp.Wallet")
                case .sign: return (TR("AuthorizeDapp.AuthorityOfSign"), "Dapp.Sign")
                }
            }

            var height: CGFloat {
                let textWidth = ScreenWidth - 48.auto() * 2 - (40 + 16).auto()
                let textHeight: CGFloat = max(20, info.text.height(ofWidth: textWidth, attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium)]))
                let containerHeight = textHeight + 16 * 2
                return containerHeight + 24.auto()
            }
        }

        lazy var containerView = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        lazy var iconIV = UIImageView(HDA(0x0552DC), cornerRadius: 4)
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, lines: 0)

        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        var type: Types = .wallet
        func bind(_ viewModel: Any?) {
            guard let type = viewModel as? Types else { return }
            self.type = type
            titleLabel.text = type.info.text
        }

        func configuration() {
            backgroundColor = .white
        }

        func layoutUI() {
            addSubview(containerView)
            containerView.addSubviews([iconIV, titleLabel])
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 24, bottom: 0, right: 24))
            }
            iconIV.snp.makeConstraints { make in
                make.top.equalTo(23.auto())
                make.left.equalTo(16.auto())
                make.size.equalTo(CGSize(width: 8, height: 8).auto())
            }
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(16)
                make.left.equalTo(iconIV.snp.right).offset(16)
                make.right.equalTo(-16)
            }
        }
    }
}
