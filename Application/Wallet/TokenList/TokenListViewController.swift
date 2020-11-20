
import AudioToolbox
import HapticGenerator
import Hero
import MJRefresh
import pop
import RxCocoa
import RxSwift
import RxViewController
import SwiftyJSON
import TrustWalletCore
import WKKit
extension WKWrapper where Base == TokenListViewController {
    var view: TokenListViewController.View { return base.view as! TokenListViewController.View }
    var navigationBar: TokenListViewController.TokenNavigationBar { return base.navigationBar as! TokenListViewController.TokenNavigationBar }
}

extension TokenListViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet else { return nil }
        return TokenListViewController(wallet: wallet)
    }
}

class TokenListViewController: WKViewController { @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet) {
        self.wallet = wallet.wk
        super.init(nibName: nil, bundle: nil)
    }

    let wallet: WKWallet
    fileprivate lazy var viewModel = ViewModel(wallet)
    override var preferFullTransparentNavBar: Bool { return true }
    override func getNavigationBar() -> WKNavigationBar {
        return TokenNavigationBar().then {
            $0.theme = WKNavBarTheme(barTint: .clear, backTint: .white, titleColor: HDA(0x080A32))
            $0.backgroundBlurView.alpha = 0
        }
    } override func navigationItems(_: WKNavigationBar) { bindNavBar() }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bindAction()
        bindListView()
        bindMoveCell()
        bindSettings()
        bindScroll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    private func bindAction() {
        weak var welf = self
        wk.view.addWalletButton.action { welf?.onClickAddWallet() }
        wk.navigationBar.settingsButton.action {
            Router.pushToSettings()
        }
        wallet.event.isBackuped.subscribe(onNext: { value in
            let image = value ? IMG("Wallet.Settings") : IMG("Wallet.NeedBackUp")
            welf?.wk.navigationBar.settingsButton.setImage(image, for: .normal)
            welf?.wk.navigationBar.settingsButton.tintColor = value ? .white : .clear
        }).disposed(by: defaultBag)
        if CoinService.current.needSync {
            CoinService.current.sync()
        }
    }

    private func bindListView() {
        weak var welf = self
        let listView = wk.view.listView
        let listViewModel = viewModel
        listViewModel.refreshItems.elements.subscribe(onNext: { _ in
            listView.mj_header?.endRefreshing()
            listView.reloadData()
        }).disposed(by: defaultBag)
        wk.view.amountLabel.wk.set(amount: listViewModel.legalBalance.value, mb: true, animated: false)
        listViewModel.legalBalance
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { welf?.wk.view.amountLabel.wk.set(amount: $0, mb: true) })
            .disposed(by: defaultBag)
        listView.viewModels = { _ in NSMutableArray.viewModels(from: listViewModel.items, Cell.self) }
        listView.didSeletedBlock = { tableView, indexPath in
            guard let this = welf else { return }
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? Cell {
                let cellVM = listViewModel.items[indexPath.row]
                (this.animators["0"] as? TokenRootViewController.InfoAnimator)?.cell = cell
                Router.pushTokenInfo(wallet: cellVM.wallet, coin: cellVM.coin)
            }
        }
    }

    private func bindSettings() {
        wk.view.nameLabel.text = "@ \(wallet.nickName ?? "")"
    }

    private func onClickAddWallet() {
        Router.pushToAddToken(wallet: wallet)
    }

    private func fetchData() {
        viewModel.refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.height = ScreenHeight
    }
}

extension TokenListViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    private func bindMoveCell() {
        let listView = wk.view.listView
        listView.dragInteractionEnabled = true
        listView.moveRow = { [weak self] from, to in
            self?.viewModel.exchangeItem(from: from.row, to: to.row)
            listView.reloadData()
            listView.inactiveAWhile(1)
        }
        viewModel.refreshItems.elements.subscribe(onNext: { [weak self] items in
            let enabled = items.count > 1
            listView.dropDelegate = enabled ? self : nil
            listView.dragDelegate = enabled ? self : nil
        }).disposed(by: defaultBag)
    }

    func tableView(_: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func tableView(_: UITableView, dropSessionDidUpdate _: UIDropSession, withDestinationIndexPath _: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters(at: indexPath)
    }

    func tableView(_: UITableView, itemsForBeginning _: UIDragSession, at _: IndexPath) -> [UIDragItem] {
        Haptic.impactMedium.generate()
        return [UIDragItem(itemProvider: NSItemProvider(object: NSString()))]
    }

    func tableView(_: UITableView, performDropWith _: UITableViewDropCoordinator) {}

    func tableView(_: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters(at: indexPath)
    }

    private func previewParameters(at _: IndexPath) -> UIDragPreviewParameters {
        let param = UIDragPreviewParameters()
        param.visiblePath = UIBezierPath(roundedRect: CGRect(x: 16, y: 0,
                                                             width: ScreenWidth - 16 * 2,
                                                             height: Cell.height(model: nil)), cornerRadius: 16)
        return param
    }
}

