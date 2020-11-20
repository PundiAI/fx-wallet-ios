//
//  FxAnyHrpSelectAddressViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/5/23.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxAnyHrpSelectAddressViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let hrp = context["hrp"] as? String,
            let dapp = context["dapp"] as? Dapp else { return nil }

        let derivationTemplate = context["derivationTemplate"] as? String
        let vc = FxAnyHrpSelectAddressViewController(wallet: wallet, hrp: hrp, derivationTemplate: derivationTemplate, dapp: dapp)
        if let handler = context["handler"] as? (UIViewController?, Keypair) -> Void {
            vc.confirmHandler = handler
        }
        return vc
    }
}

class FxAnyHrpSelectAddressViewController: SelectAddressViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet, hrp: String, derivationTemplate: String? = nil, dapp: Dapp) {
        self.hrp = hrp
        self.dapp = dapp
        self.derivationTemplate = derivationTemplate
        super.init(wallet: wallet)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindDapp()
    }

    let hrp: String
    let dapp: Dapp
    let derivationTemplate: String?

    func bindDapp() {
        viewS.subtitleLabel.text = TR("WalletConnect.SelectAddress.Subtitle$", dapp.name)
        viewS.navTitleLabel.text = dapp.name
        viewS.navIconIV.setImage(urlString: dapp.icon, placeHolderImage: dapp.placeholderIcon)
    }

    override var cellClass: Cell.Type { return AddressCell.self }
    override var listViewModel: ListViewModel { AddressListViewModel(wallet, hrp: hrp, derivationTemplate: derivationTemplate) }
}
