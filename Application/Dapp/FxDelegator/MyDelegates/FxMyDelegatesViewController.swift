

import WKKit
import RxSwift
import RxCocoa
import XChains

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
        
        bindHeader()
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
    
    private func bindHeader() {
        let header = wk.view.header
        
        let fxc = coin.token
        header.fxcLabel.text = fxc
        header.fxUSDLabel.text = Coin.FxUSDSymbol

        let fxcReward = Observable.combineLatest(items.map{ $0.fxcReward })
        fxcReward.subscribe(onNext: { [weak self](values) in
            guard let this = self else { return }
            header.fxcRewardsLabel.text = this.total(values).div10(this.coin.decimal).thousandth()
        }).disposed(by: defaultBag)
        
        let fxUSDReward = Observable.combineLatest(items.map{ $0.fxUSDReward })
        fxUSDReward.subscribe(onNext: { [weak self](values) in
            guard let this = self else { return }
            header.fxUSDRewardsLabel.text = this.total(values).div10(this.coin.decimal).thousandth()
        }).disposed(by: defaultBag)
        
        let delegated = Observable.combineLatest(items.map{ $0.delegateAmount })
        delegated.subscribe(onNext: { [weak self](values) in
            guard let this = self else { return }
            header.delegatedLabel.text = "\(this.total(values).div10(this.coin.decimal).thousandth()) \(fxc)"
        }).disposed(by: defaultBag)
        
        let balance = Observable.combineLatest(items.map{ $0.balance.value })
        balance.subscribe(onNext: { [weak self](values) in
            guard let this = self else { return }
            header.availableLabel.text = "\(this.total(values).div10(this.coin.decimal).thousandth()) \(fxc)"
        }).disposed(by: defaultBag)
    }
    
    private func fetchData() {
        
        if displayItems.isEmpty { self.hud?.waiting() }
        DispatchQueue.main.asyncAfter(deadline: .now() + (displayItems.isEmpty ? 0 : 1)) {
            self.items.forEach{ $0.refreshAction.execute() }
        }
    }
    
    private func total(_ values: [String]) -> String {
        
        var total = "0"
        for v in values {
            if !v.isUnknownAmount { total = total.add(v, coin.decimal) }
        }
        return total
    }
}
        
 
extension FxMyDelegatesViewController: UITableViewDataSource, UITableViewDelegate {

    private var listView: UITableView { wk.view.listView }
    private func bindListView() {
        
        listView.delegate = self
        listView.dataSource = self
        listView.register(Cell.self, forCellReuseIdentifier: "cell")
        listView.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
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
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeader
        let amount = displayItems[section].delegateAmount.value.div10(coin.decimal).thousandth()
        header?.totalLabel.text = "\(TR("Total")) \(amount)"
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
        guard let vm = displayItems.get(indexPath.section)?.items.get(indexPath.row) else { return }
        
        Router.pushToFxValidatorOverview(wallet: wallet, coin: coin, validator: vm.validator, account: vm.account)
    }
}
