
import RxCocoa
import RxSwift
import SwipeCellKit
import WKKit
extension WKWrapper where Base == NotificationListViewController {
    var view: NotificationListViewController.View { return base.view as! NotificationListViewController.View }
}

extension NotificationListViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet else { return nil }
        return NotificationListViewController(wallet: wallet)
    }
}

class NotificationListViewController: WKViewController {
    public static var minContentHeight: CGFloat = 140.auto()
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet) {
        self.wallet = wallet.wk
        super.init(nibName: nil, bundle: nil)
        configuration()
    }

    let wallet: WKWallet
    lazy var viewModel = ViewModel(wallet)
    fileprivate var listView: UICollectionView { wk.view.listView }
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }
    override func loadView() { view = View(foldLayout: NotificationFoldLayout(delegate: self), expandLayout: NotificationExpandLayout(delegate: self)) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bindFold()
        bindExpand()
        bindListView()
        bindNotifUpdate() fetchData()
        bindScroll()
    }

    func show(in superView: UIView) {
        superView.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(NotificationListViewController.minContentHeight)
        }
    }

    private func fetchData() {
        viewModel.refreshItems.execute()
    }

    override func bindNavBar() {
        navigationBar.isHidden = true
    }

    private func bindFold() {
        let view = wk.view
        weak var welf = self
        viewModel.itemCount
            .skip(1)
            .subscribe(onNext: { count in
                let fold = count == 0
                welf?.view.isHidden = fold
                welf?.view.isUserInteractionEnabled = !fold
                if fold { _ = view.fold() }
            }).disposed(by: defaultBag)
        view.headerView.foldButton.action { _ = view.fold() }
        view.headerView.closeButton.action { _ = welf?.viewModel.removeAll() }
        viewModel.itemCount.map { (count) -> Bool in
            count > 0
        }.bind(to: view.headerView.closeButton.rx.isEnabled)
            .disposed(by: defaultBag)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(fold))
        tapGR.delegate = self
        tapGR.numberOfTapsRequired = 1
        tapGR.numberOfTouchesRequired = 1
        listView.addGestureRecognizer(tapGR)
    }

    @objc private func fold(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: listView)
        guard listView.indexPathForItem(at: point) == nil else { return }
        _ = wk.view.fold()
    }

    private func bindExpand() {
        let view = wk.view
        wk.view.expandButton.action { _ = view.expand() }
    }

    private func bindNotifUpdate() {
        weak var welf = self

        wallet.notifManager.didReceive.subscribe(onNext: { notif in
            welf?.insert(notif)
        }).disposed(by: defaultBag)
        viewModel.didRemove.subscribe(onNext: { _, indexs in
            welf?.remove(indexs)
        }).disposed(by: defaultBag)
        viewModel.didUpdate.subscribe(onNext: { _, _ in
            welf?.listView.reloadData()
        }).disposed(by: defaultBag)
    }

    override func router(event: String, context: [String: Any]) {
        if event == "addToken",
            let cell = context[eventSender] as? TransactionCell,
            let coin = cell.viewModel?.coin
        {
            Router.showAddCoinAlert(coin: coin) { [weak self] allow in
                guard allow else { return }
                self?.viewModel.add(coin: coin)
                self?.wk.view.fold().done { _ in
                    self?.listView.reloadData()
                }
            }
        }
    }

    private func insert(_ item: FxNotification) {
        listView.performBatchUpdates({ [weak self] in
            self?.viewModel.insert(item)
            self?.listView.insertItems(at: [IndexPath(row: 0, section: 0)])
            self?.listView.insertItems(at: [IndexPath(row: 0, section: 1)])
        }, completion: { [weak self] _ in
            self?.viewModel.reloadData()
            self?.listView.reloadData()
            self?.listView.collectionViewLayout.invalidateLayout()
        })
    }

    private func remove(_ indexs: [IndexPath]) {
        if indexs.count == 0 {
            viewModel.reloadData()
            listView.reloadData()
            listView.collectionViewLayout.invalidateLayout()
        } else {
            listView.performBatchUpdates({
                self.listView.deleteItems(at: indexs)
            }, completion: { [weak self] _ in
                self?.viewModel.reloadData()
                self?.listView.reloadData()
                self?.listView.collectionViewLayout.invalidateLayout()
            })
        }
    }

    private func bindScroll() {
        let minDistance: CGFloat = 100.auto()
        let headView = wk.view.headerView
        let blurView = wk.view.blurView
        let initHeadTop = headView.top let scrollView = listView scrollView.rx.contentOffset.filter { [weak self] (_) -> Bool in
            scrollView.contentInset.top > 0
                && ((self?.wk.view.isAnimating ?? true) == false)
        }.subscribe(onNext: { point in
            if point.y >= -1 * minDistance {
                headView.top = (point.y - scrollView.contentInset.top) - (-1 * minDistance) scrollView.bringSubviewToFront(headView)
                headView.clipsToBounds = false
                headView.headerBlurView.isHidden = false
                blurView.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(minDistance)
                }
            } else {
                headView.top = initHeadTop
                headView.layer.zPosition = 0
                scrollView.sendSubviewToBack(headView)
                headView.clipsToBounds = true
                headView.headerBlurView.isHidden = true blurView.snp.updateConstraints { make in
                    make.top.equalToSuperview()
                }
            }
        }).disposed(by: defaultBag)
    }
}

