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
        
        leftListBinder.bind(AccountListViewModel(wallet: wallet, current: nil))
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
        weak var welf = self 
        let animator0 = WKHeroAnimator({ (_) in
            welf?.wk.view.headerBlur.alpha = 0
            welf?.wk.view.blurContainer.alpha = 0 
            welf?.wk.view.aBackgroundView.hero.id = "token_list_background"
            welf?.wk.view.aBackgroundView.hero.modifiers = [.useOptimizedSnapshot, .useGlobalCoordinateSpace, .cornerRadius(36)]
            welf?.wk.view.contentView.hero.modifiers = [.translate(y: 1000), .fade, .useGlobalCoordinateSpace]
            welf?.wk.view.blurContainer.hero.modifiers = [.translate(y: -600), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.closeButton.hero.modifiers = [.translate(y: -600), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.subtitleLabel.hero.modifiers = [.translate(y: -600), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.titleLabel.hero.modifiers = [.translate(y: -600), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.headerBlur.hero.modifiers = [.translate(y: -600), .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            
            welf?.wk.view.switchView.hero.modifiers = [.translate(y: 1000), .useGlobalCoordinateSpace]
            welf?.wk.view.leftListView.hero.modifiers = [.translate(y: 1500), .useGlobalCoordinateSpace]
            welf?.wk.view.rightListView.hero.modifiers = [.translate(y: 1500), .useGlobalCoordinateSpace]
            Router.tabBarController?.tabBar.hero.modifiers = [.whenPresenting(.useGlobalCoordinateSpace, .beginWith([.zPosition(100)]),
                                                                              .translate(y: CGFloat(100.0 * 2.0))),
                                                              .whenDismissing(.useGlobalCoordinateSpace, .beginWith([.zPosition(100)]), .delay(0.1),
                                                                              .translate(y: CGFloat(100.0 * 2.0)), .forceAnimate)]
        }, onSuspend: { (_) in
            welf?.wk.view.headerBlur.alpha = 1
            welf?.wk.view.blurContainer.alpha = 1
            welf?.wk.view.contentView.hero.modifiers = nil
            welf?.wk.view.blurContainer.hero.modifiers = nil
            welf?.wk.view.closeButton.hero.modifiers = nil
            welf?.wk.view.subtitleLabel.hero.modifiers = nil
            welf?.wk.view.titleLabel.hero.modifiers = nil
            welf?.wk.view.aBackgroundView.hero.id = nil
            welf?.wk.view.aBackgroundView.hero.modifiers = nil
            welf?.wk.view.headerBlur.hero.modifiers = nil
            welf?.wk.view.switchView.hero.modifiers = nil
            welf?.wk.view.leftListView.hero.modifiers = nil
            welf?.wk.view.rightListView.hero.modifiers = nil
            Router.tabBarController?.tabBar.hero.modifiers = nil
        })
        
        animators["0"] = animator0
        
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
        
