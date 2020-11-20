//
//  AuthorizeDappAlertController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/26.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension AuthorizeDappAlertController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let dapp = context["dapp"] as? Dapp else { return nil }

        let vc = AuthorizeDappAlertController(dapp: dapp)
        if let completionHandler = context["handler"] as? (UIViewController?, Bool) -> Void {
            vc.completionHandler = completionHandler
        }
        if let authorityTypes = context["authorityTypes"] as? [Int] {
            vc.authorityTypes = authorityTypes.map { AuthorityCell.AuthorityType(rawValue: $0)! }
        }
        return vc
    }
}

class AuthorizeDappAlertController: WKPopViewController {
    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(dapp: Dapp) {
        self.dapp = dapp
        super.init(nibName: nil, bundle: nil)
    }

    let dapp: Dapp
    var completionHandler: ((UIViewController?, Bool) -> Void)?
    private var authorityTypes: [AuthorityCell.AuthorityType] = []
    lazy var listView = WKTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 8 * 2, height: 488), style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()

        layoutUI()
        configuration()
        logWhenDeinit()

        view.layoutIfNeeded()
    }

    private func bind() {
        listView.viewModels = { [weak self] section in
            guard let this = self else { return section }

            section.push(DappInfoCell.self) { this.bindDapp($0) }
            for type in this.authorityTypes {
                section.push(AuthorityCell.self, m: type) { $0.type = type }
            }
            section.push(ActionCell.self) { this.bindAction($0) }
            return section
        }
    }

    private func bindDapp(_ cell: DappInfoCell) {
        cell.iconIV.setImage(urlString: dapp.icon, placeHolderImage: dapp.placeholderIcon)
        cell.nameLabel.text = dapp.name
        cell.closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.complete(false)
        }).disposed(by: cell.reuseBag)
    }

    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.denyButton.rx.tap.subscribe(onNext: { _ in
            welf?.complete(false)
        }).disposed(by: cell.reuseBag)

        cell.allowButton.rx.tap.subscribe(onNext: { _ in
            welf?.complete(true)
        }).disposed(by: cell.reuseBag)
    }

    private func complete(_ allow: Bool) {
        if let handler = completionHandler {
            handler(self, allow)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: Utils

    private func configuration() {
        transitioning.alertType = .sheet
        transitioningDelegate = transitioning
        listView.isScrollEnabled = false
        listView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundView.isUserInteractionEnabled = false
    }

    private func layoutUI() {
        backgroundView.gradientBGLayerForPop.frame = ScreenBounds

        let height = WKMTableView.contentHeight(section: listView._vModels)
        let tableViewBounds = CGRect(x: 0, y: 0, width: ScreenWidth - 8 * 2, height: height)
        contentView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(height)
        }

        let shadow = shadowView()
        let listContainer = UIView(COLOR.BACKGROUND)
        listContainer.frame = tableViewBounds
        listContainer.addCorner()
        listContainer.gradientBGLayerForTip.frame = tableViewBounds

        listContainer.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.layer.masksToBounds = false
        contentView.addSubviews([shadow, listContainer])

        shadow.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.left.right.equalToSuperview().inset(4)
            make.height.equalTo(16)
        }

        listContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func shadowView() -> UIView {
        let v = UIView(HDA(0xC91F1F))
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.4
        v.layer.shadowOffset = CGSize(width: 0, height: -10)
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.cornerRadius = 8
        return v
    }
}
