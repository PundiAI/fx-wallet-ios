//
//  ApprovePopController.swift
//  fxWallet
//
//  Created by May on 2020/12/25.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import TrustWalletCore
import Hero

class OxApprovingController: FxRegularPopViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
        logWhenDeinit()
    }
    
    override var dismissWhenTouch: Bool { false }
    
    override func bindListView() {
        listBinder.push(ContentCell.self, vm: "NPXS")  { self.bindContent($0) }
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    private func bindContent(_ cell: ContentCell) {
        cell.noticeLabel1.text = TR("Ox.Approve.Title", "NPXS")
        cell.noticeLabel2.text = TR("Ox.Approve.SubTitle", "NPXS")
    }
    
    private func bindAction(_ cell: ActionCell) {
           
           weak var welf = self
           cell.cancelButton.rx.tap.subscribe(onNext: { (_) in
               welf?.dismiss()
           }).disposed(by: cell.defaultBag)
           
           cell.confirmButton.rx.tap.subscribe(onNext: { (_) in
                
            }).disposed(by: cell.defaultBag)
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}
