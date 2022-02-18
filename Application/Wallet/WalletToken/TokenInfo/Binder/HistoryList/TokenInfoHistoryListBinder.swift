//
//  TokenInfoHistoryListBinder.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/19.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//
import WKKit
import RxSwift
import RxCocoa
import XLPagerTabStrip

extension WKWrapper where Base == TokenInfoHistoryListBinder {
    var view: TokenInfoHistoryListBinder.View { return base.view as! TokenInfoHistoryListBinder.View }
}


class TokenInfoHistoryListBinder: TokenInfoSubListBinder {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.bindListView()
        self.bindAction()
    }
    
    let viewModel: ViewModel
    
    
    override var listView: WKTableView { wk.view.listView }
    override func loadView() { view = View(frame: ScreenBounds) }
    
    lazy var listBinder = WKTableViewBinder<CellViewModel>(view: listView)
    
    override func refresh() {
        viewModel.refreshItems.execute()
    }
    
    private func bindAction() {
        weak var welf = self
        wk.view.addAddressButton.rx.tap.subscribe(onNext: { (_) in
            guard let coin = welf?.viewModel.coin, let wallet = welf?.viewModel.wallet, let addresses = welf?.viewModel.accounts.accounts else { return }
            if addresses.count == 1 {
                Router.showExplorer(coin, path: .address(addresses[0].address))
            } else {
                Router.showSelectErc20AccountToJump(wallet: wallet, current: nil, push: true, filter: { c,_ in c.id == coin.id }) { (_, _, account) in
                    Router.showExplorer(coin, path: .address(account.address)) { _ in
                        Router.popAllButTop { $0?.heroIdentity == "TokenInfoViewController" }
                    }
                }
            }
        }).disposed(by: defaultBag)
        listBinder.footer?.setTitle("", for: .noMoreData)
    }
    
    
    private func testModel() -> TokenInfoHistoryListBinder.CellViewModel {
        let info = TokenInfoTxInfo()
        info.transferType = "Cross"
        let model = CellViewModel(info, nil, nil, self.viewModel.coin, self.viewModel.wallet)
        return model
    }
    
    private func bindListView() {
        
        let listView = self.listView
        let listViewModel = self.viewModel
        listViewModel.refreshItems.elements.subscribe(onNext: { (_) in
            listView.reloadData()
        }).disposed(by: defaultBag)
        
        listBinder.bind(viewModel)
        
        listView.viewModels = {[weak self] section in
            
            let items = NSMutableArray()
            for vm in listViewModel.items {
                
                switch vm.tTpye {
                case .btc:
                    items.push(BTCCell.self, m: vm, b: nil)
                case .eth:
                    items.push(ETHCell.self, m: vm, b: nil)
                case .crossChain:
                    items.push(CorssChainCell.self, m: vm, b: nil)
                }
            }
            
            let model = TableModel(ReFreshCell.self, m: listViewModel.lastUpdateDate) { (cell) in
                cell.view.refershBtn.rx.tap.subscribe(onNext: { (_) in
                    self?.viewModel.refreshItems.execute()
                }).disposed(by: cell.reuseBag)
            }
            
            items.insert(model, at: 0)
            for (idx, item) in items.enumerated() {
                section.add(item)
                if idx != 0 {
                    section.add(TableModel(WKSpacingCell.self, m: WKSpacing(height: 16.auto()), b: nil))
                }
            }
            
            return section
        }
        
        weak var weakself = self
        
        listView.didSeletedBlock = { (table, indexPath) in
            if let cell = table.cellForRow(at: indexPath as IndexPath) as? BTCCell,
               let model = cell.model as? CellViewModel,
               let coin = weakself?.viewModel.coin {
                Router.showExplorer(coin, path: .hash(model.txInfo.txHash))
            } else if let cell = table.cellForRow(at: indexPath as IndexPath) as? ETHCell,
                      let model = cell.model as? CellViewModel,
                      let coin = weakself?.viewModel.coin {
                Router.showExplorer(coin, path: .hash(model.txInfo.txHash))
            }
            else if let cell = table.cellForRow(at: indexPath as IndexPath) as? CorssChainCell,
                     let model = cell.model as? CellViewModel {
                
                let fromChainId = model.txInfo.chainId
                let toChainId = model.txInfo.crossChain?.chainId ?? 0
                
                guard let coin = weakself?.getCoin(chainId: fromChainId), let coin2 = weakself?.getCoin(chainId: toChainId) else {
                    return
                }

                var  hx = model.txInfo.crossChain?.transactionHash ?? ""
                if hx.length == 0 {
                    if let rshx = ChainTransactionServer.shared?.csHash(forKey: model.txInfo.txHash) {
                        hx = rshx
                    }
                }
                if coin.isFxCore && model.isTransIn == false {
                    Router.showCrossChainWeb((coin2,  hx), fx: (coin , model.txInfo.txHash), ethTofx: false)
                } else if coin.isFxCore && model.isTransIn == true {
                    Router.showCrossChainWeb((coin2, hx ), fx: (coin , model.txInfo.txHash), ethTofx: true)
                } else if coin.isEthereum && model.isTransIn == false {
                    Router.showCrossChainWeb((coin , model.txInfo.txHash), fx: (coin2, hx ), ethTofx: true)
                } else if coin.isEthereum && model.isTransIn == true {
                    Router.showCrossChainWeb((coin , model.txInfo.txHash), fx: (coin2, hx ), ethTofx: false)
                }
           }
        }
    }
    
    
    override func router(event: String, context: [String : Any]) {
        if event == "Help" {
            Router.showRevWebViewController(url: ThisAPP.WebURL.helpTxFailURL)
        }
    }
    
    private func getCoin(chainId: Int64) -> Coin? {
        if let chain = Node.ChainType(rawValue: Int(chainId)) {
            if chain.isEthereumNet {
                return CoinService.current.ethereum
            } else if chain.isFxCoreNet {
                return CoinService.current.fxCore
            }
        }
        return nil
    }
    
    public func loadCache() {
        
    }
    
    //MARK: View
    override func layoutUI() {
        self.navigationBar.isHidden = true
    }
}
