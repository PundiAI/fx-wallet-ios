//
//  SendTokenCommitMinePageListBinder.swift
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

class SendTokenCommitMinePageListBinder: SendTokenCommitPageListBinder, UITableViewDataSource, UITableViewDelegate {
    
    private var items: [SectionViewModel] = []
    
    var didSeleted: ((User) -> Void)?
    
    override func bind() {
        load()
        bindListResponder()
        bindListView()
    }
    
    private func load() {
        
        let sections = matchedSections()
        for coin in wallet.coins {
            for section in sections {
                
                if section.coin.chainType == coin.chainType {
                    
                    for account in wallet.accounts(forCoin: coin).accounts {
                        section.add(CellViewModel(account: account))
                    }
                    break
                }
            }
        }
        
        for section in sections {
            section.items.last?.tagLast()
            if section.items.isNotEmpty { items.append(section) }
        }
        
        loadCrossChainSections()
    }
    
    private func bindListView() {
        
        listView.delegate = self
        listView.dataSource = self
        listView.register(Cell.self, forCellReuseIdentifier: "cell")
        listView.register(Header.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listView.scrollViewDidScroll?(listView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return items.count }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 64.auto() }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? Header
        let coin = items[section].mainCoin
        header?.chainNameLabel.text = coin.node.chain.rawValue
        header?.chainView.bind(coin)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0.001 }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { return "" }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items.get(indexPath.section)?.items.get(indexPath.row)?.height ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = items[indexPath.section]
        let vm = section.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        
        let remark = vm.account.remark
        cell.addressLabel.text = vm.account.address
        cell.remarkLabel.title = remark
        cell.remarkLabel.isHidden = remark.isEmpty
        cell.addCorner(top: indexPath.row == 0, bottom: indexPath.row == section.items.count - 1, height: vm.height)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = items[indexPath.section].items[indexPath.row].account
        let user = User(address: account.address)
        self.didSeleted?(user)
    }
    
    private func matchedSections() -> [SectionViewModel] {
        
        let service = CoinService.current
        if coin.isBTC { return [SectionViewModel(coin: service.btc ?? .empty)] }
        if coin.isEthereum { return [SectionViewModel(coin: service.ethereum)] }
        if coin.isFxCore { return [SectionViewModel(coin: service.fxCore)] }
        if coin.isFxPayment { return [SectionViewModel(coin: service.payc)] }
        return []
    }
    
    private func loadCrossChainSections() {
        
        let eth = CoinService.current.ethereum
        let fxc = CoinService.current.fxCore
        let payc = CoinService.current.payc
        let hasFxc = wallet.coinManager.has(fxc)
        let hasEth = wallet.coinManager.has(eth)
        let hasPayc = wallet.coinManager.has(payc)
        if coin.isERC20 {
            guard hasFxc || hasPayc else { return }
            
            let bridge = FunctionXEthereumBridge(rpc: coin.node.url, chainId: 0, contract: ThisAPP.FxConfig.bridge())
            bridge.isSupport(erc20: coin.contract).subscribe(onNext: { [weak self] isSupport in
                if isSupport {
                    
                    if hasFxc { self?.addSection(fxc) }
                    if hasPayc { self?.addSection(payc) }
                    self?.listView.reloadData()
                }
            }).disposed(by: defaultBag)
        } else if coin.isFxCore {
            if hasEth { addSection(eth) }
            if hasPayc { addSection(payc) }
        } else if coin.isFxPayment {
            guard !coin.isPAYC else { return }
            
            if hasEth { addSection(eth) }
            if hasFxc { addSection(fxc) }
        }
    }
    
    private func addSection(_ coin: Coin) {
        
        let section = SectionViewModel(coin: coin)
        for account in wallet.accounts(forCoin: coin).accounts {
            section.add(CellViewModel(account: account))
        }
        section.items.last?.tagLast()
        if section.items.count > 0 { items.append(section) }
    }
    
    //MARK: View
    override func layoutUI() {
        self.navigationBar.isHidden = true
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: listTop, left: 0, bottom: 0, right: 0))
        }
    }
    
    override var listView: WKTableView { tableView }
    lazy var tableView: WKTableView = {

        let v = WKTableView(frame: ScreenBounds, style: .grouped)
        v.backgroundColor = HDA(0x080A32)
        return v
    }()
}


extension SendTokenCommitMinePageListBinder {
    
    class SectionViewModel {
        
        init(coin: Coin) {
            self.coin = coin
        }
        
        let coin: Coin
        var items: [CellViewModel] = []
        
        private var map: [String: Any] = [:]
        func add(_ item: CellViewModel) {
            let k = item.account.address.lowercased()
            guard map[k] == nil else { return }
            
            map[k] = "1"
            items.append(item)
        }
        
        var mainCoin: Coin { coin.mainCoin }
    }
    
    class CellViewModel {
        
        let account: Keypair
        var height: CGFloat
        init(account: Keypair) {
            self.account = account
            self.height = account.remark.isEmpty ? 59.auto() : 83.auto()
        }
        
        func tagLast() {
            self.height += 8.auto()
        }
    }
}
