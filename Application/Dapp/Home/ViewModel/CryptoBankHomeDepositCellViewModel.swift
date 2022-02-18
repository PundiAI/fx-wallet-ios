//
//  CryptoBankHomeDepositCellViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class DepositCellViewModel {
        
        init(wallet: WKWallet) {
            self.wallet = wallet
        }
        
        let wallet: WKWallet
        lazy var items: [CryptoBankAssetCellViewModel] = []
        
        func reloadIfNeed() -> Bool {
            guard AAve.current.tokens.count >= 3 else { return false }
            
            let needReload = items.isEmpty || items.first?.coin.isETH == false
            if needReload {
                
                items.removeAll()
                for coin in AAve.current.recommendedTokens {
                    items.append(CryptoBankAssetCellViewModel(coin: coin))
                }
                refresh()
            }
            return needReload
        }
        
        func refresh() {
            items.forEach{ $0.reserveData.refreshIfNeed() }
        }
        
        lazy var height: CGFloat = {
           
            let itemCount = 3//items.count
            let descHeight = TR("CryptoBank.DepositDesc").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            let titleHeight = 64.auto() + descHeight
            let listHeight = 58.auto() + CGFloat(itemCount * 80.auto())
            let actionHeight: CGFloat = 68.auto()
            return 24.auto() + titleHeight + listHeight + actionHeight
        }()
    }
    
}


