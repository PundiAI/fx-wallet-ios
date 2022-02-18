

import WKKit
import RxSwift
import RxCocoa
 
extension WKWrapper where Base == AddTokenViewController {
    var view: AddTokenViewController.View { return base.view as! AddTokenViewController.View }
}

extension AddTokenViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        
        return AddTokenViewController(wallet: wallet)
    }
}

class AddTokenViewController: WKViewController, UITextFieldDelegate {
    var heroDidAddCoinOb = BehaviorRelay<Coin?>(value: nil)
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    let wallet: WKWallet
    private lazy var viewModel = ViewModel(wallet)
    
    private lazy var listBinder = ListBinder(view: wk.view)
    private lazy var searchBinder = SearchListBinder(view: wk.view.searchListView, searchView: wk.view.searchView)
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
         
        logWhenDeinit()
        
        bindMainList()
        bindSearchList()
        bindTitleAnimator()
    }
    
    override func bindNavBar() {
        
        navigationBar.isHidden = true
        wk.view.closeButton.action { [weak self] in
            Router.pop(self)
        }
    }
    
    private func bindMainList() {
        
        listBinder.bind(viewModel.listViewModel)
        listBinder.didAdded = { [weak self] coin in
            self?.add(coin: coin)
        }
        listBinder.didScroll = { [weak self] _ in
            if self?.wk.view.searchView.beginEdit == true { return }
            self?.view.endEditing(true)
        }
        
        let view = self.wk.view
        heroDidAddCoinOb.filterNil().subscribe(onNext: { (coin) in
            var mCell:AddCoinListCell?
            for listView in [view.mainListView, view.searchListView] {
                if let _mCell = (listView.visibleCells.find(condition: { cell in
                    if let vCell = cell as? AddCoinListCell, let scoin = vCell.viewModel?.rawValue {
                        return scoin.name == coin.name && scoin.symbol == coin.symbol
                    }
                    return false
                }) as? AddCoinListCell) {
                    mCell = _mCell
                    break
                }
            } 
            mCell?.view.tokenIV.hero.id = "hero_add_coin_image"
        }).disposed(by: defaultBag)
    }
    
    private func bindSearchList() {
        searchBinder.bind(viewModel.searchListViewModel)
        searchBinder.didAdded = { [weak self] coin in
            self?.add(coin: coin)
        }
        
        wk.view.searchView.inputTF.delegate = self
        wk.view.searchView.inputTF.rx.text
            .filterNil()
            .subscribe(onNext: { [weak self](v) in
                self?.searchBinder.view.isHidden = v.count == 0
                self?.listBinder.listView.isScrollEnabled = v.count == 0
                self?.listBinder.view.suggestedSection.isHidden = v.count > 0
        }).disposed(by: defaultBag)
    }
    
    private func bindTitleAnimator() {
        wk.view.titleAnimator.bind(listBinder.listView)
        view.wk.bindLineDisplay(listBinder.listView)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        wk.view.searchView.isEditing(true)
        wk.view.searchView.beginEdit = true
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.wk.view.titleAnimator.set(percent: 1)
            self.listBinder.listView.contentOffset = CGPoint(x: 0, y: FullNavBarHeight)
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.wk.view.searchView.beginEdit = false
            }
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        wk.view.searchView.isEditing(false)
        wk.view.searchView.beginEdit = false
    }
    
    private func add(coin: Coin) { 
        Router.showAddCoinAlert(coin: coin) { [weak self] allow in
            guard allow else { return }
            self?.heroDidAddCoinOb.accept(coin)
            self?.wallet.coinManager.add(coin)
            Router.pop(self)
        }
    }
}

/// hero
extension AddTokenViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("TokenRootViewController", "AddTokenViewController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() { 
        weak var welf = self
        let navBarBackgoundColor = self.wk.view.navBar.backgroundColor
        _ = WKHeroAnimator({ (_) in
            welf?.wk.view.navBar.blur.alpha = 0
            welf?.wk.view.navBar.backgroundColor = UIColor.clear 
            welf?.wk.view.navBar.hero.modifiers = [.translate(y: -200), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.aBackgroundView.hero.id = "token_list_background"
            welf?.wk.view.aBackgroundView.hero.modifiers = [.useOptimizedSnapshot, .useGlobalCoordinateSpace] 
            welf?.wk.view.mainListView.hero.modifiers = [.translate(y: 1000), .fade, .useGlobalCoordinateSpace]
            welf?.wk.view.closeButton.hero.modifiers = [.translate(y: -200), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.subtitleLabel.hero.modifiers = [.translate(y: -200), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.titleLabel.hero.modifiers = [.translate(y: -200), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            Router.fxTabBarController?.setHeroModifiers(modifiers: [.whenPresenting(.useGlobalCoordinateSpace, .beginWith([.zPosition(100)]),
                                                                                    .translate(y: CGFloat(100.0 * 2.0))),
                                                                    .whenDismissing(.useGlobalCoordinateSpace, .beginWith([.zPosition(100)]), .delay(0.1),
                                                                                    .translate(y: CGFloat(100.0 * 2.0)), .forceAnimate)])
        }, onSuspend: { (_) in
            Router.fxTabBarController?.setHeroModifiers(modifiers: nil)
            welf?.wk.view.navBar.blur.alpha = 1
            welf?.wk.view.navBar.backgroundColor = navBarBackgoundColor
            welf?.wk.view.aBackgroundView.hero.id = nil
            welf?.wk.view.aBackgroundView.hero.modifiers = nil
            welf?.wk.view.mainListView.hero.modifiers = nil
            welf?.wk.view.closeButton.hero.modifiers = nil
            welf?.wk.view.subtitleLabel.hero.modifiers = nil
            welf?.wk.view.titleLabel.hero.modifiers = nil
            welf?.wk.view.navBar.hero.modifiers = nil
        })
        
        animators["0"] = WKHeroAnimator.Share.pageIn()
    }
}
        
