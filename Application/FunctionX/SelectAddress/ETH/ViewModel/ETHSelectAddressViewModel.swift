//
//  ETHSelectAddressViewModel.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import FunctionX
import SwiftyJSON
import TrustWalletCore

extension SelectAddressViewController {
    
    class ETHListViewModel: ListViewModel {
        
        let token: String?
        init(_ wallet: Wallet, token: String? = nil) {
            self.token = token
            super.init(wallet)
        }
        
        override func cellVM(derivationAddress: Int) -> CellViewModel {
            
            let item = ETHCellViewModel(wallet, derivationAddress: derivationAddress, token: token)
            item.refreshIfNeed()
            return item
        }
    }
}



//MARK: FXCellViewModel
extension SelectAddressViewController {
    
    class ETHCellViewModel: CellViewModel {
        
        let chain = FxChain.Types.ethereum
        let token: String
        var fx: FunctionX { FunctionX.shared }
        
        init(_ wallet: Wallet, derivationAddress: Int, token: String? = nil) {
            self.token = token ?? FxChain.ethereum.token
            super.init(wallet, derivationAddress: derivationAddress)
        }
        
        override var publicKey: PublicKey { privateKey.getPublicKeySecp256k1(compressed: false) }
        override var coinType: String { chain.coinType }
        override func generateAddress() -> String { AnyAddress(publicKey: publicKey, coin: .ethereum).description }
        
        private(set) var balance = ""
        public let balanceText = BehaviorRelay<String>(value: TR("Updating") + "...")
        var fetchBalance: Observable<String> {
            if balance != "" { return Observable.just(balance) }
            
            weak var welf = self
            return fx.bridges.eth.balance(of: address, token: token)
                .do(onNext: { welf?.hanlder(balance: $0) },
                    onError: { welf?.hanlder(error: $0) })
                .map{ _ in return welf?.balance ?? "0" }
        }
        
        func refreshIfNeed() {
            _ = fetchBalance.subscribe()
        }
        
        private func hanlder(balance: String? = nil, error: Error? = nil) {

            if let balance = balance {
                
                self.balance = balance
                self.balanceText.accept(balance.eth.thousandth())
            } else {
                self.balanceText.accept("--")
            }
        }
    }
}
