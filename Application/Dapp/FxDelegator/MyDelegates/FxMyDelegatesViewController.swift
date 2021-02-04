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

extension WKWrapper where Base == FxMyDelegatesViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension FxMyDelegatesViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let coin = context["coin"] as? Coin else { return nil }
        
        return FxMyDelegatesViewController(wallet: wallet, coin: coin)
    }
}

class FxMyDelegatesViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        self.coin = coin
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        
        self.items = wallet.accounts(forCoin: coin).accounts.map{ SectionViewModel(wallet: wallet, coin: coin, account: $0) }
    }
    
    private let coin: Coin
    private let wallet: WKWallet
    private var items: [SectionViewModel] = []
    
    private var displayMap: [String: SectionViewModel] = [:]
    private var displayItems: [SectionViewModel] = []
    
    private lazy var noDataCell = NoDataCell()
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindAction()
        bindListView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("MyDelegates.Title"))
    }
    
    private func bindAction() {
        
        wk.view.chooseButton.action { [weak self] in
            guard let this = self else { return }
            Router.pushToValidatorList(wallet: this.wallet, coin: this.coin)
        }
    }
    
    private func fetchData() {
        
        if displayItems.isEmpty { self.hud?.waiting() }
        DispatchQueue.main.asyncAfter(deadline: .now() + (displayItems.isEmpty ? 0 : 1)) {
            self.items.forEach{ $0.refreshAction.execute() }
        }
    }
}
        
 
extension FxMyDelegatesViewController: UITableViewDataSource, UITableViewDelegate {

    private var listView: UITableView { wk.view.listView }
    private func bindListView() {
        
        listView.delegate = self
        listView.dataSource = self
        listView.register(Cell.self, forCellReuseIdentifier: "cell")
        listView.register(ListHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
        items.first?.refreshAction.executing.subscribe(onNext: { [weak self] executing in
            if !executing { self?.hud?.hide() }
        }).disposed(by: defaultBag)
        
        for (idx, item) in items.enumerated() {
            
            item.refreshAction.elements.subscribe(onNext: { [weak self] value in
                guard let this = self else { return }
                
                if item.items.count > 0, this.displayMap[item.account.address] == nil {
                    
                    this.displayMap[item.account.address] = item
                    if idx < this.displayItems.count {
                        this.displayItems.insert(item, at: idx)
                    } else {
                        this.displayItems.append(item)
                    }
                }
                this.listView.reloadData()
            }).disposed(by: defaultBag)
        }
    }
    
    private var isNoData: Bool { displayItems.count == 0 }
    func numberOfSections(in tableView: UITableView) -> Int {
        return isNoData ? 1 : displayItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { isNoData ? 0.01 : displayItems[section].height }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isNoData { return nil }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ListHeader
        header?.balanceLabel.text = "Total \(displayItems[section].amount)"
        header?.addressLabel.text = displayItems[section].account.address
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 24.auto() }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { "" }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isNoData ? 1 : displayItems[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isNoData { return noDataCell.estimatedHeight }
        return displayItems[indexPath.section].items[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isNoData { return noDataCell }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        cell.bind(displayItems[indexPath.section].items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = displayItems[indexPath.section].items[indexPath.row]
        
        Router.pushToFxValidatorOverview(wallet: wallet, coin: coin, validator: vm.validator, account: vm.account)
    }
}
