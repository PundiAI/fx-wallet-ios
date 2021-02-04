//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SetCurrencyViewController {
    
    class CellViewModel {
        var item: Currency
        fileprivate(set) var selected = BehaviorRelay<Bool>(value: false)
        
        init(item: Currency) {
            self.item = item
            self.set(item: item)
        }
        
        func set(item: Currency) {
            self.item = item
            selected.accept(item.selected)
        }
    }
}
        
