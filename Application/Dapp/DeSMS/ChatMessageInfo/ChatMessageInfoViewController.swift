import FunctionX
import WKKit
extension ChatMessageInfoViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let receiver = context["receiver"] as? SmsUser,
            let wallet = context["wallet"] as? FxWallet,
            let sms = context["sms"] as? SmsMessage else { return nil }
        return ChatMessageInfoViewController(receiver: receiver, wallet: wallet, sms: sms)
    }
}

class ChatMessageInfoViewController: WKTableViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(receiver: SmsUser, wallet: FxWallet, sms: SmsMessage) {
        self.sms = sms
        service = SmsServiceManager.service(forWallet: wallet)
        self.receiver = receiver
        super.init(nibName: nil, bundle: nil)
    }

    let sms: SmsMessage
    let service: SmsService
    let receiver: SmsUser
    fileprivate let items = NSMutableArray()
    override func viewModels() -> NSMutableArray? { return items }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        layoutUI()
        configuration()
        bind()
    }

    private func bind() {
        let message = sms.message
        var senderName = service.name
        var receiverName = receiver.name
        if message.fromAddress == receiver.address {
            senderName = receiver.name
            receiverName = service.name
        }
        items.push(Cell.self, m: CellViewModel(title: TR("From"), name: senderName, content: message.fromAddress, contentIsLink: true))
        items.push(Cell.self, m: CellViewModel(title: TR("To"), name: receiverName, content: message.toAddress, contentIsLink: true))
        items.push(Cell.self, m: CellViewModel(title: TR("Timestamp"), content: sms.GMTTime))
        items.push(Cell.self, m: CellViewModel(title: TR("MessageInfo.EncryptedMessage"), content: message.encryptedContent))
        items.push(Cell.self, m: CellViewModel(title: TR("MessageInfo.MessageHash"), content: sms.txHash, contentIsLink: true))
        items.push(Cell.self, m: CellViewModel(title: TR("Height"), content: String(sms.txHeight), contentIsLink: true))
        items.push(Cell.self, m: CellViewModel(title: TR("MessageInfo.MessageHash"), content: TR("Verified")))
        if let token = message.transferTokens.first {
            items.push(Cell.self, m: CellViewModel(title: TR("Amount"), content: "\(token.amount.thousandth()) \(token.denom.uppercased())"))
        }
        items.push(Cell.self, m: CellViewModel(title: TR("Fee"), content: "0 \(FxChain.sms.symbol.uppercased())"))
        items.push(Cell.self, m: CellViewModel(title: TR("Status"), content: TR("Success")))
        items.push(WKSpacingCell.self, m: WKSpacing(50, 0, .clear))
        navBar.rightButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: defaultBag)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath as IndexPath) as? Cell,
            let vm = cell.viewModel, vm.contentIsLink else { return }
        var path: ExplorerURL.Path?
        if vm.title == TR("MessageInfo.MessageHash") {
            path = .hash(vm.content.string)
        } else if vm.title == TR("Height") {
            path = .height(vm.content.string)
        } else if vm.title == TR("From") || vm.title == TR("To") {
            path = .address(vm.content.string)
        }
        if path != nil {
            Router.showExplorer(.sms, path: path)
        }
    }

    private func configuration() {
        view.backgroundColor = HDA(0x272727)
        tableView.backgroundColor = HDA(0x272727)
    }

    private func layoutUI() {
        navigationBar.isHidden = true
        let navBarHeight = navBar.height
        navBar.navigationArea.addSubview(navTitleLabel)
        view.addSubview(navBar)
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
        tableView.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
    }

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
        v.text = TR("MessageInfo.Title")
        v.font = XWallet.Font(ofSize: 16, weight: .bold)
        v.textColor = .white
        return v
    }()
}

private func newTextLabel(_ text: String) -> UILabel {
    let v = UILabel()
    v.text = text
    v.font = XWallet.Font(ofSize: 14, weight: .bold)
    v.textColor = UIColor.white
    v.backgroundColor = .clear
    return v
}

private func newTitleLabel(_ text: String) -> UILabel {
    let v = newTextLabel(text)
    v.textColor = UIColor.white.withAlphaComponent(0.5)
    return v
}

extension ChatMessageInfoViewController {
    fileprivate class CellViewModel {
        let name: String
        let title: String
        let content: NSAttributedString
        let height: CGFloat
        let contentIsLink: Bool
        init(title: String, name: String = "", content: String, contentIsLink: Bool = false) {
            self.name = name
            self.title = title
            self.contentIsLink = contentIsLink
            let font = XWallet.Font(ofSize: 14, weight: .bold)
            let nameHeight: CGFloat = name.isEmpty ? 0 : 33
            let contentHeight = content.height(ofWidth: ScreenWidth - 18 * 2, attributes: [.font: font])
            height = 32 + 10 + nameHeight + contentHeight + 1
            if !contentIsLink {
                self.content = NSAttributedString(string: content, attributes: [.font: font])
            } else {
                self.content = NSAttributedString(string: content, attributes: [.font: font, .foregroundColor: HDA(0x1A7CEB), .underlineStyle: NSUnderlineStyle.single.rawValue])
            }
        }
    }

    fileprivate class Cell: WKTableViewCell {
        fileprivate lazy var titleLabel: UILabel = newTitleLabel("--")
        fileprivate lazy var nameFxLabel: UILabel = newTitleLabel("--")
        fileprivate lazy var nameLabel: UILabel = {
            let v = newTextLabel("--")
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            return v
        }()

        fileprivate lazy var contentLabel: UILabel = {
            let v = newTextLabel("--")
            v.numberOfLines = 0
            return v
        }()

        override class func height(model: Any?) -> CGFloat {
            return (model as? CellViewModel)?.height ?? 74
        }

        fileprivate var viewModel: CellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            titleLabel.text = vm.title
            contentLabel.attributedText = vm.content
            let top = vm.name.isEmpty ? 4 : 10 + 29 + 2
            contentLabel.snp.updateConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(top)
            }
            nameLabel.isHidden = vm.name.isEmpty
            nameFxLabel.isHidden = vm.name.isEmpty
            nameLabel.text = vm.name
            nameFxLabel.text = "(\(vm.name).fx)"
        }

        override func initSubView() {
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            let padding = 18
            contentView.addSubviews([titleLabel, nameLabel, nameFxLabel, contentLabel])
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(27)
                make.left.equalTo(padding)
                make.height.equalTo(16)
            }
            let nameHeight = 29
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(6)
                make.left.equalTo(padding)
                make.height.equalTo(nameHeight)
            }
            nameFxLabel.snp.makeConstraints { make in
                make.bottom.equalTo(nameLabel)
                make.left.equalTo(nameLabel.snp.right).offset(10)
                make.height.equalTo(20)
            }
            contentLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10 + nameHeight + 2)
                make.left.right.equalToSuperview().inset(padding)
            }
        }
    }
}
