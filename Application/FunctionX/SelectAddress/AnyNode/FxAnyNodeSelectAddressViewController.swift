//
//  FxCloudSelectAddressViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/6/2.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxAnyNodeSelectAddressViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let hrp = context["hrp"] as? String,
            let dapp = context["dapp"] as? Dapp,
            let token = context["token"] as? String,
            let nodeUrl = context["nodeUrl"] as? String else { return nil }
        
        let derivationTemplate = context["derivationTemplate"] as? String
        let vc = FxAnyNodeSelectAddressViewController(wallet: wallet, hrp: hrp, derivationTemplate: derivationTemplate, dapp: dapp, nodeUrl: nodeUrl, token: token)
        if let handler = context["handler"] as? (UIViewController?, Keypair) -> Void {
            vc.confirmHandler = handler
        }
        return vc
    }
}

class FxAnyNodeSelectAddressViewController: FxAnyHrpSelectAddressViewController {

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet, hrp: String, derivationTemplate: String? = nil, dapp: Dapp, nodeUrl: String, token: String) {
        self.token = token
        self.nodeUrl = nodeUrl
        super.init(wallet: wallet, hrp: hrp, derivationTemplate: derivationTemplate, dapp: dapp)
    }
    
    let token: String
    let nodeUrl: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindDapp()
    }
    
    override var cellClass: Cell.Type { return FCAddressCell.self }
    override var listViewModel: ListViewModel { FCListViewModel(wallet, hrp: hrp, derivationTemplate: derivationTemplate, nodeUrl: nodeUrl, token: token) }
}
