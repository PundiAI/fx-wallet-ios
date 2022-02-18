//
//  SendTokenCommitRecentsPageListBinder.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/4/13.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import FunctionX
import XLPagerTabStrip

class SendTokenCommitRecentPageListBinder: SendTokenCommitPageListBinder, UITableViewDataSource, UITableViewDelegate {
    
    private var items: [CellViewModel] = []
    private lazy var noDataCell = NoDataCell(style: .default, reuseIdentifier: "")
    
    var didSeleted: ((User) -> Void)?
    
    override func bind() {
        load()
        bindListResponder()
        bindListView()
    }
    
    private func load() {
        
        loadReceivers(coin: coin)
        loadCrossChainReceivers()
    }
    
    private func bindListView() {
        
        listView.delegate = self
        listView.dataSource = self
        listView.register(Cell.self, forCellReuseIdentifier: "cell")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listView.scrollViewDidScroll?(listView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.isEmpty ? 1 : items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items.get(indexPath.row)?.height ?? noDataCell.estimatedHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = items.get(indexPath.row) else { return noDataCell }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        let remark = UserDefaults.remark(ofAddress: vm.user.address)
        let hasName = vm.user.name.isNotEmpty
        cell.timeLabel.text = vm.timeText
        cell.addressLabel.text = hasName ? "@\(vm.user.name)" : vm.user.address
        cell.remarkLabel.title = remark
        cell.relayout(hasName: hasName, hasRemark: remark != nil)
        cell.coinTypeView.bind(vm.mainCoin)
        cell.addCorner(top: indexPath.row == 0, bottom: indexPath.row == items.count - 1, height: vm.height)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = items.get(indexPath.row)?.user else { return }
        
        self.didSeleted?(user)
    }
    
    private func loadReceivers(coin: Coin, resort: Bool = false) {
        
        let receiverList = wallet.receivers(forCoin: coin)
        for receiver in receiverList.receivers {
            self.items.append(CellViewModel(user: receiver, coin: receiverList.coin))
        }
        
        if resort { self.resort() }
    }
    
    private func loadCrossChainReceivers() {
        
        let eth = CoinService.current.ethereum
        if coin.isFunctionX, wallet.coinManager.has(eth) {
            loadReceivers(coin: eth, resort: true)
        } else if coin.isERC20 {
            
            let fxc = CoinService.current.fxCore
            let payc = CoinService.current.payc
            let hasFxc = wallet.coinManager.has(fxc)
            let hasPayc = wallet.coinManager.has(payc)
            guard hasFxc || hasPayc else { return }
            
            let bridge = FunctionXEthereumBridge(rpc: coin.node.url, chainId: 0, contract: ThisAPP.FxConfig.bridge())
            bridge.isSupport(erc20: coin.contract)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] isSupport in
                if isSupport {
                    if hasFxc { self?.loadReceivers(coin: fxc) }
                    if hasPayc { self?.loadReceivers(coin: payc) }
                    self?.resort()
                    self?.listView.reloadData()
                }
            }).disposed(by: defaultBag)
        }
    }
    
    private func resort() {
        var temp = self.items
        temp.sort{ $0.user.lastSeenTime >= $1.user.lastSeenTime }
        self.items = temp
    }
    
    //MARK: View
    override func layoutUI() {
        self.navigationBar.isHidden = true
        self.view.backgroundColor = HDA(0x080A32)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: listTop, left: 0, bottom: CGFloat(16.ifull(34).auto()), right: 0))
        }
    }
    
    override var listView: WKTableView { tableView }
    lazy var tableView: WKTableView = {

        let v = WKTableView(frame: ScreenBounds, style: UITableView.Style.plain)
        v.autoCornerRadius = 16
        return v
    }()
}



extension SendTokenCommitRecentPageListBinder {
    
    class CellViewModel {
        
        let coin: Coin
        let user: Receiver
        let height: CGFloat
        let timeText: String
        init(user: Receiver, coin: Coin) {
            self.coin = coin
            self.user = user
//            self.height = user.name.isEmpty ? 115.auto() : 91.auto()
            self.height = 115.auto()
            
            self.timeText = Date.timeAgo(since: Date(timeIntervalSince1970: TimeInterval(user.lastSeenTime)))
        }
        
        var mainCoin: Coin { coin.mainCoin }
    }
}
