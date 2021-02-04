//
//  AuthorizeDappAlertController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/26.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension AuthorizeDappAlertController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let dapp = context["dapp"] as? Dapp,
            let authorityTypes = context["authorityTypes"] as? [Int] else { return nil }
        
        let vc = AuthorizeDappAlertController(dapp: dapp, authorityTypes: authorityTypes.map{ AuthorityCell.AuthorityType(rawValue: $0)! })
        if let completionHandler = context["handler"] as? (UIViewController?, Bool) -> Void {
            vc.completionHandler = completionHandler
        }
        return vc
    }
}

class AuthorizeDappAlertController: FxRegularPopViewController {
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(dapp: Dapp, authorityTypes: [AuthorityCell.AuthorityType]) {
        self.dapp = dapp
        self.authorityTypes = authorityTypes
        super.init(nibName: nil, bundle: nil)
    }
    
    let dapp: Dapp
    var completionHandler: ( (UIViewController?, Bool) -> Void )?
    private var authorityTypes: [AuthorityCell.AuthorityType]
    
    override func bindListView() {
        
        listBinder.push(DappInfoCell.self) { self.bindDapp($0) }
        for type in authorityTypes {
            listBinder.push(AuthorityCell.self, vm: type)
        }
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    private func bindDapp(_ cell: DappInfoCell) {
        
        cell.nameLabel.text = dapp.name
        cell.iconIV.setImage(urlString: dapp.icon, placeHolderImage: dapp.placeholderIcon)
    }
    
    private func bindAction(_ cell: ActionCell) {
        
        weak var welf = self
        cell.denyButton.rx.tap.subscribe(onNext: { (_) in
            welf?.dismiss(userCanceled: true)
        }).disposed(by: cell.reuseBag)
        
        cell.allowButton.rx.tap.subscribe(onNext: { (_) in
            welf?.dismiss(userCanceled: false)
        }).disposed(by: cell.reuseBag)
    }
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        
        if let handler = completionHandler {
            handler(self, !userCanceled)
        } else {
            Router.dismiss(self, animated: true, completion: nil)
        }
    }
}


