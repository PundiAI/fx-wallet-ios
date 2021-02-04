//
//
//  XWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == SelectPayAccountViewController {
    var view: SelectPayAccountViewController.View { return base.view as! SelectPayAccountViewController.View }
}

extension SelectPayAccountViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        
        let filter = context["filter"] as? (Coin, [String: Any]?) -> Bool
        var current: (Coin, Keypair)?
        if let coin = context["currentCoin"] as? Coin,
           let account = context["currentAccount"] as? Keypair {
            current = (coin, account)
        }
        
        let vc = SelectPayAccountViewController(wallet: wallet, current: current, filter: filter)
        vc.cancelHandler = context["cancelHandler"] as? () -> Void
        vc.confirmHandler = context["handler"] as? (UIViewController?, Coin, Keypair) -> Void
        return vc
    }
}

class SelectPayAccountViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, current: (Coin, Keypair)?, filter: ((Coin, [String: Any]?) -> Bool)? = nil) {
        self.listViewModel = AccountListViewModel(wallet: wallet, current: current, filter: filter)
        super.init(nibName: nil, bundle: nil)
    }
    
    var cancelHandler: (() -> Void)?
    var confirmHandler: ((UIViewController?, Coin, Keypair) -> Void)?

    let listViewModel: AccountListViewModel
    lazy var listBinder = OxAccountListBinder(view: wk.view.listView, searchView: wk.view.searchView)
    
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindListView()
    }
    
    override func bindNavBar() {
        navigationBar.isHidden = true
        wk.view.closeButton.action { [weak self] in
            Router.dismiss(self)
        }
        wk.view.navBar.titleLabel.text = TR("Ox.Select.Token")
    }
    
    private func bindListView() {
        
        weak var welf = self
        
        listBinder.bind(listViewModel)
        
        listViewModel.itemsCount.subscribe(onNext: { [weak self] (v) in
            self?.wk.view.noDataView.isHidden = v != 0
        }).disposed(by: defaultBag)
        

        listBinder.didSeleted = { _, coin, account in
            welf?.confirmHandler?(welf, coin, account)
        }
        
        listBinder.didNotEnougtFee = {
            
        }

        listBinder.refresh()
        
        wk.view.closeButton.action {
            Router.dismiss(welf) {
                welf?.cancelHandler?()
            }
        }
        
    }
}
        
