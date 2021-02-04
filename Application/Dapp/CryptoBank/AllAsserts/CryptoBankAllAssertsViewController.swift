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

extension WKWrapper where Base == CryptoBankAllAssertsViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension CryptoBankAllAssertsViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        
        return CryptoBankAllAssertsViewController(wallet: wallet)
    }
}

class CryptoBankAllAssertsViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.viewModel = ViewModel(wallet)
        super.init(nibName: nil, bundle: nil)
    }

    let viewModel: ViewModel
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindMainList()
        bindSearchList()
        
        fetchData()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("CryptoBank.AllAssets"))
    }
    
    private func bindMainList() {
        
        let view = wk.view.mainListView
        let viewModel = self.viewModel.listViewModel
        
        view.viewModels = { _ in return NSMutableArray.viewModels(from: viewModel.items, CryptoBankAssetCell.self) }
        view.scrollViewDidScroll = { [weak self] _ in self?.view.endEditing(true) }
        view.didSeletedBlock = { (_, indexPath) in
            
            let cellVM = viewModel.items[indexPath.row]
            Router.pushToCryptoBankAssetsOverview(wallet: viewModel.wallet, coin: cellVM.coin)
        }
    }
    
    private func bindSearchList() {
        
        let view = wk.view.searchListView
        let viewModel = self.viewModel.searchListViewModel
        
        weak var welf = self
        view.viewModels = { _ in return NSMutableArray.viewModels(from: viewModel.items, CryptoBankAssetCell.self) }
        view.scrollViewDidScroll = { _ in welf?.view.endEditing(true) }
        view.didSeletedBlock = { (_, indexPath) in
            
            let cellVM = viewModel.items[indexPath.row]
            Router.pushToCryptoBankAssetsOverview(wallet: viewModel.wallet, coin: cellVM.coin)
        }

        let input = wk.view.searchTF.rx.text
        input
            .filterNil()
            .subscribe(onNext: { (v) in
                view.isHidden = v.count == 0
                if view.isHidden { welf?.wk.view.noDataView.isHidden = true }
        }).disposed(by: defaultBag)
        
        viewModel.itemCount.subscribe(onNext: { value in
            welf?.wk.view.resultSection.titleLabel.text = TR("Select.Token.Result", value.s)
            if !view.isHidden { welf?.wk.view.noDataView.isHidden = value != 0 }
        }).disposed(by: defaultBag)
        
        viewModel.search(input)
            .subscribe(onNext: { (_) in view.reloadData() })
            .disposed(by: defaultBag)
    }
    
    private func fetchData() {
        viewModel.refresh()
    }
}
