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

class AddFunctionXChainController: WKViewController {
    
    var urls = ["https://v68sbvamoqe4-test.blockchain.functionx.io/chain/fxcore-1/"]
    lazy var listView = WKTableView(.white, cornerRadius: 20)
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: "Function X Chains")
        navigationBar.action(.right, imageName: "Wallet.Add") { [weak self] in
            self?.addChainIfNeed()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = HDA(0xe5e5e5)
        self.view.addSubview(listView)
        self.view.bringSubviewToFront(navigationBar)
        listView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight + 8, left: 24, bottom: 24, right: 24).auto())
        }
        
        weak var welf = self
        listView.viewModels = { _ in NSMutableArray.viewModels(from: welf?.urls, Cell.self) }
        listView.didSeletedBlock = { (listView, indexPath) in
            guard let url = welf?.urls.get(indexPath.row) else { return }

            welf?.addCoin(url)
        }
    }
    
    private func addChainIfNeed() {
        
        let vc = AddFunctionXChainInputController()
        vc.handler = { [weak self]url in
            if self?.urls.contains(items: url) == false {
                self?.urls.append(url)
                self?.listView.reloadData()
            }
        }
        Router.push(vc)
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
//                        result.append(Coin.cloud(rpc: url, hrp: hrp, chainId: chainId, name: "\(symbol.uppercased())-ETH", symbol: "eth-\(symbol)-\(suffix)".lowercased(), decimals: objs[i].3))
//                    }
//                    return result
//                }
//            }
//        }.subscribe(onNext: { items in
//            welf?.hud?.hide()
//            
//            var count = 0
//            let wallet = XWallet.currentWallet!.wk
//            for coin in items {
//                if !wallet.coinManager.has(coin) {
//                    wallet.coinManager.add(coin)
//                    count += 1
//                }
//            }
//
//            Router.popToRoot()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                Router.topViewController?.hud?.text(m: "add \(count) coin success")
//            }
//        }, onError: { (e) in
//            welf?.hud?.hide()
//            welf?.hud?.text(m: e.asWKError().msg)
//        }).disposed(by: defaultBag)
    }
}

extension AddFunctionXChainController {
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
