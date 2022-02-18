//
//  CryptoBankHomePurchaseCellViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class PurchaseCellViewModel {
        
        init(wallet: WKWallet) {
            self.wallet = wallet
            
            for coin in RampAssets.shared.recommendedTokens {
                items.append(CryptoBankPurchaseCellViewModel(coin: coin))
            }
        }
        
        let wallet: WKWallet
        lazy var items: [CryptoBankPurchaseCellViewModel] = []
        
        func refresh() {
//            items.forEach{ $0.reserveData.refreshIfNeed() }
        }
        
        lazy var height: CGFloat = {
           
            let descHeight = TR("CryptoBank.PurchaseDesc").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            let titleHeight = 62.auto() + descHeight
            let listHeight = CGFloat(items.count * 80.auto()) 
            let actionHeight: CGFloat = 68.auto()
            return 24.auto() + titleHeight + listHeight + actionHeight
        }()
    }
    
}
