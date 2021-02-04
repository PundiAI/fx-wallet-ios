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

extension WKWrapper where Base == CryptoBankViewController {
    var view: Base.View { return base.view as! Base.View }
}
 
open class CryptoBankViewController: WKViewController {

    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.viewModel = ViewModel(wallet: wallet)
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = .bottom
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    let viewModel: ViewModel
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)

    open override func loadView() { view = View(frame: ScreenBounds) }
    open override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindListView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.refresh()
        AAve.current.syncIfNeed()
    }
    
    open override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("CryptoBank"))
    }
    
    private func bindListView() { 
        
        listBinder.push(DelegateCell.self, vm: viewModel.delegateVM)
        self.pushDepositCell()
        listBinder.push(PurchaseCell.self, vm: viewModel.purchaseVM)
    }
    
    lazy var depositCell = DepositCell(style: .default, reuseIdentifier: "x")
    private func pushDepositCell() {
        
        reloadDepositIfNeed()
        XWallet.Event.subscribe(.AAveTokensUpdate, { [weak self](_, _) in
            self?.reloadDepositIfNeed()
            self?.listBinder.view.reloadData()
        }, disposedBy: defaultBag)
    }
    
    private func reloadDepositIfNeed() {
        guard AAve.current.tokens.count >= 3 else { return }
        
        if depositCell.viewModel == nil {
            listBinder.push(depositCell, vm: viewModel.depositVM, at: 1)
        }
        depositCell.reloadIfNeed()
    }
    
    open override func router(event: String, context: [String : Any]) {
        if event == "buy", let coin = context["coin"] as? Coin {
            Router.showCashBuyController(coin: coin)
        }else if event == "all" {
            Router.pushToAllPurchaseController()
        }
    }
}
        
