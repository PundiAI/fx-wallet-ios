//
//  ETHDappSelectAddressViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import RxSwift
import TrustWalletCore
import WKKit

extension ETHDappSelectAddressViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let dapp = context["dapp"] as? Dapp else { return nil }

        let token = context["token"] as? String
        let vc = ETHDappSelectAddressViewController(wallet: wallet, dapp: dapp, chain: .ethereum, token: token)
        if let handler = context["handler"] as? (UIViewController?, Keypair) -> Void {
            vc.confirmHandler = handler
        }
        return vc
    }
}

class ETHDappSelectAddressViewController: DappSelectAddressViewController {
    override var cellClass: Cell.Type { return ETHCell.self }
    override var listViewModel: ListViewModel { ETHListViewModel(wallet, token: token) }

    override func bindDapp() {
        super.bindDapp()
        viewS.titleLabel.text = TR("SelectAddress.ETH.Title")
    }
}
