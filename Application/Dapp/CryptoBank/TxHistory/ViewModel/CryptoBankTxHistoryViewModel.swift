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

extension CryptoBankTxHistoryViewController {
    
    class ViewModel: WKListViewModel<CellViewModel> {
        
        let wallet: WKWallet
        init(wallet: WKWallet) {
            self.wallet = wallet
            super.init()
            
            self.pager.startPage = 0
            self.pager.pageSize = 10
            self.fetchItems = { pager in
                return CryptoBankTxCache.shared.selectAll(ofWallet: wallet.id, page: pager.page, pageSize: pager.pageSize)
                    .map{ $0.map{ CellViewModel($0) } }
            }
        }
    }
}
        
