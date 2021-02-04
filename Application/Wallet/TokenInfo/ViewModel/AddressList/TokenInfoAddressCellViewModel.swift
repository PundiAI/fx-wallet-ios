//
//  TokenInfoAddressCellViewModel.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/20.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import XChains
import RxSwift
import RxCocoa
import TrustWalletCore

extension TokenInfoAddressListBinder {
    
    class CellViewModel {
        
        init(account: Keypair, coin: Coin) {
            self.coin = coin
            self.account = account
        }
        
        let coin: Coin
        let account: Keypair
        
        var address: String { account.address }
        lazy var remark = BehaviorRelay<String>(value: account.remark)
        
        lazy var balance = XWallet.currentWallet?.wk.balance(of: account.address, coin: coin) ?? .empty
         
        func refresh() {
            balance.refreshIfNeed()
        }
    }
    
}
