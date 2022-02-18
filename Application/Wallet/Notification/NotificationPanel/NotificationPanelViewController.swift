

import WKKit
import RxSwift
import RxCocoa
import SwipeCellKit
import XChains
import SwiftyJSON

extension WKWrapper where Base == NotificationPanelViewController {
    var view: NotificationPanelViewController.View { return base.view as! NotificationPanelViewController.View }
}

extension NotificationPanelViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        return NotificationPanelViewController(wallet: wallet)
    }
}

class NotificationPanelViewController: WKViewController {
    var actionDag:DisposeBag = DisposeBag()
    public static var minContentHeight:CGFloat = (100 + 22.ifull(44)).auto()
    public static var minFoldContentHeight:CGFloat = (82 + 22.ifull(44)).auto()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        self.configuration()
    }
    
    let wallet: WKWallet
    lazy var viewModel = ViewModel(wallet, listView)
    fileprivate var listView: UICollectionView { wk.view.listView }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }
    override func loadView() { view = View(foldLayout: NotificationFoldLayout(delegate: self),
                                           expandLayout: NotificationExpandLayout(delegate: self),
                                           hideLayout: NotificationHideLayout(delegate: self)) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindFold()
        bindExpand()
        bindListView()
        bindNotifUpdate() 
        fetchData()
        bindScroll() 
    }
     
    func show(in superView:UIView) {
        superView.addSubview(self.view)
        self.view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func fetchData() {
        viewModel.refreshItems.execute((false, self.viewModel.layoutType)).subscribe(onNext: { [weak self]_ in
            self?.viewModel.reloadData()
            self?.wk.view.listView.reloadData()
        }).disposed(by: defaultBag)
    }
    
    override func bindNavBar() {
        navigationBar.isHidden = true
    }
    
    private func bindFold() {
        
        let view = wk.view
        weak var welf = self
        viewModel.itemCount
            .skip(1)
            .subscribe(onNext: {(count, layout) in
                if layout == LayoutType.expand && count == 0 {
                    welf?.view.isHidden = false
                    welf?.view.isUserInteractionEnabled = true
                }else {
                    let fold = count == 0
                    welf?.view.isHidden = fold
                    welf?.view.isUserInteractionEnabled = !fold
                    if fold { _ = view.fold() }
                }
        }).disposed(by: defaultBag)
         
        view.headerView.foldButton.rx
            .tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
            .subscribe( onNext: { (_) in
                welf?.toHideAction()
            }).disposed(by: defaultBag) 
    }
    
    private func toHideAction() {
        let vModel = self.viewModel
        let view = wk.view
        wk.view.hide().flatMap { () -> Observable<[CellViewModel]> in
            return vModel.markAllRead.execute((false, .hide))
        }.flatMap { (_) -> Observable<Void> in
            return view.fold(animated: false)
        }.subscribe().disposed(by: defaultBag)
    }
    
    func toExpandAction() {
        let view = wk.view
        let value = viewModel.itemCount.value 
        viewModel.refreshItems.execute((true, .expand))
            .flatMap { (_) -> Observable<Void> in
                if value.0 != 0 && value.1 != .hide { view.listView.reloadData() }
                return view.expand()
            }
         .subscribe().disposed(by: defaultBag)
    }
    
    private func bindExpand() { 
        weak var welf = self
        wk.view.expandButton.rx
            .tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
            .subscribe( onNext: { (_) in
                welf?.toExpandAction()
            }).disposed(by: defaultBag)
    }
    
    private func bindNotifUpdate() { 
        weak var welf = self
        
        wallet.notifManager
            .didReceive
            .throttle(.milliseconds(300), scheduler:MainScheduler.instance)
            .subscribe(onNext: { (notif) in
                welf?.insert(notif)
        }).disposed(by: defaultBag)
        
        viewModel.didRemove.subscribe(onNext: { (model) in
            welf?.remove(model.indexPath, model.update, model.complated)
        }).disposed(by: defaultBag)
        
        viewModel.didUpdate.subscribe(onNext: { (_) in
            welf?.listView.reloadData()
        }).disposed(by: defaultBag)
        
        wallet.event.isBackuped.subscribe(onNext:  {(value) in
            welf?.fetchData()
        }).disposed(by: defaultBag)
        
        viewModel.wallet.notifManager.updateRaw.subscribe(onNext: { (_) in
            welf?.fetchData()
        }).disposed(by: defaultBag)
    }
 
    private func tokenMetadata(_ coin:Coin, _ waitting:()->Void) -> Observable<Coin> {
        guard coin.isOther, coin.isERC20, coin.contract.isNotEmpty else {
            return Observable.just(coin)
        }
        
        waitting()
        let n = NodeManager.shared.currentEthereumNode
        let node = ERC20Node(endpoint: n.url, chainId: n.chainId.i, contract: coin.contract)
        return Observable.combineLatest(node.name(), node.decimals())
            .map { (name, decimals) -> Coin in
                coin.update(name: name, decimals: Int(decimals))
                return coin
            }
    }
    
    override func router(event: String, context: [String : Any]) {
        weak var welf = self
        let wallet  = self.wallet
        if event == "addToken",
            let cell = context[eventSender] as? TransactionAddTokenCell,
            let fxNotification = cell.viewModel?.rawValue,
            let coin = cell.viewModel?.coin {
            let hub = Router.topViewController?.hud
            self.tokenMetadata(coin, {
                hub?.waiting()
            })
            .observeOn(MainScheduler.instance)
            .subscribe {  (_coin) in
                Router.showAddCoinAlert(coin: _coin) {(allow) in
                    guard allow else {
                        hub?.hide()
                        return
                    }
                    
                    var account: Keypair?
                    for c in wallet.coins {
                        guard c.chainType == _coin.chainType else { continue }
                        for keypair in wallet.accountManager.accounts(forCoin: c).accounts {
                            if keypair.address.lowercased() == fxNotification.address.lowercased() {
                                account = keypair
                                break
                            }
                        }
                    }
                    
                    welf?.viewModel.add(coin: _coin)
                    
                    if let account = account {
                        wallet.accountManager.accounts(forCoin: _coin).add(account)
                    }
                    
                    welf?.foldAndHaveRead(cid: _coin.id)
                    hub?.hide()
                }
            } onError: { (error) in
                hub?.hide(animated: false)
                hub?.error(m: TR("Notif.AddToken.Error$", coin.symbol))
            }.disposed(by: defaultBag)
        }
        
        if event == "Help" {
            Router.showRevWebViewController(url: ThisAPP.WebURL.helpTxFailURL)
        }
    }
     
    //MARK: Animations
    private func insert(_ item: FxNotification, _ complated:(()->Void)? = nil) {
        self.listView.performBatchUpdates ({ [weak self] in
            self?.viewModel.insert(item, self?.viewModel.layoutType ?? .fold)
            self?.listView.insertItems(at: [IndexPath(row: 0, section: 0)])
            self?.listView.insertItems(at: [IndexPath(row: 0, section: 1)])
        }, completion: {[weak self] (_) in
            self?.viewModel.reloadData()
            self?.listView.reloadData()
            self?.listView.collectionViewLayout.invalidateLayout()
            complated?()
        })
    }
    
    private func remove(_ indexs: [IndexPath], _ update:(()->Void)? = nil, _ complate:(()->Void)? = nil) { 
        DispatchQueue.main.async { [weak self] in
            if indexs.count == 0 {
                update?()
                self?.viewModel.reloadData()
                self?.listView.reloadData()
                self?.listView.collectionViewLayout.invalidateLayout()
                complate?()
            } else {
                self?.listView.performBatchUpdates({
                    update?()
                    self?.listView.deleteItems(at: indexs)
                }, completion: { _ in
                    self?.viewModel.reloadData()
                    self?.listView.reloadData()
                    self?.listView.collectionViewLayout.invalidateLayout()
                    complate?()
                })
            }
        }
    }
     
    private func bindScroll() {
        let minDistance:CGFloat = wk.view.headHeight - 100.auto()
        let headView = wk.view.headerView
        let scrollView = listView
 
        scrollView.rx.contentOffset 
            .filter { (_) -> Bool in
            return scrollView.contentInset.top > 0
        }.subscribe(onNext: {  (point) in
            let distance = point.y - (-1) * scrollView.contentInset.top
            if distance > 0 {
                let offsetY = min(minDistance, distance)
                headView.snp.updateConstraints { (make) in
                    make.top.equalToSuperview().offset(-1 * offsetY)
                }
                let isBlurShadow = offsetY == minDistance
                headView.headerBlurView.isHidden = !isBlurShadow
                headView.headerBlurView.clipsToBounds = !isBlurShadow
            }else {
                headView.headerBlurView.isHidden = true
                headView.headerBlurView.clipsToBounds = true
                headView.headerBlurView.clipsToBounds = true
                headView.snp.updateConstraints { (make) in
                    make.top.equalToSuperview()
                }
            }
        }).disposed(by: defaultBag)
    }
}

