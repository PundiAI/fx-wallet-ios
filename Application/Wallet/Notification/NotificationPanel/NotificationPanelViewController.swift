//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import SwipeCellKit
import XChains

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
    public static var minContentHeight:CGFloat = 140.auto()
    
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
        viewModel.refreshItems.execute((false, self.viewModel.layoutType))
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
        viewModel.refreshItems.execute((true, .expand))
            .flatMap { (_) -> Observable<Void> in
                return view.expand()
            }.subscribe().disposed(by: defaultBag)
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
        wallet.notifManager.didReceive.subscribe(onNext: { (notif) in
            welf?.insert(notif)
        }).disposed(by: defaultBag)
        
        viewModel.didRemove.subscribe(onNext: { (_, indexs) in
            welf?.remove(indexs)
        }).disposed(by: defaultBag)
        
        viewModel.didUpdate.subscribe(onNext: { (_, _) in
            welf?.listView.reloadData()
        }).disposed(by: defaultBag)
        
        wallet.event.isBackuped.subscribe(onNext:  {(value) in
            welf?.fetchData()
        }).disposed(by: defaultBag)
        
    }

    // 校验ERC20币种信息
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
        if event == "addToken",
            let cell = context[eventSender] as? TransactionCell,
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
                    welf?.viewModel.add(coin: _coin)
                    welf?.foldAndHaveRead(cid: _coin.id)
                    hub?.hide()
                }
            } onError: { (error) in
                hub?.hide(animated: false)
                hub?.error(m: TR("Notif.AddToken.Error$", coin.symbol))
            }.disposed(by: defaultBag)
        }
    }
     
    //MARK: Animations
    private func insert(_ item: FxNotification) {
        self.listView.performBatchUpdates ({ [weak self] in
            self?.viewModel.insert(item, self?.viewModel.layoutType ?? .fold)
            self?.listView.insertItems(at: [IndexPath(row: 0, section: 0)])
            self?.listView.insertItems(at: [IndexPath(row: 0, section: 1)])
        }, completion: {[weak self] (_) in
            self?.viewModel.reloadData()
            self?.listView.reloadData()
            self?.listView.collectionViewLayout.invalidateLayout()
        })
    }
    
    private func remove(_ indexs: [IndexPath]) {
        if indexs.count == 0 {
            self.viewModel.reloadData()
            self.listView.reloadData()
            self.listView.collectionViewLayout.invalidateLayout()
        } else {
            self.listView.performBatchUpdates({
                self.listView.deleteItems(at: indexs)
            }, completion: { [weak self] _ in
                self?.viewModel.reloadData()
                self?.listView.reloadData()
                self?.listView.collectionViewLayout.invalidateLayout()
            })
        }
    }
    
    //MARK: 绑定滚动
    private func bindScroll() {
        let minDistance:CGFloat = 100.auto()
        let headView = wk.view.headerView
        let blurView = wk.view.blurView
        let initHeadTop = headView.top
        let scrollView = listView

        scrollView.rx.contentOffset.filter({[weak self] (point) -> Bool in
            return scrollView.contentInset.top > 0
                && ((self?.wk.view.isAnimating ?? true) == false)
        }).subscribe(onNext: {  (point) in
            if point.y >= -1 * minDistance {
                headView.top = (point.y - scrollView.contentInset.top) - (-1 * minDistance)
                scrollView.bringSubviewToFront(headView)
                headView.clipsToBounds = false
                headView.headerBlurView.isHidden = false
                blurView.snp.updateConstraints { (make) in
                    make.top.equalToSuperview().inset(minDistance)
                }
            }else {
                headView.top = initHeadTop
                headView.layer.zPosition = 0
                scrollView.sendSubviewToBack(headView)
                headView.clipsToBounds = true
                headView.headerBlurView.isHidden = true
                blurView.snp.updateConstraints { (make) in
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
        
        listView.register(FoldCell.self, forCellWithReuseIdentifier: FoldCell.description())
        listView.register(ExpandCell.self, forCellWithReuseIdentifier: ExpandCell.description())
        listView.register(TransactionCell.self, forCellWithReuseIdentifier: TransactionCell.description())
        
        listView.delegate = self
        listView.dataSource = self
        viewModel.refreshItems.elements.subscribe(onNext: { [weak self](_) in
            self?.viewModel.reloadData()
            self?.listView.reloadData()
        }).disposed(by: defaultBag)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return viewModel.foldItems.count }
        return viewModel.items.count
    }
    
    func itemSize(layout: UICollectionViewLayout, indexPath: IndexPath) -> CGSize {
        if (layout is NotificationExpandLayout) || (layout is NotificationHideLayout){
            return viewModel.items.get(indexPath.row)?.size ?? .zero
        } else {
            return CGSize(width: ScreenBounds.width,
                          height: NotificationPanelViewController.minContentHeight - 20.0.auto())
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = indexPath.section == 0 ? viewModel.foldItems : viewModel.items
        guard let cellVM = items.get(indexPath.row) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ExpandCell.description(), for: indexPath)
        }
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoldCell.description(), for: indexPath) as! FoldCell
            let unReadCount = viewModel.items.filter { (cell) -> Bool in
                return cell.rawValue.isRead == false
            }.count
            let content = viewModel.foldItems[indexPath.row].rawValue.title + " " + viewModel.foldItems[indexPath.row].rawValue.message
            cell.textLabel.text = content
            cell.alertNumRelay.accept(unReadCount)
            cell.isHidden = unReadCount <= 0
            cell.contentBoxVie.isHidden = indexPath.row > 0
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
        wk.view.fold().subscribe(onNext: { [weak self] in
            guard let this = self else { return }
            if let _cid = cid  {
                this.wallet.notifManager.markAllRead(coin: _cid).subscribe(onNext: { _ in
                    this.viewModel.refreshItems.execute((false, this.viewModel.layoutType))
                }).disposed(by: this.defaultBag)
            }else {
                this.viewModel.refreshItems.execute((false, this.viewModel.layoutType))
            }
        }).disposed(by: defaultBag)
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
        if item.rawValue.mustKnown || orientation == .left { return nil }
        
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