extension NotificationListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: wk.view.listView)
        return wk.view.listView.indexPathForItem(at: point) == nil
    }
}

extension NotificationListViewController: UICollectionViewDelegate, UICollectionViewDataSource, NotificationLayoutDelegate {
    private func bindListView() {
        listView.register(FoldCell.self, forCellWithReuseIdentifier: FoldCell.description())
        listView.register(ExpandCell.self, forCellWithReuseIdentifier: ExpandCell.description())
        listView.register(TransactionCell.self, forCellWithReuseIdentifier: TransactionCell.description())
        listView.delegate = self
        listView.dataSource = self
        viewModel.refreshItems.elements.subscribe(onNext: { [weak self] _ in
            self?.viewModel.reloadData()
            self?.listView.reloadData()
        }).disposed(by: defaultBag)
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return viewModel.foldItems.count }
        return viewModel.items.count
    }

    func itemSize(layout: UICollectionViewLayout, indexPath: IndexPath) -> CGSize {
        if layout is NotificationExpandLayout {
            return viewModel.items.get(indexPath.row)?.size ?? .zero
        } else {
            return CGSize(width: ScreenBounds.width,
                          height: NotificationListViewController.minContentHeight - 20.0.auto())
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = indexPath.section == 0 ? viewModel.foldItems : viewModel.items
        guard let cellVM = items.get(indexPath.row) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ExpandCell.description(), for: indexPath)
        }
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoldCell.description(), for: indexPath) as! FoldCell
            cell.textLabel.text = viewModel.foldItems[indexPath.row].rawValue.message
            cell.alertNumRelay.accept(viewModel.itemCount.value)
            return cell
        } else {
            let cell: ExpandCell
            if cellVM.rawValue.coin == nil {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExpandCell.description(), for: indexPath) as! ExpandCell
            } else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: TransactionCell.description(), for: indexPath) as! TransactionCell
            }
            cell.bind(cellVM)
            cell.delegate = self
            return cell
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1, let item = viewModel.items.get(indexPath.row) {
            if item.rawValue.url.isNotEmpty {
                viewModel.remove(at: indexPath)
                DispatchQueue.main.async {
                    Router.showWebViewController(url: item.rawValue.url) { [weak self] _ in
                        self?.wk.view.fold()
                    }
                }
            }
        }
    }
}

extension NotificationListViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let item = viewModel.items[indexPath.row]
        if item.rawValue.mustKnown || orientation == .left { return nil }
        let trash = SwipeAction(style: .destructive, title: nil) { [weak self] _, indexPath in
            self?.viewModel.remove(at: indexPath)
        }
        trash.image = IMG("ic_not_trashB")
        trash.backgroundColor = .clear
        trash.highlightedBackgroundColor = .clear
        trash.hidesWhenSelected = true
        trash.transitionDelegate = ScaleTransition.default
        return [trash]
    }

    func collectionView(_: UICollectionView, editActionsOptionsForItemAt _: IndexPath, for _: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .reveal
        options.backgroundColor = UIColor.clear
        return options
    }
}

extension NotificationListViewController {
    private func configuration() {
        modalPresentationStyle = .overCurrentContext
        extendedLayoutIncludesOpaqueBars = false
        modalPresentationCapturesStatusBarAppearance = true
    }
}
