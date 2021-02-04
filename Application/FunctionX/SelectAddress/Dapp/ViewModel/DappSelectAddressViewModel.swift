//
//  DappSelectAddressViewModel.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/30.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import FunctionX
import SwiftyJSON
import TrustWalletCore

//MARK: FXListViewModel
extension DappSelectAddressViewController {
    
    class DappListViewModel: ListViewModel {
        
        let chain: FxChain.Types
        let token: String?
        var fx: FunctionX { FunctionX.shared }
        init(_ wallet: Wallet, chain: FxChain.Types, token: String? = nil) {
            self.chain = chain
            self.token = token
            super.init(wallet)
            
//            self.handleItems = { [weak self](this, items) in
//
//                this.items.append(contentsOf: items)
//                self?.fetchNames(items)
//                self?.fetchBalance(items)
//            }
        }
        
        override func cellVM(derivationAddress: Int) -> CellViewModel {
            
            let item = DappCellViewModel(wallet, derivationAddress: derivationAddress, chain: chain, token: token)
            item.refreshIfNeed()
            return item
        }
        
//        private func fetchNames(_ items: [CellViewModel]) {
//
//            let addresses = items.map{ $0.address }
//            let signal = chain == .sms ? fx.sms.names(ofAddresses: addresses) : fx.hub.names(ofAddresses: addresses)
//            signal.subscribe(onNext: { (names) in
//                for (idx, item) in items.enumerated() {
//                    (item as? DappCellViewModel)?.accept(name: names[idx])
//                }
//            }).disposed(by: defaultBag)
//        }
//
//        private func fetchBalance(_ items: [CellViewModel]) {
//
//            let addresses = items.map{ $0.address }
//            let signal = chain == .sms ? fx.sms.query(addresses: addresses) : fx.hub.query(addresses: addresses)
//            signal.subscribe(onNext: { (result) in
//                for (idx, item) in items.enumerated() {
//                    (item as? DappCellViewModel)?.accept(balance: result[idx])
//                }
//            }).disposed(by: defaultBag)
//        }
    }
}

//MARK: FXCellViewModel
extension DappSelectAddressViewController {
    
    class DappCellViewModel: CellViewModel {
        
        let chain: FxChain.Types
        let token: String
        var hasName: Bool { chain == .hub || chain == .sms }
        
        public let addressName = BehaviorRelay<String>(value: "--")
        
        init(_ wallet: Wallet, derivationAddress: Int, chain: FxChain.Types, token: String? = nil) {
            self.chain = chain
            self.token = token ?? chain.token
            super.init(wallet, derivationAddress: derivationAddress)
            
            var name: String?
            if chain == .sms {
                name = UserDefaults.standard.nameOnSMS(ofAddress: self.address)
            } else {
                name = UserDefaults.standard.nameOnHUB(ofAddress: self.address)
            }
            
            addressName.accept(name ?? "--")
        }
        
        var fx: FunctionX { FunctionX.shared }
        var fetchName: Observable<String> {
            if hasName && addressName.value != "--" { return Observable.just(addressName.value) }
            
            let signal = chain == .sms ? fx.sms.name(ofAddress: address) : fx.hub.name(ofAddress: address)
            return signal
                .do(onNext: { self.save(name: $0) })
        }
        
        private(set) var balance = ""
        public let balanceText = BehaviorRelay<String>(value: TR("Updating") + "...")
        var fetchBalance: Observable<String> {
            if balance.isNotEmpty { return Observable.just(balance) }
            
            weak var welf = self
            let signal: Observable<JSON>
            if chain == .hub {
                signal = fx.hub.query(address: address)
            } else if chain == .sms {
                signal = fx.sms.query(address: address)
            } else {
                signal = fx.order.query(address: address)
            }
            return signal
                .do(onNext: { welf?.hanlder(result: $0) },
                    onError: { welf?.hanlder(error: $0) })
                .map{ _ in return welf?.balance ?? "0" }
        }
        
        func refreshIfNeed() {
            
            //ignore debug log
            _ = fetchName.subscribe({ (_) in })
            _ = fetchBalance.subscribe({ (_) in })
        }
        
        override var coinType: String { chain.coinType }
        override func generateAddress() -> String {
            return FunctionXAddress(hrp: chain.hrp, publicKey: publicKey.data)?.description ?? ""
        }
        
//        fileprivate func accept(name: String = "", balance: JSON? = nil) {
//
//            if name.isNotEmpty { save(name: name) }
//            if self.balance == "" { hanlder(result: balance) }
//        }
        
        fileprivate func save(name: String) {
            
            self.addressName.accept(name)
            if chain == .sms {
                UserDefaults.standard.set(nameOnSMS: name, ofAddress: self.address)
            } else {
                UserDefaults.standard.set(nameOnHUB: name, ofAddress: self.address)
            }
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
            if hasName {
                self.balanceText.accept("\(balanceText) \(token.uppercased())")
            } else {
                self.balanceText.accept(balanceText)
            }
        }
    }
}