extension NotificationPanelViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: wk.view.listView)
        return wk.view.listView.indexPathForItem(at: point) == nil
    }
}

//MARK: CollectionView
extension NotificationPanelViewController: UICollectionViewDelegate, UICollectionViewDataSource, NotificationLayoutDelegate {
    private func bindListView() {
        for aClass in CellViewModel.viewCellClass() {
            listView.register(aClass, forCellWithReuseIdentifier: aClass.description())
        } 
        
        listView.delegate = self
        listView.dataSource = self
//        viewModel.refreshItems.elements.observeOn(MainScheduler.instance)
//            .subscribe(onNext: { [weak self](items) in
//                print("----",items.first?.rawValue.isActive)
//                if items.count == 1, (items.first?.rawValue.isActive ?? true) == false {
//                    self?.viewModel.reloadData()
//                    self?.listView.reloadData()
//                }
//        }).disposed(by: defaultBag)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return viewModel.foldItems.count }
        return viewModel.items.count
    }
    
    func itemSize(layout: UICollectionViewLayout, indexPath: IndexPath) -> CGSize {
        if (layout is NotificationExpandLayout)   {
            return viewModel.items.get(indexPath.row)?.contentSize() ?? .zero
        } else {
            return CGSize(width: ScreenBounds.width,
                          height: NotificationPanelViewController.minFoldContentHeight)
        }
    }
    
