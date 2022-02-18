//
//
//  XWallet
//
//  Created by May on 2020/12/24.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import Hero

extension OxNotFeeViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let minNeedPay = context["minNeedPay"] as? String,
              let balance = context["balance"] as? String  else {
            return nil
        }
        return OxNotFeeViewController(current: (minNeedPay, balance))
    }
}

class OxNotFeeViewController: FxRegularPopViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(current: (String, String)) {
        self.current = current
        super.init(nibName: nil, bundle: nil) 
        self.modalPresentationStyle = .fullScreen
        logWhenDeinit()
    }
    
    let current: (String, String)
    
    override var dismissWhenTouch: Bool { false }
    
    override func bindListView() {
        listBinder.push(ContentCell.self) { self.bindContent($0) }
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }

    private func bindContent(_ cell: ContentCell) {
        cell.payLabel.text =  current.0
        cell.balanceLabel.text = current.1
    }
    
    private func bindAction(_ cell: ActionCell) {
    
        cell.confirmButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let this = self else { return }
                Router.dismiss(this)
        }).disposed(by: cell.defaultBag)
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}
