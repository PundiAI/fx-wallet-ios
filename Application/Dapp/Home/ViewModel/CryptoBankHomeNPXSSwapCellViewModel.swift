//
//  CryptoBankHomeNPXSSwapCellViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/1.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class NPXSSwapCellViewModel {
        
        init(wallet: WKWallet) {
            self.wallet = wallet 
        }
        
        let wallet: WKWallet
        var display:Bool {
            get {
                if Node.Current(.ethereum).isKovan { return false }
                return ThisAPP.AuthPath.npxsToPundixDisplay
            }
        }
        
        var coin: Coin { return CoinService.current.coin(forId: "npxs_60") ?? .empty }
        
        func refresh() {}
        
        lazy var height: CGFloat = {
            
            let descHeight = TR("NPXSSwap.Desc").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            let titleHeight = 62.auto() + descHeight
            return 24.auto() + titleHeight + 148.auto()
        }()
    }
}
