//
//  FxCloudSelectAddressCellViewModel.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/6/2.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import FunctionX
import SwiftyJSON
import TrustWalletCore

//MARK: AddressListViewModel
extension FxAnyNodeSelectAddressViewController {
    
    class FCListViewModel: ListViewModel {
        
        let hrp: String
        let token: String
        let nodeUrl: String
        let derivationTemplate: String?
        
        init(_ wallet: Wallet, hrp: String, derivationTemplate: String? = nil, nodeUrl: String, token: String) {
            self.hrp = hrp
            self.token = token
            self.nodeUrl = nodeUrl
            self.derivationTemplate = derivationTemplate
            super.init(wallet)
        }
        
        override func cellVM(derivationAddress: Int) -> CellViewModel {
            let cellVM = FCCellViewModel(wallet, derivationAddress: derivationAddress, hrp: hrp, derivationTemplate: derivationTemplate, nodeUrl: nodeUrl, token: token)
            cellVM.refreshIfNeed()
            return cellVM
        }
    }
}

//MARK: AddressCellViewModel
extension FxAnyNodeSelectAddressViewController {
    
    class FCCellViewModel: CellViewModel {
        
        let hrp: String
        let path: String
        let token: String
        let nodeUrl: String
        
        init(_ wallet: Wallet, derivationAddress: Int, hrp: String, derivationTemplate: String? = nil, nodeUrl: String, token: String) {
            
            self.hrp = hrp
            self.token = token
            self.nodeUrl = nodeUrl
            
            let template = derivationTemplate ?? "m/44'/118'/0'/0/0"
            var components = template.components(separatedBy: "/")
            components.removeLast()
            components.append(String(derivationAddress))
            self.path = components.joined(separator: "/")
            
            super.init(wallet, derivationAddress: derivationAddress)
        }
        
        override var derivationPath: String { path }
        override func generateAddress() -> String {
            return FunctionXAddress(hrpString: hrp, publicKey: publicKey.data)?.description ?? ""
        }
        
        lazy var node: FxNode = FxNode(endpoints: FxNode.Endpoints(rpc: nodeUrl), wallet: nil)
        private(set) var balance = ""
        public let balanceText = BehaviorRelay<String>(value: TR("Updating") + "...")
        var fetchBalance: Observable<String> {
            if balance != "" { return Observable.just(balance) }
            
            weak var welf = self
            return node.query(address: address)
                .do(onNext: { welf?.hanlder(result: $0) },
                    onError: { welf?.hanlder(error: $0) })
                .map{ _ in return welf?.balance ?? "0" }
        }
        
        func refreshIfNeed() {
            _ = fetchBalance.subscribe({ (_) in })
        }
        
        private func hanlder(result: JSON? = nil, error: Error? = nil) {
            
            if let result = result {
                
                let accountInfo = SmsUser.instance(fromQuery: result)
                for coin in accountInfo.coins {
                    if coin.denom == token.lowercased() {
                        balance = coin.amount
                        break
                    }
                }
            }
            
            let balanceText = balance.isEmpty ? "--" : balance.fxc.thousandth()
            self.balanceText.accept(balanceText)
        }
    }
}
