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

extension WKWrapper where Base == SelectReceiveCoinViewController {
    var view: SelectReceiveCoinViewController.View { return base.view as! SelectReceiveCoinViewController.View }
}

extension SelectReceiveCoinViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet, let handle = context["handler"] as? (Coin) -> Void  else { return nil }
        
        
        
        let vc = SelectReceiveCoinViewController(wallet: wallet)
        vc.handle = handle
        if let filter = context["filter"] as? Coin {
            vc.filter = filter
        }
        return vc
    }
}

class SelectReceiveCoinViewController: WKViewController, UITextFieldDelegate {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    private let wallet: WKWallet
    var handle: ((Coin) -> Void)?
    var filter: Coin?
    fileprivate lazy var viewModel = ViewModel(wallet, filter: filter)
 
    private lazy var listBinder = SearchListBinder(view: wk.view.listView, searchView: wk.view.searchView)
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindList()
        loadData()
    }
    
    override func bindNavBar() {
        navigationBar.isHidden = true
        wk.view.closeButton.action { [weak self] in
            Router.dismiss(self)
        }
        wk.view.navBar.titleLabel.text = TR("Ox.Select.Token")
    }
    
    private func bindList() {
        
        listBinder.bind(viewModel.listViewModel)

        wk.view.searchView.inputTF.delegate = self
        
        listBinder.coinSelected = {[weak self] coin in
                guard let this = self else {
                    return
                }
                this.handle?(coin)
                Router.dismiss(this)
            }
    }
    
    private func loadData() {
        weak var  welf = self
        welf?.hud?.waiting()
        getCoins().subscribe(onNext: { [weak self](value) in
            welf?.hud?.hide()
            guard let this = self else { return }
             let models = value.map { AddCoinCellViewModel($0) }
             this.viewModel.listViewModel.coins = models
             this.viewModel.listViewModel.items = models
             this.listBinder.loadCompleted = true
             this.listBinder.view.reloadData()
        }, onError: { (e) in
            welf?.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
            welf?.listBinder.loadCompleted = true
            welf?.listBinder.view.reloadData()
        }).disposed(by: defaultBag)
    }
    
    private func getCoins() -> Observable<[OxToken]>  {
        return  viewModel.listViewModel.loadCoins()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        wk.view.searchView.isEditing(true)
        wk.view.searchView.beginEdit = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        wk.view.searchView.isEditing(false)
        wk.view.searchView.beginEdit = false
    }
}
        
