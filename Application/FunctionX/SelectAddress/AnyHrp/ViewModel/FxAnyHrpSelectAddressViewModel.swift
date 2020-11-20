//
//  FxAnyHrpSelectAddressViewModel.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/5/23.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import WKKit

// MARK: AddressListViewModel

extension FxAnyHrpSelectAddressViewController {
    class AddressListViewModel: ListViewModel {
        let hrp: String
        let derivationTemplate: String?

        init(_ wallet: Wallet, hrp: String, derivationTemplate: String? = nil) {
            self.hrp = hrp
            self.derivationTemplate = derivationTemplate
            super.init(wallet)
        }

        override func cellVM(derivationAddress: Int) -> CellViewModel {
            return AddressCellViewModel(wallet, derivationAddress: derivationAddress, hrp: hrp, derivationTemplate: derivationTemplate)
        }
    }
}

// MARK: AddressCellViewModel

extension FxAnyHrpSelectAddressViewController {
    class AddressCellViewModel: CellViewModel {
        let hrp: String
        let path: String

        init(_ wallet: Wallet, derivationAddress: Int, hrp: String, derivationTemplate: String? = nil) {
            self.hrp = hrp
            let template = derivationTemplate ?? "m/44'/118'/0'/0/0"
            var components = template.components(separatedBy: "/")
            components.removeLast()
            components.append(String(derivationAddress))
            path = components.joined(separator: "/")
            super.init(wallet, derivationAddress: derivationAddress)
        }

        override var derivationPath: String { path }
        override func generateAddress() -> String {
            return FunctionXAddress(hrpString: hrp, publicKey: publicKey.data)?.description ?? ""
        }
    }
}
