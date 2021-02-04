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

extension WKWrapper where Base == CryptoBankAssetsOverviewViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension CryptoBankAssetsOverviewViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let coin = context["coin"] as? Coin else { return nil }
        
        return CryptoBankAssetsOverviewViewController(wallet: wallet, coin: coin)
    }
}

class CryptoBankAssetsOverviewViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        self.viewModel = ViewModel(wallet: wallet, coin: coin)
        super.init(nibName: nil, bundle: nil)
    }
    
    let viewModel: ViewModel
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindListHeader()
        bindListView()
        
        fetchData()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("AssetsOverview.Title"))
    }
    
    private func bindListHeader() {
        
        let vm = self.viewModel
        let view = wk.view.listHeader
        let coin = vm.coin
        view.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
        view.tokenNameLabel.text = coin.name
        view.tokenSymbolLabel.text = coin.token
            
        vm.reserveData.value.subscribe(onNext: { value in
            view.apyLabel.text = vm.apy
            view.liquidityLabel.text = vm.availableLiquidity
        }).disposed(by: defaultBag)
        
        vm.legalAvailableLiquidity.value.subscribe(onNext: { value in
            view.legalLiquidityLabel.text = "$\(value.thousandth(coin.decimal))"
        }).disposed(by: defaultBag)
        
        vm.exchangeRate.value.subscribe(onNext: { value in
            view.priceLabel.text = vm.assetPrice
        }).disposed(by: defaultBag)
        
        var headerHeight: CGFloat = (8 + 24).auto()
        if vm.items.count > 0 {
            headerHeight += view.infoContentHeight
            view.loadingContentView.isHidden = true
        } else {
            headerHeight += (view.infoContentHeight + 24.auto() + view.loadingContentHeight)
            view.loadingIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
            view.loadingLabel.text = TR("AssetsOverview.NoAsset$", coin.token)
            view.loadingDescLabel.text = TR("AssetsOverview.NoAsset$$Notice", coin.token, coin.token)
        }
        wk.view.listView.tableHeaderView = nil
        view.height = headerHeight
        wk.view.listView.tableHeaderView = view
    }
    
    private func bindListView() {
        
        weak var welf = self
        wk.view.listView.viewModels = { _ in return NSMutableArray.viewModels(from: welf?.viewModel.items, Cell.self) }
        wk.view.despositButton.action { welf?.goToDeposit() }
    }
    
    private func goToDeposit() {
        
        let wallet = viewModel.wallet
        Router.showSelectAccount(wallet: viewModel.wallet, current: nil, filterCoin: viewModel.coin) { (vc, coin, account) in
            Router.dismiss(vc, animated: false) {
                Router.pushToCryptoBankDeposit(wallet: wallet, coin: coin, account: account)
            }
        }
    }
    
    private func fetchData() {
        viewModel.refresh()
    }
}
