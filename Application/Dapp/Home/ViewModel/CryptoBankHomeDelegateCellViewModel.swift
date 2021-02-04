//
//  CryptoBankHomeDelegateCellViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/25.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class DelegateCellViewModel {
        
        init(wallet: WKWallet) {
            self.wallet = wallet
            
            self.coin = CoinService.current.functionX
        }
        
        let wallet: WKWallet
        let coin: Coin
        
        func refresh() {}
        
        var height: CGFloat { (24 + 244).auto() }
    }
    
}
