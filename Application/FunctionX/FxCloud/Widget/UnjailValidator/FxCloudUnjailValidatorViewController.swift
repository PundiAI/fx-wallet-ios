//
//  FxCloudUnjailValidatorViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/8/6.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxCocoa
import FunctionX
import SwiftyJSON
import TrustWalletCore

extension FxCloudUnjailValidatorViewController {

    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction else { return nil }
        
        let vc = FxCloudUnjailValidatorViewController(tx: tx)
        vc.confirmHandler = context["handler"] as? () -> Void
        return vc
    }
}

class FxCloudUnjailValidatorViewController: FxCloudWidgetActionViewController {
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction) {
        self.tx = tx
        
        let hrp = tx.rawValue["prefix"].string ?? "fx"
        let chainName = tx.rawValue["chainId"].string ?? "--"
        super.init(hrp: hrp, chainName: chainName)
    }
    
    let tx: FxTransaction
    var confirmHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var titleText: String { "Unjail Validator" }
    
    override func bindList() {
        super.bindList()
        
        listBinder.push(InfoTitleCell.self) { $0.titleLabel.text = TR("CloudWidget.SubDelegatorAddr.ValidatorAddress") }
        listBinder.push(FxCloudSubmitValidatorAddressCompletedViewController.ValidatorAddressCell.self, vm: ["walletAddress": tx.delegator, "validatorAddress": tx.validator])
    }
    
    override func bindAction() {
        
        wk.view.confirmButton.title = "UNJAIL"
        wk.view.confirmButton.rx.tap.subscribe(onNext: { [weak self](_) in
            self?.confirmHandler?()
        }).disposed(by: defaultBag)
    }
}
