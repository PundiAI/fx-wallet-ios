//
//  BroadcastTxResultController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/13.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import FunctionX
import SwiftyJSON

extension BroadcastTxResultController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction else { return nil }
        
        let vc = BroadcastTxResultController(tx: tx)
        return vc
    }
}

class BroadcastTxResultController: WKViewController {

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction) {
        self.tx = tx
        super.init(nibName: nil, bundle: nil)
    }

    let tx: FxTransaction
    private var binder: BroadcastTxAlertController.ResultBinder?

    override var preferFullTransparentNavBar: Bool { true }
    override func loadView() {
        
        let view = BroadcastTxAlertController.ResultView(frame: ScreenBounds).relayoutForFullScreen()
        self.view = view
        self.binder = BroadcastTxAlertController.ResultBinder(view: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        let closeAction = CocoaAction({[weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        self.binder?.bind(tx, closeAction: closeAction, closeTitle: TR("BroadcastTx.ReturnToHome"))
    }
}


//MARK: UI
extension BroadcastTxAlertController.ResultView {
    fileprivate func relayoutForFullScreen() -> BroadcastTxAlertController.ResultView {
        
        backgroundColor = HDA(0x272727)
        closeButton.isHidden = true
        containerView.isHidden = true
        addSubview(self.listView)
        listView.snp.remakeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
        }
        return self
    }
}
