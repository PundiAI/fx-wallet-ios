//
//  RemoveTokenViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit
import RxSwift
import TrustWalletCore

extension ChangeNodeAlertController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let handler = context["handler"] as? ((Bool) -> Void),
               let name = context["name"] as? String else { return nil }
        let vc = ChangeNodeAlertController(name: name, handler: handler)
        return vc
    }
}

class ChangeNodeAlertController: FxRegularPopViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init( name: String, handler:@escaping ((Bool) -> Void)) {
        self.name = name
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
    }
    
    let name: String
    let handler:((Bool) -> Void)
    override var dismissWhenTouch: Bool { true }
    override var interactivePopIsEnabled: Bool { false }
    
    override func bindListView() { 
        listBinder.push(ContentCell.self) { [weak self] in
            $0.noticeLabel1.text = TR("ChangeNode.Alert.Notice1$", self!.name)
        }
        listBinder.push(ActionCell.self) {[weak self] in
            self?.bindAction($0)
        }
    }
    
    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { (_) in
            Router.pop(welf)
        }).disposed(by: cell.defaultBag)
        
        cell.confirmButton.action {
            Router.pop(welf, animated: false) {
                welf?.handler(true)
            }
        }
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}

 
