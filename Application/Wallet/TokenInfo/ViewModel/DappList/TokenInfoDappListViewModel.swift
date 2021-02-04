//
//  TokenInfoDappListViewModel.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/20.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension TokenInfoDappListBinder {
    
    class ViewModel: WKListViewModel<DappCellViewModel> {
        
        let coin: Coin
        let wallet: WKWallet
        
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            super.init()
            
            self.refreshItems = Action { [weak self] _ -> Observable<[DappCellViewModel]> in
                if coin.isCloud { return .just([]) }
                
                var items: [DappCellViewModel] = []
                for dapp in wallet.dappManager.apps {
                    if dapp.isExplorer || dapp.isCrossChain || coin.isFunctionX {
                        items.append(DappCellViewModel(dapp: dapp))
                    }
                }
                self?.items = items
                return .just(items)
            }
        }
    }
}
