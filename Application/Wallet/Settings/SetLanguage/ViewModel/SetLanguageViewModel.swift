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
    
    struct Language {
       var name: String
       var selected: Bool = false
    }
    
    class ViewModel {
        
        init() {
            self.items = WKLocale.Shared.languages.map { CellViewModel(item: $0) }
        }
        
        var items: [CellViewModel]
        
        func selecdItem() -> LanguageItem? {
            return WKLocale.Shared.language
        }
    }
}