    func status() -> (Bool, LayoutType) {
        let layout = viewModel.layoutType
        var headunRead:Bool = true
        if layout == .fold, viewModel.items.count == 0 {
            headunRead = false
        }
        return (headunRead, viewModel.layoutType)
    }
    
    private func getCollectionCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ vm:CellViewModel) ->fxNotificationViewCell {
        let aClass = vm.viewCellClass()
        let identifier = indexPath.section == 0 ? aClass.0.description() : aClass.1.description()
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! fxNotificationViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = indexPath.section == 0 ? viewModel.foldItems : viewModel.items
        guard let cellVM = items.get(indexPath.row) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ExpandNormalCell.description(), for: indexPath)
        }
        let unReadCount = viewModel.items.filter { (cell) -> Bool in
            return cell.rawValue.isRead == false && cell.rawValue.notiType != .backup
        }.count
        
        let cell = getCollectionCell(collectionView, indexPath, cellVM)
        cell.update(model: cellVM, unReadCount, indexPath.row)
        cell.delegate = indexPath.section == 0 ? nil : self
        cell.isHidden = false
        if self.viewModel.itemCount.value.1 == .fold {
            cell.isHidden = unReadCount <= 0
        }
        return cell
    }

    private func setReadItems(coin cid:String) -> Observable<[CellViewModel]> { 
        return self.wk.view.fold().flatMap {[weak self]  (_) -> Observable<[CellViewModel]> in
            guard let this = self else { return .empty() }
            return this.wallet.notifManager.markAllRead(coin: cid).flatMap { (_) -> Observable<[CellViewModel]> in
                guard let this = self else { return .empty() }
                return this.viewModel.refreshItems.execute((false, LayoutType.hide))
            }
        }
    }
 
    fileprivate func foldAndHaveRead(cid: String?) {
        self.wk.view.hide().subscribe(onNext: { [weak self] in
            guard let this = self else { return }
            if let _cid = cid  {
                this.wallet.notifManager.markAllRead(coin: _cid)
                    .observeOn(MainScheduler.instance)
                    .flatMap { (_) -> Observable<Void> in
                        return this.wk.view.fold(animated: false)
                    }.subscribe(onNext: { _ in
                        this.viewModel.refreshItems.execute((false, this.viewModel.layoutType))
                }).disposed(by: this.defaultBag)
            }else {
                this.viewModel.refreshItems.execute((false, this.viewModel.layoutType))
            }
        }).disposed(by: self.defaultBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1, let item = self.viewModel.items.get(indexPath.row) {
            if item.rawValue.url.isNotEmpty {
                DispatchQueue.main.async {
                    if item.rawValue.walletId == FxNotification.globalId {
                        if item.rawValue.url == "fxWallet://app/backup" {
                            Router.pushToBackUpNotice(wallet: self.wallet, completion: { [weak self] _ in
                                self?.foldAndHaveRead(cid: nil)
                            })
                        } 
                    }else { 
                        if let cid = item.coin?.id {
                            Router.showWebViewController(url: item.rawValue.url, completion: { [weak self] _ in
                                self?.foldAndHaveRead(cid: cid)
                            })
                        } else {
                            if  item.rawValue.notiType == .system && item.rawValue.url.length > 0 {
                                Router.showWebViewController(url: item.rawValue.url, completion: nil)
                            }
                        }
                    }
                }
            } else {
                if item.rawValue.notiType == .failureTransfer || item.rawValue.notiType == .crossFailureTransfer {
                    if let chain = Node.ChainType(rawValue: Int(item.rawValue.chain)) {
                        if chain.isEthereumNet {
                            let coin = Coin.unknownErc20(chain: chain, symbol: item.rawValue.symbol, contract: item.rawValue.contractAddress)
                            Router.showExplorer(coin , path: .hash(item.rawValue.txHash))
                        } else if chain.isFxCoreNet {
                            let coin = CoinService.current.fxCore
                            Router.showExplorer(coin , path: .hash(item.rawValue.txHash))
                        } else if chain == .bitcoin {
                            guard let coin = CoinService.current.btc else {
                                return
                            }
                            Router.showExplorer(coin , path: .hash(item.rawValue.txHash))
                        }
                    }
                }
            }
        }
    }
}

extension NotificationPanelViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let item = viewModel.items[indexPath.row]
        if item.rawValue.unDeleted || orientation == .left { return nil }
        let trash = SwipeAction(style: .destructive, title: nil) {[weak self] action, indexPath in
            self?.viewModel.remove(at: indexPath, self?.viewModel.layoutType ?? .hide)
        }
        
        trash.image = IMG("ic_not_trashB")
        trash.backgroundColor = .clear
        trash.highlightedBackgroundColor = .clear
        
        trash.hidesWhenSelected = true
        trash.transitionDelegate = ScaleTransition.default
        return [trash]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions { 
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .reveal
        options.backgroundColor = UIColor.clear
        return options
    }
}

//MARK: Utils
extension NotificationPanelViewController {
    
    private func configuration() {
        self.modalPresentationStyle = .overCurrentContext
        self.extendedLayoutIncludesOpaqueBars = false
        self.modalPresentationCapturesStatusBarAppearance = true
    }
}
