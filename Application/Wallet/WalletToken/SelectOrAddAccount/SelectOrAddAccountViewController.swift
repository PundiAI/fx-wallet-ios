

import WKKit
import RxSwift
import RxCocoa
import Hero

extension WKWrapper where Base == SelectOrAddAccountViewController {
    var view: SelectOrAddAccountViewController.View { return base.view as! SelectOrAddAccountViewController.View }
}

extension SelectOrAddAccountViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        
        let vc = SelectOrAddAccountViewController(wallet: wallet)
        vc.confirmHandler = context["handler"] as? (UIViewController?, Coin, Keypair) -> Void
        return vc
    }
}

class SelectOrAddAccountViewController: WKViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    let wallet: WKWallet
    var confirmHandler: ((UIViewController?, Coin, Keypair) -> Void)?
    
    lazy var leftListBinder = AccountListBinder(view: wk.view.leftListView)
    lazy var rightListBinder = AddCoinListBinder(view: wk.view.rightListView, searchView: wk.view.searchView)

    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindSwitch()
        bindLeftListView()
        bindRightListView()
        bindTitleAnimator()
    }
    
    override func bindNavBar() {
        navigationBar.isHidden = true
        
        wk.view.closeButton.action { [weak self] in
            Router.pop(self)
        }
    }
    
    private func bindSwitch() {
        
        wk.view.switchToAll.bind(self, action: #selector(switchTo), forControlEvents: .touchUpInside)
        wk.view.switchToMyAssets.bind(self, action: #selector(switchTo), forControlEvents: .touchUpInside)
        wk.view.switchToMyAssets.isSelected = true
    }
    
    @objc private func switchTo(_ sender: UIButton) {
        
        let isMyAssets = sender == wk.view.switchToMyAssets
        let reduceHeader = leftListBinder.view.contentOffset.y < FullNavBarHeight
        
        wk.view.switchToAll.isSelected = !isMyAssets
        wk.view.switchToMyAssets.isSelected = isMyAssets
        wk.view.switchIndicator.snp.updateConstraints { (make) in
            make.left.equalTo(isMyAssets ? 4 : 4 + sender.width)
        }
        
        if !reduceHeader {
            UIView.animate(withDuration: 0.2) {
                self.wk.view.switchView.layoutIfNeeded()
            }
        }
        
        if isMyAssets {
            rightListBinder.view.endEditing(true)
        } else {
            
            if reduceHeader {
                
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                    self.wk.view.titleAnimator.set(percent: 1)
                })
                leftListBinder.view.setContentOffset(CGPoint(x: 0, y: FullNavBarHeight), animated: false)
            }
        }
        wk.view.contentView.setContentOffset(CGPoint(x: isMyAssets ? 0 : ScreenWidth, y: 0), animated: !reduceHeader)
    }
    
    private func bindLeftListView() {
        
        leftListBinder.bind(AccountListViewModel(wallet: wallet, current: nil, showRecentAccounts: false))
        leftListBinder.didSeleted = { [weak self] headView, coin, account in
            (self?.animators["1"] as? AddressHeroAnimator)?.heroHeaderView = headView?.heroBgView
            (self?.animators["1"] as? AddressHeroAnimator)?.headerView = headView?.bgView
            self?.confirmHandler?(self, coin, account)
        }
        leftListBinder.refresh()
    }
    
    private func bindRightListView() {
        
        let viewModel = AddCoinListViewModel(wallet)
        viewModel.itemCount.subscribe(onNext: { [weak self]value in
            self?.wk.view.rightListTitleLabel.text = TR("Select.Token.Result", value.s)
        }).disposed(by: defaultBag)
        
        rightListBinder.didAdded = { [weak self] coin in
            guard let this = self else { return }
            (self?.animators["1"] as? AddressHeroAnimator)?.headerView = self?.wk.view.rightListTitleView
            DispatchQueue.main.async {
                self?.wk.view.searchView.inputTF.resignFirstResponder()
                self?.confirmHandler?(self, coin, this.wallet.accounts(forCoin: coin).recommend)
            }
        }
        rightListBinder.bind(viewModel)
        rightListBinder.refresh()
    }
    
    private func bindTitleAnimator() {
        
        let listView = leftListBinder.view
        let blurOrigin = wk.view.blurContainer.origin.y
        listView.rx.didScroll.subscribe(onNext: { [weak self] _ in

            let interval = min(FullNavBarHeight, max(0, listView.contentOffset.y))
            self?.wk.view.blurContainer.origin.y = blurOrigin - interval
        }).disposed(by: defaultBag)
        wk.view.titleAnimator.bind(listView)
        view.wk.bindLineDisplay(listView)
    }
    
}

extension SelectOrAddAccountViewController {
    class AddressHeroAnimator: WKHeroAnimator {
        var heroHeaderView:UIView?
        var headerView:UIView?
    }
}

/// hero
extension SelectOrAddAccountViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("TokenRootViewController", "SelectOrAddAccountViewController"):  return animators["0"]
        case ("CryptoRootViewController", "SelectOrAddAccountViewController"):  return animators["0"]
        case ("SelectOrAddAccountViewController", "ReceiveTokenViewController"): return animators["1"]
        default: return nil
        }
    }
    
    private func bindHero() {
        animators["0"] = WKHeroAnimator.Share.pageIn() 
        let animator1 = AddressHeroAnimator({ (a) in
            if let animator = a as? AddressHeroAnimator {
                animator.headerView?.isHidden = true
                if let headView = animator.heroHeaderView {
                    headView.isHidden = false
                    headView.hero.id = "qrCodeBackground"
                    headView.hero.modifiers = [.useGlobalCoordinateSpace, .useOptimizedSnapshot, .cornerRadius(36.auto())]
                }
            }
        }, onSuspend: { (a) in
            if let animator = a as? AddressHeroAnimator {
                animator.headerView?.isHidden = false
                if let headView = animator.heroHeaderView {
                    headView.isHidden = true
                    headView.hero.id = nil
                    headView.hero.modifiers = nil
                }
            }
        })
        
        animators["1"] = animator1
    }
}
        
