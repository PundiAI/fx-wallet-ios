//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension BackUpNoticeViewController {
    
    class ViewModel: WKListViewModel<CellViewModel> {
        
        override init() {
            super.init()
            self.bind()
        }
        
        private func bind() {
            
            items.append(CellViewModel(TR("BackUpNotice.Tip0.Title"), TR("BackUpNotice.Tip0.SubTitle")))
            
            items.append(CellViewModel(TR("BackUpNotice.Tip1.Title"), TR("BackUpNotice.Tip1.SubTitle")))
            
            items.append(CellViewModel(TR("BackUpNotice.Tip2.Title"), TR("BackUpNotice.Tip2.SubTitle")))
            
            items.append(CellViewModel(TR("BackUpNotice.Tip3.Title"), TR("BackUpNotice.Tip3.SubTitle")))
            
        }
    }
}
        
