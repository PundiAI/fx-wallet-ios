//
//
//  XWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SelectReceiveCoinViewController {
    
    class AddCoinCellViewModel {
        
        init(_ rawValue: OxToken) {
            self.rawValue = rawValue
        }

        let rawValue: OxToken
    }
}
        
