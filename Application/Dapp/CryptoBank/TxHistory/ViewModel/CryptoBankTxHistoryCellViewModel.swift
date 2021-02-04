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
    
    class CellViewModel: RxObject {
        
        init(_ txInfo: CryptoBankTxInfo) {
            self.txInfo = txInfo
            super.init()
            
            if txInfo.symbol.isNotEmpty {
                txInfo.symbol.exchangeRate().value
                    .filter{ $0.isAvailable }
                    .take(1)
                    .subscribe(onNext: { [weak self](v) in
                        if v.isAvailable, let amount = self?.txInfo.amount {
                            self?.legalAmount.accept("$\(amount.mul(v.value, ThisAPP.CurrencyDecimal))")
                        }
                }).disposed(by: defaultBag)
            }
        }
        
        let txInfo: CryptoBankTxInfo
        var isDeposit: Bool { txInfo.type == .deposit }
        
        lazy var dateText = Date(timeIntervalSince1970: TimeInterval(txInfo.timestamp)).format(with: "z YYYY-MM-dd HH:mm:ss")
        lazy var legalAmount = BehaviorRelay<String>(value: "$--")
        
        let height: CGFloat = (328 + 24).auto()
    }
}
        
