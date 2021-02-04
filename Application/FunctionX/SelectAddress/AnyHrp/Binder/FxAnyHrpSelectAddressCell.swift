//
//  FxAnyHrpSelectAddressCell.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/5/23.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxAnyHrpSelectAddressViewController {
    
    class AddressCell: SelectAddressViewController.Cell {
        
        override func layoutUI() {
            super.layoutUI()
            view.relayoutForNoName()
        }
    }
}
