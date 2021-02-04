//
//  FxSelectAddressViewModel.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/25.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import TrustWalletCore

//MARK: FXListViewModel
extension SelectAddressViewController {
    
    class FxListViewModel: ListViewModel {
        
        override func cellVM(derivationAddress: Int) -> CellViewModel {
            return FxCellViewModel(wallet, derivationAddress: derivationAddress)
        }
    }
}

//MARK: FXCellViewModel
extension SelectAddressViewController {
    
    class FxCellViewModel: CellViewModel {
        
        override func generateAddress() -> String {
            return AnyAddress(publicKey: publicKey, coin: .cosmos).description
        }
    }
}
