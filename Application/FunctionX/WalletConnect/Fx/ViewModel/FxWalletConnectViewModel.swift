//
//  FxWalletConnectViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxCocoa

extension FxWalletConnectViewController {
    class CellViewModel {
        
        init(coin: Coin, balance: Balance) {
            self.coin = coin
            self.balance = balance
        }
        
        let coin: Coin
        let balance: Balance
        var height: CGFloat = 36.auto()
        
        func set(height: CGFloat) -> CellViewModel { self.height = height; return self }
    }
}
