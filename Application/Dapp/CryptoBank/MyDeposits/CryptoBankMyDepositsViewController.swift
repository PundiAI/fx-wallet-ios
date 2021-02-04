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

extension WKWrapper where Base == CryptoBankMyDepositsViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension CryptoBankMyDepositsViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        
        return CryptoBankMyDepositsViewController(wallet: wallet)
    }
}

class CryptoBankMyDepositsViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.viewModel = ViewModel(wallet: wallet)
        super.init(nibName: nil, bundle: nil)
    }
    
    let viewModel: ViewModel
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindListView()
        bindListHeader()
        
        fetchData()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("MyDeposits.Title"))
    }
    
    private func fetchData() {
        viewModel.refresh()
    }
    
    private func bindListHeader() {
        
        weak var welf = self
        let wallet = viewModel.wallet
        viewModel.totalBalance.value.subscribe(onNext: { value in
            welf?.wk.view.listHeader.legalBalanceLabel.text = "$\(value)"
        }).disposed(by: defaultBag)
        wk.view.listHeader.txHistoryButton.action {
            Router.pushToCryptoBankTxHistory(wallet: wallet)
        }
        
        wk.view.despositButton.action { welf?.goToDeposit() }
    }
    
    private func goToDeposit() {
        
        let wallet = viewModel.wallet
        Router.showSelectAccount(wallet: viewModel.wallet, current: nil, filter: { (token, _) in token.supportAave }) { (vc, coin, account) in
            Router.dismiss(vc, animated: false) {
                Router.pushToCryptoBankDeposit(wallet: wallet, coin: coin, account: account)
            }
        }
    }
}
        

extension CryptoBankMyDepositsViewController: UITableViewDataSource, UITableViewDelegate {

    private var listView: UITableView { wk.view.listView }
    private func bindListView() {
        
        listView.register(Cell.self, forCellReuseIdentifier: "cell")
        listView.register(ListHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
        listView.delegate = self
        listView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { viewModel.items[section].height }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ListHeader
        header?.titleLabel.text = TR("MyDeposits.$Assets", viewModel.items[section].items.count)
        header?.addressLabel.text = viewModel.items[section].account.address
        return header
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.items[indexPath.section].items[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        cell.bind(viewModel.items[indexPath.section].items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = viewModel.items[indexPath.section].items[indexPath.row]
        
    }
}
