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

extension ResetWalletViewController {
    
    class CellViewModel {
        
        init(_ title: String, _ subTitle: String, _ subMarkTitle: String) {
            self.title = title
            self.subTitle = subTitle
            self.subMarkTitle = subMarkTitle
        }
        
        let title: String
        let subTitle: String
        let subMarkTitle: String
    }
}
        
