//
//  FxValidatorSelectKeypairViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/5/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import TrustWalletCore
import WKKit

extension FxValidatorSelectKeypairViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let dapp = context["dapp"] as? Dapp else { return nil }

        let vc = FxValidatorSelectKeypairViewController(wallet: wallet, hrp: "", dapp: dapp)
        if let handler = context["handler"] as? (UIViewController?, Keypair) -> Void {
            vc.confirmHandler = handler
        }
        return vc
    }
}

// MARK: FxValidatorSelectKeypairViewController

class FxValidatorSelectKeypairViewController: FxAnyHrpSelectAddressViewController {
    override var listViewModel: ListViewModel { KeypairListViewModel(wallet, hrp: hrp) }

    override func bindDapp() {
        super.bindDapp()

        viewS.titleLabel.text = TR("SelectAddress.Keypair.Title")
    }
}

// MARK: KeypairListViewModel

extension FxValidatorSelectKeypairViewController {
    class KeypairListViewModel: AddressListViewModel {
        override func cellVM(derivationAddress: Int) -> CellViewModel {
            return KeypairCellViewModel(wallet, derivationAddress: derivationAddress, hrp: hrp)
        }
    }
}

// MARK: KeypairCellViewModel

extension FxValidatorSelectKeypairViewController {
    class KeypairCellViewModel: AddressCellViewModel {
        override var derivationPath: String { "m/44'/118'/1'/0/\(derivationAddress)" }
        override var publicKey: PublicKey { privateKey.getPublicKeyEd25519() }
        override func generateAddress() -> String {
            return FunctionXValidatorKeypair(privateKey).encodedPublicKey()?.description ?? ""
        }
    }
}