extension TokenListViewController {
    private func applyTransform(view: UIView, withScale scale: CGFloat, anchorPoint: CGPoint) {
        view.layer.anchorPoint = anchorPoint
        var scale = scale != 0 ? scale : CGFloat.leastNonzeroMagnitude
        scale = floor(scale * 100) / 100
        let xPadding = 1 / scale * (anchorPoint.x - 0.5) * view.bounds.width
        let yPadding = 1 / scale * (anchorPoint.y - 0.5) * view.bounds.height
        view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).translatedBy(x: CGFloat(xPadding), y: CGFloat(yPadding))
    }

    private func bindScroll() {
        let viewSize = wk.view.bounds.size
        let listHeaderHeight = wk.view.listHeaderView.height
        wk.view.listView.rx.contentOffset
            .asObservable().subscribe(onNext: { [weak self] point in
                let offsetY = listHeaderHeight - 16.auto()
                self?.wk.view.bgroundView.frame = CGRect(x: 0, y: offsetY - point.y, width: viewSize.width, height: viewSize.height - offsetY + point.y + 200)
                DispatchQueue.main.async { self?.scrollProgress(offset: point)
                }
            }).disposed(by: defaultBag)
        wk.view.amountLabel.rx
            .observe(String.self, "text")
            .bind(to: wk.navigationBar.amountLabel.rx.text)
            .disposed(by: wk.view.amountLabel.defaultBag)
        wk.view.listView.rx.observe(UIEdgeInsets.self, "contentInset")
            .distinctUntilChanged()
            .filterNil()
            .subscribe(onNext: { [weak self] inset in
                let height = UIApplication.shared.statusBarFrame.height + 56 + inset.top
                self?.navigationBar.snp.updateConstraints { make in make.height.equalTo(height)
                }
                let offset: CGPoint = self?.wk.view.listView.contentOffset ?? .zero
                self?.scrollProgress(offset: offset)
            }).disposed(by: defaultBag)
        scrollProgress(offset: CGPoint(x: 0, y: 1))
    }

    private func scrollProgress(offset _: CGPoint) {
        if wk.view.amountLabel.width > 0,
            wk.view.amountLabel.height > 0, wk.navigationBar.bottom > 0
        {
            let idistance: CGFloat = 36
            let minSacel: CGFloat = 0.5
            let iAlpha: CGFloat = minSacel + 0.1
            let rect = wk.view.listHeaderView.convert(wk.view.amountLabel.frame, to: view)
            let toRect = wk.view.convert(rect, to: navigationBar) if toRect.maxY < wk.navigationBar.titleLabel.bottom {
                wk.view.amountLabel.alpha = 0
                wk.navigationBar.amountLabel.alpha = 1
                wk.navigationBar.amountLabel.frame = CGRect(origin: CGPoint(x: toRect.origin.x,
                                                                            y: wk.navigationBar.titleLabel.bottom - toRect.height), size: toRect.size)
            } else {
                wk.view.amountLabel.alpha = 1
                wk.navigationBar.amountLabel.frame = toRect
                wk.navigationBar.amountLabel.alpha = 0
            }
            let referRect = wk.view.listHeaderView.convert(wk.view.nameLabel.frame, to: view)
            let referOffsetY: CGFloat = wk.view.amountLabelHeight * minSacel + 4.auto()
            let referDistance = referRect.minY - wk.navigationBar.bottom - referOffsetY
            if referDistance >= 0 {
                let scale: CGFloat = referDistance >= idistance ? 1 : min((1 - minSacel) + (referDistance * minSacel / idistance), 1.02)
                applyTransform(view: wk.view.amountLabel, withScale: scale, anchorPoint: CGPoint(x: 0, y: 1))
                applyTransform(view: wk.navigationBar.amountLabel, withScale: scale, anchorPoint: CGPoint(x: 0, y: 1))
                let alpha = scale <= iAlpha ? min((iAlpha - scale) / (iAlpha - minSacel), 1) : 0
                wk.navigationBar.backgroundBlurView.alpha = 1
                wk.navigationBar.titleLabel.alpha = 1 - alpha
                wk.view.nameLabel.alpha = 1 - alpha
                wk.navigationBar.amountLabel.alpha = 0
                wk.navigationBar.titleLabel.snp.updateConstraints { make in
                    make.bottom.equalToSuperview()
                }
            } else {
                applyTransform(view: wk.view.amountLabel, withScale: minSacel, anchorPoint: CGPoint(x: 0, y: 1))
                applyTransform(view: wk.navigationBar.amountLabel, withScale: minSacel, anchorPoint: CGPoint(x: 0, y: 1))
                wk.navigationBar.backgroundBlurView.alpha = 1
                wk.navigationBar.titleLabel.alpha = 0
                wk.navigationBar.amountLabel.alpha = 1
                wk.view.nameLabel.alpha = 0 if (rect.origin.y + rect.height) <= wk.navigationBar.bottom {
                    let distance0 = wk.navigationBar.bottom - (rect.origin.y + rect.height)
                    wk.navigationBar.titleLabel.snp.updateConstraints { make in
                        make.bottom.equalToSuperview().inset(min(16, distance0))
                    }
                } else {
                    wk.navigationBar.titleLabel.snp.updateConstraints { make in
                        make.bottom.equalToSuperview()
                    }
                }
            }
        }
    }
}
