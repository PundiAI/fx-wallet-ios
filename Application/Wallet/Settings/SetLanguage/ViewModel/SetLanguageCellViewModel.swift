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

extension SetLanguageViewController {
    
    class CellViewModel {
        var item: LanguageItem
        fileprivate(set) var selected = BehaviorRelay<Bool>(value: false)
        
        init(item: LanguageItem) {
            self.item = item
            self.set(item: item)
        }
        
        func set(item: LanguageItem) {
            self.item = item
            let select = WKLocale.Shared.language.title == item.title
            selected.accept(select)
        }
    }
}
        
