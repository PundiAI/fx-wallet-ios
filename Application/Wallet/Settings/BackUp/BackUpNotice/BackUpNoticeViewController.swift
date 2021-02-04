//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == BackUpNoticeViewController {
    var view: BackUpNoticeViewController.View { return base.view as! BackUpNoticeViewController.View }
}

extension BackUpNoticeViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = BackUpNoticeViewController(wallet: wallet)
        return vc
    }
}

class BackUpNoticeViewController: WKViewController {
    
        
    fileprivate lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private let wallet: WKWallet
    fileprivate lazy var viewModel = ViewModel()
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
       
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        bindAction()
        bindListView()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("BackUpNotice.Title"))
    }
    
    private func bindAction() {
        wk.view.startButton.action { [weak self] in
            guard let mnemonic = self?.wallet.mnemonic else { return }
            Router.showVerifyPasswordAlert() { error in
                if error == nil { 
                    Router.pushToPreMnemonic(mnemonic: mnemonic) { (_) in
                        if  Router.isExistInNavigator("SettingsViewController") {
                            Router.popAllButTop{ $0?.heroIdentity == "SettingsViewController" }
                        } 
                    }
                }
            }            
        }
        
        wk.view.startButton.isEnabled =  wk.view.listView.contentSize.height > wk.view.listView.height
        
        listBinder.view.rx.didScroll.subscribe(onNext: { [weak self] in
            guard let contentY =  self?.wk.view.listView.contentOffset.y, let view = self?.wk.view else { return }
            
            if contentY + view.listView.height >= view.listView.contentSize.height {
                UIView.animate(withDuration: 0.15, animations: {
                    view.titleLabel.alpha = 0
                }, completion: { (_) in
                    view.titleLabel.alpha = 1
                    view.startButton.isEnabled = true
                    view.titleLabel.isHidden = true
                })
            }
        }).disposed(by: defaultBag)
        
    }
    
    private func bindListView() {
        let listViewModel = self.viewModel
        listViewModel.items.each { (mode) in
            listBinder.push(Cell.self, vm: mode)
        }
    }
}

/// hero
extension BackUpNoticeViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SettingsViewController", "BackUpNoticeViewController"): return animators["0"]
        case (_, "BackUpNoticeViewController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() { 
        animators["0"] = WKHeroAnimator.Share.push()
    }
}
