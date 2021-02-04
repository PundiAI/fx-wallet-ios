//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class ViewModel {
        
        let wallet: WKWallet
        init(wallet: WKWallet) {
            self.wallet = wallet
        }
        
        lazy var delegateVM = DelegateCellViewModel(wallet: wallet)
        lazy var depositVM = DepositCellViewModel(wallet: wallet)
        lazy var purchaseVM = PurchaseCellViewModel(wallet: wallet)
        
        func refresh() {
            
            delegateVM.refresh()
            depositVM.refresh()
            purchaseVM.refresh()
        }
    }
}
        
