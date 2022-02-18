//
//  AddFunctionXChain.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/19.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import FunctionX
import SwiftyJSON
 
extension SettingNodesController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        let vc = SettingNodesController()
        return vc
    }
}

class SettingNodesController: WKViewController {
    var dataSouce:Array<NodeList> { NodeManager.shared.nodes }
     
    var urls = ["https://v68sbvamoqe4-test.blockchain.functionx.io/chain/fxcore-1/"]
    lazy var listView = WKTableView(.white).then {
        $0.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Setting.Newtrok.Title"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        self.view.backgroundColor = HDA(0xe5e5e5)
        self.view.addSubview(listView)
        self.view.bringSubviewToFront(navigationBar)
        listView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom)
        }
        
        weak var welf = self
        listView.viewModels = { section in
            guard let this = welf else { return section }
            for nodeList in this.dataSouce {
                if this.ignore(nodeList) { continue }
                
                let chain = nodeList.chain.rawValue
                if chain == Node.Chain.functionX.rawValue {
                    section.push(FxChianHeaderCell.self, m: chain) {
                        welf?.bindFxChainCell($0, chain)
                    }
                }else {
                    section.push(TopHeaderCell.self, m: chain) { $0.titleLabel.text = chain }
                }
                  
                section.push(TopSpaceCell.self)
                
                for item in nodeList.items {
                    
                    section.push(SingleCell.self, m: item) {
                        $0.titleLabel.text = item.name
                        $0.selectedBehavior.accept(item.id == nodeList.selectedItem?.id)
                        $0.enableBehavior.accept(item.enable)
                    }
                }
                section.push(BotSpaceCell.self)
                section.push(WKSpacingCell.self, m: WKSpacing(32.auto(), 0, .clear))
            } 
            return section
        }
        
        listView.didSeletedBlock = {[weak self] (listView, indexPath) in
            guard let this = self else { return }
            guard let cell = (listView.cellForRow(at: indexPath as IndexPath) as? SingleCell),
                  let node = (cell.model as? Node),
                  node.enable, cell.selectedBehavior.value == false
                  else { return }
            
            this.changeNodeAlert(to: node).filter { $0 == true }.subscribe(onNext: { _ in
                Router.switchTo(node: node)
                self?.listView.reloadData()
            }).disposed(by: this.defaultBag)
        }
    }
    
    private func bindFxChainCell(_ cell:FxChianHeaderCell, _ chain: String) {
        cell.titleLabel.text = chain
        
        cell.addButton.isHidden = true //unsupport this version
        cell.addButton.action { [weak self] in
            self?.addChainIfNeed()
        }
    }
    
    private func changeNodeAlert(to:Node) ->Observable<Bool> {
        return Observable.create { observer in
            Router.showChangeNodeAlert(name: to.name) { (_) in
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create {}
        }
    }
    
    private func addChainIfNeed() { 
        if NodeManager.shared.currentEthereumNode.isTestnet {
            addCoin(NodeManager.shared.currentFxNode.url)
        } else {
            self.hud?.text(m: TR("Setting.Newtrok.Alert.1"))
        }
    }
    
    private func ignore(_ node: NodeList) -> Bool {
        if node.chain == .binance || node.chain == .binance_smart_chain || node.chain == .fxPayment { return true }
        return false
    }
    
    private func addCoin(_ url: String) {
        
//        weak var welf = self
//        let eth = CoinService.current.ethereum
//        let node = FxHubNode(endpoints: FxNode.Endpoints(rpc: url), wallet: nil)
//        self.hud?.waiting()
//        node.genesisBlock().flatMap{ value -> Observable<[Coin]> in
//
//            let chainId = value["result", "genesis", "chain_id"].stringValue
//            let account = value["result", "genesis", "app_state", "auth", "accounts", 0, "value", "address"].stringValue
//            guard chainId.isNotEmpty,
//               let (hrp, _) = FunctionXAddress.decode(address: account) else {
//                return .error(WKError(.default, "unrecognized url"))
//            }
//
//            return FunctionX.shared.ethereum.manager.bridgeRecords(of: hrp).flatMap{ info -> Observable<[Coin]> in
//
//                let bridge = FunctionXEthereumBridge(rpc: eth.node.url, chainId: eth.node.chainId.i, contract: info.bridgeContract)
//                return bridge.allTokens().map{ (objs) in
//                    
//                    var result: [Coin] = []
//                    for i in 0..<objs.count {
//                        
//                        let symbol = objs[i].2
//                        let contract = objs[i].0
//                        let suffix = contract.substring(from: contract.count - 3)
//                        result.append(Coin.cloud(rpc: url, hrp: hrp, chainId: chainId, name: "\(symbol.uppercased())-KETH", symbol: "\(symbol)-keth-\(suffix)".lowercased(), decimals: objs[i].3))
//                    }
//                    result.append(Coin.cloud(rpc: url, hrp: hrp, chainId: chainId, name: "ETHER-KETH", symbol: "ether-keth-000", decimals: 18))
//                    return result
//                }
//            }
//        }.subscribe(onNext: { items in
//            welf?.hud?.hide()
//            CoinService.current.add(coins: items)
//
//            Router.popToRoot()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                Router.topViewController?.hud?.text(m: TR("Setting.Newtrok.Add.Success"))
//            }
//        }, onError: { (e) in
//            welf?.hud?.hide()
//            welf?.hud?.text(m: e.asWKError().msg)
//        }).disposed(by: defaultBag)
    }
}

extension SettingNodesController {
    class Cell: WKTableViewCell.TitleCell {
        override func configuration() {
            super.configuration()
            titleLabel.textColor = COLOR.title
            titleLabel.lineBreakMode = .byTruncatingMiddle
            titleLabel.font = XWallet.Font(ofSize: 16)
        }
        
        override class func height(model: Any?) -> CGFloat { 50.auto() }
    }
}
