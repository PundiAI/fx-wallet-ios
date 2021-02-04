//
//  FxCloudWidgetActionVCompletediewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/20.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

class FxCloudWidgetActionCompletedViewController: FxCloudWidgetActionViewController {
    
    override func bindList() {
        
        wk.view.listView.isScrollEnabled = false
        listBinder.push(ResultTitleCell.self)
    }
    
    override func bindAction() {
        
        wk.view.confirmButton.title = TR("ReturnToHome")
        wk.view.confirmButton.rx.action = CocoaAction({
            Router.currentNavigator?.popToRootViewController(animated: true)
        })
    }
}
